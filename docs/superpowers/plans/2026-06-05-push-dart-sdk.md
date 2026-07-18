# Push Dart SDK — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Push support to the `castbrick` Dart/Flutter package — server-side `push.issueToken` + `push.publish`, plus a `push.subscribe()` method that returns a `PushSubscription` for listening to SSE events by channel.

**Architecture:** `PushResource` added to `CastBrick` facade for both server-side operations (token + publish) and client-side SSE subscription. `SseClient` handles raw HTTP streaming via `http.Client.send()` with `StreamedResponse`. `PushSubscription` wraps per-channel `StreamController`s and exposes `on(channel)` → `Stream<PushEvent>`. Auto-reconnect with exponential backoff.

**Tech Stack:** Dart, `http` package (already a dependency), `dart:async`, `dart:convert`

---

## Reference files (read before starting)

- `lib/src/client.dart` — `CastBrickClient` pattern (reuse `_httpClient`, `_buildUri`)
- `lib/src/resources/sms.dart` — resource pattern (constructor, method signatures)
- `lib/src/castbrick_dart_base.dart` — `CastBrick` facade (add `push` field)
- `lib/src/models.dart` — model class pattern (`fromJson`)
- `pubspec.yaml` — check `http` version

---

## File Map

### New files
| File | Responsibility |
|------|----------------|
| `lib/src/push/push_event.dart` | `PushEvent` model |
| `lib/src/push/push_token_response.dart` | `PushTokenResponse` model |
| `lib/src/push/push_publish_response.dart` | `PushPublishResponse` model |
| `lib/src/push/sse_client.dart` | Raw SSE stream parser over `StreamedResponse` |
| `lib/src/push/push_subscription.dart` | `PushSubscription` — per-channel routing, reconnect |
| `lib/src/push/push_resource.dart` | `PushResource` — `issueToken`, `publish`, `subscribe` |

### Modified files
| File | Change |
|------|--------|
| `lib/src/castbrick_dart_base.dart` | Add `late final PushResource push` |
| `lib/castbrick_dart.dart` | Export push models |

---

## Task 1 — Push models

**Files:**
- Create: `lib/src/push/push_event.dart`
- Create: `lib/src/push/push_token_response.dart`
- Create: `lib/src/push/push_publish_response.dart`

- [ ] **Step 1: Create `push_event.dart`**

```dart
// lib/src/push/push_event.dart
class PushEvent {
  final String channel;
  final String event;
  final dynamic data;
  final DateTime timestamp;

  const PushEvent({
    required this.channel,
    required this.event,
    required this.data,
    required this.timestamp,
  });

  factory PushEvent.fromJson(Map<String, dynamic> json) => PushEvent(
    channel: json['channel'] as String,
    event: json['event'] as String,
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
```

- [ ] **Step 2: Create `push_token_response.dart`**

```dart
// lib/src/push/push_token_response.dart
class PushTokenResponse {
  final String token;
  final DateTime expiresAt;
  final List<String> channels;

  const PushTokenResponse({
    required this.token,
    required this.expiresAt,
    required this.channels,
  });

  factory PushTokenResponse.fromJson(Map<String, dynamic> json) => PushTokenResponse(
    token: json['token'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    channels: List<String>.from(json['channels'] as List),
  );
}
```

- [ ] **Step 3: Create `push_publish_response.dart`**

```dart
// lib/src/push/push_publish_response.dart
class PushPublishResponse {
  final String messageId;
  final int delivered;
  final double creditsUsed;

  const PushPublishResponse({
    required this.messageId,
    required this.delivered,
    required this.creditsUsed,
  });

  factory PushPublishResponse.fromJson(Map<String, dynamic> json) => PushPublishResponse(
    messageId: json['messageId'] as String,
    delivered: json['delivered'] as int,
    creditsUsed: (json['creditsUsed'] as num).toDouble(),
  );
}
```

- [ ] **Step 4: Verify dart analyze**

```bash
dart analyze lib/src/push/
```
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/src/push/push_event.dart \
        lib/src/push/push_token_response.dart \
        lib/src/push/push_publish_response.dart
