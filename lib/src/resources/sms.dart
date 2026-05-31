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
    bool? fallback,
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
        if (fallback != null) 'fallback': fallback,
      },
    );
    return SendSmsResponse.fromJson(raw);
  }

  Future<PagedResult<SmsMessage>> list({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? phone,
    DateTime? from,
    DateTime? to,
  }) async {
    final raw = await _client.get<Map<String, dynamic>>(
      '/sms',
      params: {
        'pageNumber': page,
        'pageSize': pageSize,
        if (status != null) 'status': status,
        if (phone != null) 'phone': phone,
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    return PagedResult.fromJson(raw, SmsMessage.fromJson);
  }

  /// Cancel a scheduled SMS by its ID.
  Future<void> cancelScheduled(String messageId) async {
    await _client.delete('/sms/$messageId');
  }
}
