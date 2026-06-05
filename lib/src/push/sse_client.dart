import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SseMessage {
  final String id;
  final String event;
  final String data;

  const SseMessage({required this.id, required this.event, required this.data});
}

class SseClient {
  final http.Client _httpClient;

  SseClient(this._httpClient);

  Stream<SseMessage> connect(Uri uri,
      {Map<String, String> extraHeaders = const {}}) async* {
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache'
      ..headers.addAll(extraHeaders);

    final response = await _httpClient.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw StateError('SSE connect failed ${response.statusCode}: $body');
    }

    String id = '';
    String event = 'message';
    final dataLines = <String>[];

    await for (final chunk in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (chunk.isEmpty) {
        if (dataLines.isNotEmpty) {
          yield SseMessage(
            id: id,
            event: event,
            data: dataLines.join('\n'),
          );
        }
        event = 'message';
        dataLines.clear();
      } else if (chunk.startsWith('id:')) {
        id = chunk.substring(3).trimLeft();
      } else if (chunk.startsWith('event:')) {
        event = chunk.substring(6).trimLeft();
      } else if (chunk.startsWith('data:')) {
        dataLines.add(chunk.substring(5).trimLeft());
      }
    }
  }
}