git commit -m "feat(push): add PushEvent, PushTokenResponse, PushPublishResponse models"
```

---

## Task 2 — `SseClient`

**Files:**
- Create: `lib/src/push/sse_client.dart`

- [ ] **Step 1: Create `sse_client.dart`**

The SSE client parses the raw text/event-stream protocol line-by-line and emits parsed field maps.

```dart
// lib/src/push/sse_client.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A single parsed SSE event.
class SseMessage {
  final String id;
  final String event;
  final String data;

  const SseMessage({required this.id, required this.event, required this.data});
}

/// Opens an SSE stream by sending a GET request with `Accept: text/event-stream`.
/// Parses the response line-by-line and emits [SseMessage] objects.
class SseClient {
  final http.Client _httpClient;

  SseClient(this._httpClient);

  Stream<SseMessage> connect(Uri uri, {Map<String, String> extraHeaders = const {}}) async* {
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache'
      ..headers.addAll(extraHeaders);

    final response = await _httpClient.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw StateError('SSE connect failed ${response.statusCode}: $body');
    }

    // SSE field accumulation state
    String id = '';
    String event = 'message';
    final dataLines = <String>[];

    await for (final chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (chunk.isEmpty) {
        // Blank line = event dispatch
        if (dataLines.isNotEmpty) {
          yield SseMessage(
            id: id,
            event: event,
            data: dataLines.join('\n'),
          );
        }
        // Reset accumulator
        event = 'message';
        dataLines.clear();
        // Keep id across events (SSE spec)
      } else if (chunk.startsWith('id:')) {
        id = chunk.substring(3).trimLeft();
      } else if (chunk.startsWith('event:')) {
        event = chunk.substring(6).trimLeft();
      } else if (chunk.startsWith('data:')) {
        dataLines.add(chunk.substring(5).trimLeft());
      }
      // Ignore comment lines (':...')
    }
  }
}
```

- [ ] **Step 2: Verify**

```bash
dart analyze lib/src/push/sse_client.dart
```
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/src/push/sse_client.dart
git commit -m "feat(push): add SseClient — SSE stream parser over http.Client.send()"
```

---

## Task 3 — `PushSubscription`

**Files:**
- Create: `lib/src/push/push_subscription.dart`

- [ ] **Step 1: Create `push_subscription.dart`**

```dart
// lib/src/push/push_subscription.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'push_event.dart';
import 'sse_client.dart';

/// Manages a live SSE subscription across one or more channels.
/// Use [on] to get a stream of events for a specific channel.
/// Call [dispose] to close the connection.
class PushSubscription {
  final http.Client _httpClient;
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
  })  : _httpClient = httpClient,
        _streamUri = streamUri,
        _sseClient = SseClient(httpClient) {
    _connect();
  }

  factory PushSubscription.connect({
    required http.Client httpClient,
    required Uri streamUri,
  }) =>
      PushSubscription._(httpClient: httpClient, streamUri: streamUri);

  /// Returns a stream of [PushEvent]s for the given channel name.
  Stream<PushEvent> on(String channel) {
    return _controllers
        .putIfAbsent(channel, () => StreamController<PushEvent>.broadcast())
        .stream;
  }

  /// Closes the SSE connection and all channel streams.
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

    _sseSubscription = _sseClient
        .connect(uri)
        .listen(
          _handleMessage,
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
          cancelOnError: false,
        );
  }

  void _handleMessage(SseMessage msg) {
    if (msg.id.isNotEmpty) _lastEventId = msg.id;

    if (msg.event == 'connected') {
      _backoffMs = 1000; // reset on successful connect
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
```

- [ ] **Step 2: Verify**

```bash
dart analyze lib/src/push/push_subscription.dart
```
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/src/push/push_subscription.dart
git commit -m "feat(push): add PushSubscription — per-channel routing + exponential backoff reconnect"
```

---

## Task 4 — `PushResource`

**Files:**
- Create: `lib/src/push/push_resource.dart`

- [ ] **Step 1: Create `push_resource.dart`**

```dart
// lib/src/push/push_resource.dart
import '../client.dart';
import 'push_event.dart';
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
  /// Returns a [PushSubscription] — call [PushSubscription.on] to listen
  /// to a specific channel, then call [PushSubscription.dispose] to close.
  PushSubscription subscribe({required String token}) {
    final uri = _client.buildStreamUri('/push/stream', token: token);
    return PushSubscription.connect(
      httpClient: _client.httpClient,
      streamUri: uri,
    );
  }
}
```

**Note:** `buildStreamUri` and `httpClient` getter need to be added to `CastBrickClient` in the next step.

- [ ] **Step 2: Add `buildStreamUri` and `httpClient` getter to `CastBrickClient`**

Open `lib/src/client.dart` and add after the `close()` method:

```dart
  /// Exposes the underlying [http.Client] for SSE streaming.
  http.Client get httpClient => _httpClient;

  /// Builds a stream URI for SSE endpoints (no auth header — token is a query param).
  Uri buildStreamUri(String path, {required String token}) {
    return _buildUri(path, {'token': token});
  }
