import 'client.dart';
import 'resources/sms.dart';
import 'resources/contacts.dart';
import 'resources/broadcasts.dart';
import 'resources/billing.dart';
import 'resources/segments.dart';
import 'resources/templates.dart';
import 'resources/webhooks.dart';
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

  /// Billing operations.
  late final BillingResource billing;

  /// Segments operations.
  late final SegmentsResource segments;

  /// Templates operations.
  late final TemplatesResource templates;

  /// Webhooks operations.
  late final WebhooksResource webhooks;

  /// Push channel operations — issue tokens, publish events, subscribe via SSE.
  late final PushResource push;

  CastBrick({
    required String apiKey,
    String baseUrl = 'https://api.castbrick.co/v1',
  }) : _client = CastBrickClient(apiKey: apiKey, baseUrl: baseUrl) {
    sms = SmsResource(_client);
    contacts = ContactsResource(_client);
    broadcasts = BroadcastsResource(_client);
    billing = BillingResource(_client);
    segments = SegmentsResource(_client);
    templates = TemplatesResource(_client);
    webhooks = WebhooksResource(_client);
    push = PushResource(_client);
  }

  void close() => _client.close();
}
