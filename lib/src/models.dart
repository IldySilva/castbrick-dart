class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemMapper,
  ) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map(itemMapper)
        .toList();

    return PagedResult(
      items: items,
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}

class SendSmsResponse {
  final String messageId;
  final String status;
  final int recipientCount;
  final String? error;
  final String timestamp;

  SendSmsResponse({
    required this.messageId,
    required this.status,
    required this.recipientCount,
    required this.error,
    required this.timestamp,
  });

  factory SendSmsResponse.fromJson(Map<String, dynamic> json) => SendSmsResponse(
    messageId: json['messageId'] as String,
    status: json['status'] as String,
    recipientCount: json['recipientCount'] as int,
    error: json['error'] as String?,
    timestamp: json['timestamp'] as String,
  );
}

class SmsMessage {
  final String id;
  final String phoneNumber;
  final String message;
  final String status;
  final String tenantId;
  final String? sentAt;
  final String? deliveredAt;
  final String createdAt;

  SmsMessage({
    required this.id,
    required this.phoneNumber,
    required this.message,
    required this.status,
    required this.tenantId,
    this.sentAt,
    this.deliveredAt,
    required this.createdAt,
  });

  factory SmsMessage.fromJson(Map<String, dynamic> json) => SmsMessage(
    id: json['id'] as String,
    phoneNumber: json['phoneNumber'] as String,
    message: json['message'] as String,
    status: json['status'] as String,
    tenantId: json['tenantId'] as String,
    sentAt: json['sentAt'] as String?,
    deliveredAt: json['deliveredAt'] as String?,
    createdAt: json['createdAt'] as String,
  );
}

class Contact {
  final String id;
  final String? name;
  final String? phoneNumber;
  final String? email;
  final String tenantId;
  final String createdAt;

  Contact({
    required this.id,
    this.name,
    this.phoneNumber,
    this.email,
    required this.tenantId,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'] as String,
    name: json['name'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    email: json['email'] as String?,
    tenantId: json['tenantId'] as String,
    createdAt: json['createdAt'] as String,
  );
}

class ContactList {
  final String id;
  final String name;
  final String tenantId;
  final int contactCount;
  final String createdAt;

  ContactList({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.contactCount,
    required this.createdAt,
  });

  factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
    id: json['id'] as String,
    name: json['name'] as String,
    tenantId: json['tenantId'] as String,
    contactCount: json['contactCount'] as int,
    createdAt: json['createdAt'] as String,
  );
}

class Broadcast {
  final String id;
  final String name;
  final String status;
  final String message;
  final String? senderId;
  final String? contactListId;
  final String? scheduledAt;
  final String createdAt;

  Broadcast({
    required this.id,
    required this.name,
    required this.status,
    required this.message,
    this.senderId,
    this.contactListId,
    this.scheduledAt,
    required this.createdAt,
  });

  factory Broadcast.fromJson(Map<String, dynamic> json) => Broadcast(
    id: json['id'] as String,
    name: json['name'] as String,
    status: json['status'] as String,
    message: json['message'] as String,
    senderId: json['senderId'] as String?,
    contactListId: json['contactListId'] as String?,
    scheduledAt: json['scheduledAt'] as String?,
    createdAt: json['createdAt'] as String,
  );
}
