import 'package:castbrick/castbrick.dart';
import 'package:test/test.dart';

void main() {
  test('CastBrick client can be constructed', () {
    final cb = CastBrick(apiKey: 'test_api_key');
    expect(cb, isNotNull);
    cb.close();
  });

  test('CastBrick exposes sms, contacts, and broadcasts resources', () {
    final cb = CastBrick(apiKey: 'test_api_key');
    expect(cb.sms, isNotNull);
    expect(cb.contacts, isNotNull);
    expect(cb.broadcasts, isNotNull);
    cb.close();
  });
}
