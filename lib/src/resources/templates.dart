import '../client.dart';
import '../models.dart';

class TemplatesResource {
  final CastBrickClient _client;

  TemplatesResource(this._client);

  Future<PagedResult<Template>> list({int page = 1, int pageSize = 20}) {
    return _client.get<Map<String, dynamic>>(
      '/templates',
      params: {'page': page, 'pageSize': pageSize},
    ).then((json) => PagedResult<Template>.fromJson(json, Template.fromJson));
  }

  Future<String> create({
    required String name,
    required String content,
    String? subject,
  }) {
    return _client.post<String>(
      '/templates',
      body: {
        'name': name,
        'content': content,
        if (subject != null) 'subject': subject,
      },
    );
  }

  Future<String> update(String id, {
    required String name,
    required String content,
    String? subject,
  }) {
    return _client.put<String>(
      '/templates/$id',
      body: {
        'name': name,
        'content': content,
        if (subject != null) 'subject': subject,
      },
    );
  }

  Future<void> delete(String id) {
    return _client.delete('/templates/$id');
  }
}
