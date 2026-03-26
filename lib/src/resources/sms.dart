import '../client.dart';
import '../models.dart';

class SmsResource {
  final CastBrickClient _client;

  SmsResource(this._client);

  Future<SendSmsResponse> send({
    required List<String> to,
    required String content,
    String? senderId,
    DateTime? scheduledAt,
    String? contactListId,
  }) async {
    final raw = await _client.post<Map<String, dynamic>>(
      '/sms/send',
      body: {
        'recipients': to,
        'content': content,
        if (senderId != null) 'senderId': senderId,
        if (scheduledAt != null)
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        if (contactListId != null) 'contactListId': contactListId,
      },
    );
    return SendSmsResponse.fromJson(raw);
  }

  Future<PagedResult<SmsMessage>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    final raw = await _client.get<Map<String, dynamic>>(
      '/sms',
      params: {'pageNumber': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(raw, SmsMessage.fromJson);
  }

  Future<void> cancelScheduled(String messageId) async {
    await _client.post<void>(
      '/sms/cancel-scheduled',
      body: {'messageId': messageId},
    );
  }
}
