import 'package:castbrick/castbrick.dart';

Future<void> main() async {
  final cb = CastBrick(apiKey: 'your_api_key_here');

  try {
    // Send an SMS
    final result = await cb.sms.send(
      to: ['+244923000000'],
      content: 'Hello from CastBrick!',
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
