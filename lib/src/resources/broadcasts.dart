import '../client.dart';
import '../models.dart';

class BroadcastsResource {
  final CastBrickClient _client;

  BroadcastsResource(this._client);

  Future<PagedResult<Broadcast>> list({int page = 1, int pageSize = 20}) async {
    final raw = await _client.get<Map<String, dynamic>>(
      '/broadcasts',
      params: {'pageNumber': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(raw, Broadcast.fromJson);
  }

  Future<Broadcast> get(String id) async {
    final raw = await _client.get<Map<String, dynamic>>('/broadcasts/$id');
    return Broadcast.fromJson(raw);
  }

  Future<String> create({
    required String name,
    required String message,
    String? contactListId,
    String? senderId,
  }) async {
    return await _client.post<String>('/broadcasts', body: {
      'name': name,
      'message': message,
      if (contactListId != null) 'contactListId': contactListId,
      if (senderId != null) 'senderId': senderId,
    });
  }

  Future<String> update(
    String id, {
    required String name,
    required String message,
    String? contactListId,
    String? senderId,
    DateTime? scheduleAt,
  }) async {
    return await _client.put<String>('/broadcasts/$id', body: {
      'name': name,
      'message': message,
      if (contactListId != null) 'contactListId': contactListId,
      if (senderId != null) 'senderId': senderId,
      if (scheduleAt != null) 'scheduleAt': scheduleAt.toUtc().toIso8601String(),
    });
  }

  Future<void> send(String id) async {
    await _client.post<void>('/broadcasts/$id/send', body: {});
  }

  Future<void> cancel(String id) async {
    await _client.post<void>('/broadcasts/$id/cancel', body: {});
  }

  Future<String> duplicate(String id) async {
    return await _client.post<String>('/broadcasts/$id/duplicate', body: {});
  }

  Future<void> delete(String id) async {
    await _client.delete('/broadcasts/$id');
  }
}
