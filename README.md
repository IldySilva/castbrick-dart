# castbrick_dart

Official Dart SDK for the [CastBrick](https://castbrick.com) API — send SMS, manage contacts and run broadcasts from any Dart or Flutter app.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  castbrick: ^0.1.0
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
print(result.status); // sent

cb.close();
```

## SMS

```dart
// Send
await cb.sms.send(
  to: ['+244923000000', '+244912000000'],
  content: 'Your OTP is 1234',
  senderId: 'MyApp',                                    // optional
  scheduledAt: DateTime.now().add(Duration(hours: 1)), // optional
);

// Get a single message
final msg = await cb.sms.get('message-id');
print(msg.status);

// List (paginated)
final page = await cb.sms.list(page: 1, pageSize: 20);
print('${page.totalCount} messages');

// Cancel a scheduled message
await cb.sms.cancelScheduled('message-id');
```

## Contacts

```dart
// List (with optional search)
final page = await cb.contacts.list(search: 'john');

// Get
final contact = await cb.contacts.get('contact-id');

// Create (comma or newline-separated values)
await cb.contacts.create(phoneNumbers: '+244923000000,+244912000000');
await cb.contacts.create(emails: 'alice@example.com');

// Delete
await cb.contacts.delete('contact-id');
```

### Contact lists

```dart
// List all
final lists = await cb.contacts.listLists();

// Create
final list = await cb.contacts.createList('VIP Customers');

// Add / remove a contact
await cb.contacts.addToList(list.id, contact.id);
await cb.contacts.removeFromList(list.id, contact.id);
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

## Error handling

All API errors throw a `CastBrickApiError`:

```dart
try {
  await cb.sms.send(to: ['+244923000000'], content: 'Hello!');
} on CastBrickApiError catch (e) {
  print('${e.status}: ${e.body}');
}
```

## Publishing to pub.dev

```bash
dart pub publish --dry-run  # validate first
dart pub publish
```

## License

MIT
