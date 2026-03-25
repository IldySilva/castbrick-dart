import '../client.dart';
import '../models.dart';

class ContactsResource {
  final CastBrickClient _client;

  ContactsResource(this._client);

  Future<PagedResult<Contact>> list({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final raw = await _client.get<Map<String, dynamic>>(
      '/audience/contacts',
      params: {
        'pageNumber': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return PagedResult.fromJson(raw, Contact.fromJson);
  }

  Future<Contact> get(String id) async {
    final raw = await _client.get<Map<String, dynamic>>('/audience/contacts/$id');
    return Contact.fromJson(raw);
  }

  Future<int> create({String? emails, String? phoneNumbers}) async {
    return await _client.post<int>('/audience/contacts', body: {
      if (emails != null) 'emails': emails,
      if (phoneNumbers != null) 'phoneNumbers': phoneNumbers,
    });
  }

  Future<void> delete(String id) async {
    await _client.delete('/audience/contacts/$id');
  }

  Future<PagedResult<ContactList>> listLists({
    int page = 1,
    int pageSize = 20,
  }) async {
    final raw = await _client.get<Map<String, dynamic>>(
      '/audience/lists',
      params: {'pageNumber': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(raw, ContactList.fromJson);
  }

  Future<ContactList> getList(String id) async {
    final raw = await _client.get<Map<String, dynamic>>('/audience/lists/$id');
    return ContactList.fromJson(raw);
  }

  Future<ContactList> createList(String name) async {
    final raw = await _client.post<Map<String, dynamic>>(
      '/audience/lists',
      body: {'name': name},
    );
    return ContactList.fromJson(raw);
  }

  Future<void> addToList(String listId, String contactId) async {
    await _client.post<void>(
      '/audience/lists/$listId/contacts',
      body: {'contactId': contactId},
    );
  }

  Future<void> removeFromList(String listId, String contactId) async {
    await _client.delete('/audience/lists/$listId/contacts/$contactId');
  }
}
