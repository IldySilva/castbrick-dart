import '../client.dart';
import 'push_token_response.dart';
import 'push_publish_response.dart';
import 'push_subscription.dart';

class PushResource {
  final CastBrickClient _client;

  PushResource(this._client);

  /// Issue a short-lived channel token (server-side call).
  Future<PushTokenResponse> issueToken({
    required List<String> channels,
    String? userId,
    int ttlSeconds = 3600,
  }) async {
    final raw = await _client.post<Map<String, dynamic>>(
      '/push/tokens',
      body: {
        'channels': channels,
        if (userId != null) 'userId': userId,
        'ttlSeconds': ttlSeconds,
      },
    );
    return PushTokenResponse.fromJson(raw);
  }

  /// Publish an event to a channel (server-side call).
  Future<PushPublishResponse> publish({
    required String channel,
    required String event,
    required Object data,
  }) async {
    final raw = await _client.post<Map<String, dynamic>>(
      '/push/publish',
      body: {
        'channel': channel,
        'event': event,
        'data': data,
      },
    );
    return PushPublishResponse.fromJson(raw);
  }

  /// Subscribe to one or more channels via SSE (client-side call).
  ///
  /// [token] must be a channel token from [issueToken].
  PushSubscription subscribe({required String token}) {
    final uri = _client.buildStreamUri('/push/stream', token: token);
    return PushSubscription.connect(
      httpClient: _client.httpClient,
      streamUri: uri,
    );
  }
}
