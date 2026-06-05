import 'client.dart';
import 'resources/sms.dart';
import 'resources/contacts.dart';
import 'resources/broadcasts.dart';
import 'push/push_resource.dart';

export 'models.dart';
export 'client.dart' show CastBrickApiError;

/// CastBrick SDK client.
class CastBrick {
  final CastBrickClient _client;

  /// SMS operations — send, list, get, cancel scheduled.
  late final SmsResource sms;

  /// Contacts and contact lists operations.
  late final ContactsResource contacts;

  /// Broadcast operations.
  late final BroadcastsResource broadcasts;

  /// Push channel operations — issue tokens, publish events, subscribe via SSE.
  late final PushResource push;

  CastBrick({
    required String apiKey,
    String baseUrl = 'https://api.castbrick.co/v1',
  }) : _client = CastBrickClient(apiKey: apiKey, baseUrl: baseUrl) {
    sms = SmsResource(_client);
    contacts = ContactsResource(_client);
    broadcasts = BroadcastsResource(_client);
    push = PushResource(_client);
  }

  void close() => _client.close();
}
