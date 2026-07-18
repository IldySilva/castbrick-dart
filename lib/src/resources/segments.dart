import '../client.dart';
import '../models.dart';

class SegmentsResource {
  final CastBrickClient _client;

  SegmentsResource(this._client);

  Future<PagedResult<Segment>> list({
    int page = 1,
    int pageSize = 50,
    String? search,
  }) {
    final params = <String, dynamic>{
      'pageNumber': page,
      'pageSize': pageSize,
      if (search != null) 'search': search,
    };
    return _client.get<Map<String, dynamic>>(
      '/audience/segments',
      params: params,
    ).then((json) => PagedResult<Segment>.fromJson(json, Segment.fromJson));
  }

  Future<String> create({
    required String name,
    String? description,
    String? rulesOperator,
    String? rules,
  }) {
    return _client.post<String>(
      '/audience/segments',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (rulesOperator != null) 'rulesOperator': rulesOperator,
        if (rules != null) 'rules': rules,
      },
    );
  }

  Future<void> update(String id, {
    required String name,
    String? description,
    String? rulesOperator,
    String? rules,
  }) {
    return _client.put<void>(
      '/audience/segments/$id',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (rulesOperator != null) 'rulesOperator': rulesOperator,
        if (rules != null) 'rules': rules,
      },
    );
  }

  Future<void> delete(String id) {
    return _client.delete('/audience/segments/$id');
  }
}