```

- [ ] **Step 3: Verify**

```bash
dart analyze lib/src/push/
```
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/src/push/push_resource.dart lib/src/client.dart
git commit -m "feat(push): add PushResource with issueToken, publish, subscribe"
```

---

## Task 5 — Wire into `CastBrick` facade + exports

**Files:**
- Modify: `lib/src/castbrick_dart_base.dart`
- Modify: `lib/castbrick_dart.dart`

- [ ] **Step 1: Add `push` to `CastBrick`**

In `lib/src/castbrick_dart_base.dart`, add the import and the `push` field:

```dart
// Add import at the top alongside existing resource imports:
import 'push/push_resource.dart';

// Add field alongside sms/contacts/broadcasts:
/// Push channel operations — issue tokens, publish events, subscribe.
late final PushResource push;

// Add initialization in constructor body alongside others:
push = PushResource(_client);
```

- [ ] **Step 2: Export push models**

In `lib/castbrick_dart.dart`, add after the existing exports:

```dart
export 'src/push/push_event.dart';
export 'src/push/push_token_response.dart';
export 'src/push/push_publish_response.dart';
export 'src/push/push_subscription.dart';
```

- [ ] **Step 3: Verify all exports compile**

```bash
dart analyze lib/
```
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/src/castbrick_dart_base.dart lib/castbrick_dart.dart
git commit -m "feat(push): wire PushResource into CastBrick facade + export push models"
```

---

## Task 6 — Tests + version bump

**Files:**
- Modify: `test/castbrick_dart_test.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add push token and publish tests**

Open `test/castbrick_dart_test.dart`. Add at the end of the `main()` function:

```dart
  group('push', () {
    late MockClient mockClient;
    late CastBrick castbrick;

    setUp(() {
      mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/push/tokens') && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'token': 'cb_push_test.sig',
              'expiresAt': '2099-01-01T00:00:00Z',
              'channels': ['orders'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/push/publish') && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'messageId': 'msg-123',
              'delivered': 3,
              'creditsUsed': 1,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      });

      castbrick = CastBrick(apiKey: 'test-key', httpClient: mockClient);
    });

    tearDown(() => castbrick.close());

    test('issueToken returns PushTokenResponse', () async {
      final response = await castbrick.push.issueToken(channels: ['orders']);
      expect(response.token, equals('cb_push_test.sig'));
      expect(response.channels, equals(['orders']));
    });

    test('publish returns PushPublishResponse', () async {
      final response = await castbrick.push.publish(
        channel: 'orders',
        event: 'order.created',
        data: {'orderId': 'abc'},
      );
      expect(response.messageId, equals('msg-123'));
      expect(response.delivered, equals(3));
      expect(response.creditsUsed, equals(1.0));
    });
  });
```

Make sure `import 'dart:convert';` is at the top if not already present.

- [ ] **Step 2: Run tests**

```bash
dart test
```
Expected: all tests pass.

- [ ] **Step 3: Bump version**

In `pubspec.yaml` change `version: 0.1.3` to `version: 0.2.0`.

- [ ] **Step 4: Update CHANGELOG**

In `CHANGELOG.md`, prepend:

```markdown
## 0.2.0

- Added `push` resource to `CastBrick` facade
- `push.issueToken()` — issue short-lived channel tokens
- `push.publish()` — publish events to channels
- `push.subscribe()` — open SSE subscription, returns `PushSubscription`
- New models: `PushEvent`, `PushTokenResponse`, `PushPublishResponse`
```

- [ ] **Step 5: Commit**

```bash
git add test/castbrick_dart_test.dart pubspec.yaml CHANGELOG.md
git commit -m "feat(push): tests, bump to v0.2.0, update CHANGELOG"
```
