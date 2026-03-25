import 'package:castbrick/castbrick.dart';

Future<void> main() async {
  final cb = CastBrick(apiKey: '3ab725d34ff74ec9997f26ec81677287');

  try {
    // Send an SMS
    final result = await cb.sms.send(
      to: ['+244923000000'],
      content: 'Hello from CastBrick!',
      senderId: "CastBrick",
    );
    print('Sent: ${result.messageId} — ${result.status}');

    // List contacts
    final contacts = await cb.contacts.list(pageSize: 10);
    print('Contacts: ${contacts.totalCount}');

    // Create and send a broadcast
    final id = await cb.broadcasts.create(
      name: 'Promo',
      message: '50% off today!',
    );
    await cb.broadcasts.send(id);
    print('Broadcast sent: $id');
  } on CastBrickApiError catch (e) {
    print('API error ${e.status}: ${e.body}');
  } finally {
    cb.close();
  }
}
