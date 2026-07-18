import '../client.dart';
import '../models.dart';

class WebhooksResource {
  final CastBrickClient _client;

  WebhooksResource(this._client);

  Future<PagedResult<Webhook>> list({int page = 1, int pageSize = 10}) {
    return _client.get<Map<String, dynamic>>(
      '/webhooks',
      params: {'pageNumber': page, 'pageSize': pageSize},
    ).then((json) => PagedResult<Webhook>.fromJson(json, Webhook.fromJson));
  }

  Future<Webhook> get(String id) {
    return _client.get<Map<String, dynamic>>('/webhooks/$id')
        .then(Webhook.fromJson);
  }

  Future<String> create({
    required String endpoint,
    required String eventType,
  }) {
    return _client.post<String>(
      '/webhooks',
      body: {
        'endpoint': endpoint,
        'eventType': eventType,
      },
    );
  }

  Future<void> toggle(String id) {
    return _client.put<void>('/webhooks/$id/toggle', body: {});
  }

  Future<void> test(String webhookId, String payload) {
    return _client.post<void>(
      '/webhooks/test',
      body: {
        'webhookId': webhookId,
        'payload': payload,
      },
    );
  }

  Future<List<WebhookLog>> listLogs(String id, {int limit = 50}) {
    return _client.get<List<dynamic>>(
      '/webhooks/$id/logs',
      params: {'limit': limit},
    ).then((list) => list.map((e) => WebhookLog.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<void> retry(String logId) {
    return _client.post<void>('/webhooks/logs/$logId/retry', body: {});
  }

  Future<void> delete(String id) {
    return _client.delete('/webhooks/$id');
  }
}
