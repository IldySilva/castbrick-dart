# castbrick

Official Dart SDK for the [CastBrick](https://castbrick.com) API — send SMS, manage contacts and run broadcasts from any Dart or Flutter app.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  castbrick: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Quick start

```dart
import 'package:castbrick/castbrick.dart';

final cb = CastBrick(apiKey: 'your_api_key_here');

// Send an SMS
final result = await cb.sms.send(
  to: ['+244923000000'],
  content: 'Hello from CastBrick!',
);
print(result.status);

cb.close();
```

## SMS

```dart
// Send
await cb.sms.send(
  to: ['+244923000000', '+244912000000'],
  content: 'Your OTP is 1234',
  senderId: 'MyApp',                                     // optional
  scheduledAt: DateTime.now().add(const Duration(hours: 1)), // optional
  fallback: true,                                        // optional
);

// List (with optional filters)
final page = await cb.sms.list(
  page: 1,
  pageSize: 20,
  status: 'delivered',       // pending | sent | delivered | failed | scheduled
  phone: '+244923000000',
  from: DateTime(2026, 1, 1),
  to: DateTime(2026, 6, 1),
);
print('${page.totalCount} messages');

// Cancel a scheduled SMS
await cb.sms.cancelScheduled('message-id');
```

## Contacts

```dart
// List (with optional search)
final page = await cb.contacts.list(search: 'john');

// Get
final contact = await cb.contacts.get('contact-id');

// Create — comma or newline-separated phone numbers
await cb.contacts.create(phoneNumbers: '+244923000000,+244912000000');

// Delete
await cb.contacts.delete('contact-id');
```

### Contact lists

```dart
// List all
final lists = await cb.contacts.listLists();

// Create — returns the new list ID (String)
final listId = await cb.contacts.createList('VIP Customers');

// Add / remove a contact
await cb.contacts.addToList(listId, contact.id);
await cb.contacts.removeFromList(listId, contact.id);
```

## Broadcasts

```dart
// Create
final id = await cb.broadcasts.create(
  name: 'Black Friday',
  message: '50% off everything today!',
  contactListId: 'list-id', // optional
  senderId: 'MyApp',        // optional
);

// Send immediately
await cb.broadcasts.send(id);

// Update (supports scheduling)
await cb.broadcasts.update(
  id,
  name: 'Black Friday',
  message: '50% off everything today!',
  scheduleAt: DateTime(2026, 11, 28, 9, 0),
);

// Other operations
await cb.broadcasts.cancel(id);
final newId = await cb.broadcasts.duplicate(id);
await cb.broadcasts.delete(id);

// List / get
final page = await cb.broadcasts.list();
final broadcast = await cb.broadcasts.get(id);
print(broadcast.status);
```

## Push (Realtime pub/sub)

CastBrick Push lets you deliver realtime events to Flutter/Dart clients via SSE channels.

### Server-side: issue token + publish

```dart
// Issue a short-lived channel token for the client
final tokenResponse = await cb.push.issueToken(
  channels: ['orders', 'user-42'],
  userId: 'user-123',  // optional
  ttlSeconds: 3600,    // optional, default 3600
);

// Publish an event to a channel
final result = await cb.push.publish(
  channel: 'orders',
  event: 'order.created',
  data: {'orderId': 'abc123', 'total': 5000},
);

print('${result.delivered} delivered, ${result.creditsUsed} credits');
```

### Client-side: subscribe to channels

```dart
// token comes from your backend (via issueToken above)
final subscription = cb.push.subscribe(token: tokenResponse.token);

// Listen to events on a specific channel
subscription.on('orders').listen((PushEvent event) {
  print('${event.event}: ${event.data}');
});

// Listen to another channel on the same connection
subscription.on('user-42').listen((PushEvent event) {
  print(event.data);
});

// Close when done
subscription.dispose();
```

The subscription auto-reconnects on network loss with exponential backoff (1s → 30s) and replays missed events using `Last-Event-ID`.

---

## Error handling

All API errors throw a `CastBrickApiError`:

```dart
try {
  await cb.sms.send(to: ['+244923000000'], content: 'Hello!');
} on CastBrickApiError catch (e) {
  print('${e.status}: ${e.body}');
  // 401 → invalid or revoked API key
  // 402 → insufficient credits
  // 422 → validation error
}
```

## License

MIT
