import 'package:castbrick/castbrick.dart';

void main() async {
  final cb = CastBrick(apiKey: 'your-api-key');

  try {
    final result = await cb.sms.send(
      to: ['24493000000'],
      content: 'Hello from CastBrick!',
    );
    print('Enviado: ${result.messageId} — ${result.status}');

    final page = await cb.sms.list(pageSize: 5);
    print('Total SMS: ${page.totalCount}');
    for (final msg in page.items) {
      print('  ${msg.id} | ${msg.status} | ${msg.recipientPhone}');
    }
  } on CastBrickApiError catch (e) {
    print('Erro API ${e.status}: ${e.body}');
  } finally {
    cb.close();
  }
}
