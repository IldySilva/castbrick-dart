import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'push_event.dart';
import 'sse_client.dart';

class PushSubscription {
  final Uri _streamUri;
  final SseClient _sseClient;

  final _controllers = <String, StreamController<PushEvent>>{};
  StreamSubscription<SseMessage>? _sseSubscription;
  String _lastEventId = '';
  bool _disposed = false;
  int _backoffMs = 1000;
  static const int _maxBackoffMs = 30000;

  PushSubscription._({
    required http.Client httpClient,
    required Uri streamUri,
  })  : _streamUri = streamUri,
        _sseClient = SseClient(httpClient) {
    _connect();
  }

  factory PushSubscription.connect({
    required http.Client httpClient,
    required Uri streamUri,
  }) =>
      PushSubscription._(httpClient: httpClient, streamUri: streamUri);

  Stream<PushEvent> on(String channel) {
    return _controllers
        .putIfAbsent(
            channel, () => StreamController<PushEvent>.broadcast())
        .stream;
  }

  void dispose() {
    _disposed = true;
    _sseSubscription?.cancel();
    _sseSubscription = null;
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
  }

  void _connect() {
    if (_disposed) return;

    final uri = _lastEventId.isNotEmpty
        ? _streamUri.replace(
            queryParameters: {
              ..._streamUri.queryParameters,
              'lastEventId': _lastEventId,
            },
          )
        : _streamUri;

    _sseSubscription = _sseClient.connect(uri).listen(
          _handleMessage,
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
          cancelOnError: false,
        );
  }

  void _handleMessage(SseMessage msg) {
    if (msg.id.isNotEmpty) _lastEventId = msg.id;

    if (msg.event == 'connected') {
      _backoffMs = 1000;
      return;
    }

    if (msg.event == 'message') {
      try {
        final json = jsonDecode(msg.data) as Map<String, dynamic>;
        final event = PushEvent.fromJson(json);
        final ctrl = _controllers[event.channel];
        if (ctrl != null && !ctrl.isClosed) ctrl.add(event);
      } catch (_) {}
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _sseSubscription?.cancel();
    _sseSubscription = null;
    final delay = Duration(milliseconds: _backoffMs);
    _backoffMs = (_backoffMs * 2).clamp(1000, _maxBackoffMs);
    Future.delayed(delay, _connect);
  }
}
