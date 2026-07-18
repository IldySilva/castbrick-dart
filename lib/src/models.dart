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

  factory SendSmsResponse.fromJson(Map<String, dynamic> json) =>
      SendSmsResponse(
        messageId: json['messageId'] as String,
        status: json['status'] as String,
        recipientCount: json['recipientCount'] as int,
        error: json['error'] as String?,
        timestamp: json['timestamp'] as String,
      );
}

class SmsMessage {
  final String id;
  final String? contactName;
  final String recipientPhone;
  final String message;
  final String? campaignName;
  final String? campaignId;
  final String? senderId;
  final String status;
  final String? errorMessage;
  final int retryCount;
  final String? scheduledAt;
  final String? sentAt;
  final String? deliveredAt;

  SmsMessage({
    required this.id,
    this.contactName,
    required this.recipientPhone,
    required this.message,
    this.campaignName,
    this.campaignId,
    this.senderId,
    required this.status,
    this.errorMessage,
    required this.retryCount,
    this.scheduledAt,
    this.sentAt,
    this.deliveredAt,
  });

  factory SmsMessage.fromJson(Map<String, dynamic> json) => SmsMessage(
    id: json['id'] as String,
    contactName: json['contactName'] as String?,
    recipientPhone: json['recipientPhone'] as String,
    message: json['message'] as String,
    campaignName: json['campaignName'] as String?,
    campaignId: json['campaignId'] as String?,
    senderId: json['senderId'] as String?,
    status: json['status'] as String,
    errorMessage: json['errorMessage'] as String?,
    retryCount: json['retryCount'] as int,
    scheduledAt: json['scheduledAt'] as String?,
    sentAt: json['sentAt'] as String?,
    deliveredAt: json['deliveredAt'] as String?,
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

class Template {
  final String id;
  final String name;
  final String content;
  final String? subject;
  final String createdAt;

  Template({
    required this.id,
    required this.name,
    required this.content,
    this.subject,
    required this.createdAt,
  });

  factory Template.fromJson(Map<String, dynamic> json) => Template(
    id: json['id'] as String,
    name: json['name'] as String,
    content: json['content'] as String,
    subject: json['subject'] as String?,
    createdAt: json['createdAt'] as String,
  );
}

class Webhook {
  final String id;
  final String endpoint;
  final String eventType;
  final bool isActive;
  final String createdAt;

  Webhook({
    required this.id,
    required this.endpoint,
    required this.eventType,
    required this.isActive,
    required this.createdAt,
  });

  factory Webhook.fromJson(Map<String, dynamic> json) => Webhook(
    id: json['id'] as String,
    endpoint: json['endpoint'] as String,
    eventType: json['eventType'] as String,
    isActive: json['isActive'] as bool,
    createdAt: json['createdAt'] as String,
  );
}

class WebhookLog {
  final String id;
  final String webhookId;
  final String eventType;
  final int statusCode;
  final int attempt;
  final String deliveredAt;

  WebhookLog({
    required this.id,
    required this.webhookId,
    required this.eventType,
    required this.statusCode,
    required this.attempt,
    required this.deliveredAt,
  });

  factory WebhookLog.fromJson(Map<String, dynamic> json) => WebhookLog(
    id: json['id'] as String,
    webhookId: json['webhookId'] as String,
    eventType: json['eventType'] as String,
    statusCode: json['statusCode'] as int,
    attempt: json['attempt'] as int,
    deliveredAt: json['deliveredAt'] as String,
  );
}

class Segment {
  final String id;
  final String name;
  final String? description;
  final String? rulesOperator;
  final int contactCount;
  final String createdAt;

  Segment({
    required this.id,
    required this.name,
    this.description,
    this.rulesOperator,
    required this.contactCount,
    required this.createdAt,
  });

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    rulesOperator: json['rulesOperator'] as String?,
    contactCount: json['contactCount'] as int,
    createdAt: json['createdAt'] as String,
  );
}

class BillingBalance {
  final num balance;
  final num lowBalanceThreshold;
  final String alertEmail;
  final String? lastAlertSentAt;

  BillingBalance({
    required this.balance,
    required this.lowBalanceThreshold,
    required this.alertEmail,
    this.lastAlertSentAt,
  });

  factory BillingBalance.fromJson(Map<String, dynamic> json) => BillingBalance(
    balance: json['balance'] as num,
    lowBalanceThreshold: json['lowBalanceThreshold'] as num,
    alertEmail: json['alertEmail'] as String,
    lastAlertSentAt: json['lastAlertSentAt'] as String?,
  );
}

class CreditPack {
  final String id;
  final String name;
  final num credits;
  final num price;
  final String currency;
  final num pricePerSms;

  CreditPack({
    required this.id,
    required this.name,
    required this.credits,
    required this.price,
    required this.currency,
    required this.pricePerSms,
  });

  factory CreditPack.fromJson(Map<String, dynamic> json) => CreditPack(
    id: json['id'] as String,
    name: json['name'] as String,
    credits: json['credits'] as num,
    price: json['price'] as num,
    currency: json['currency'] as String,
    pricePerSms: json['pricePerSms'] as num,
  );
}

class InitiatePaymentResponse {
  final String paymentUrl;
  final String providerRef;
  final String paymentId;

  InitiatePaymentResponse({
    required this.paymentUrl,
    required this.providerRef,
    required this.paymentId,
  });

  factory InitiatePaymentResponse.fromJson(Map<String, dynamic> json) => InitiatePaymentResponse(
    paymentUrl: json['paymentUrl'] as String,
    providerRef: json['providerRef'] as String,
    paymentId: json['paymentId'] as String,
  );
}

class PaymentInfo {
  final String id;
  final num amount;
  final String currency;
  final String status;
  final String providerRef;
  final num creditsGranted;
  final String createdAt;

  PaymentInfo({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.providerRef,
    required this.creditsGranted,
    required this.createdAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
    id: json['id'] as String,
    amount: json['amount'] as num,
    currency: json['currency'] as String,
    status: json['status'] as String,
    providerRef: json['providerRef'] as String,
    creditsGranted: json['creditsGranted'] as num,
    createdAt: json['createdAt'] as String,
  );
}

class CreditLedgerEntry {
  final String id;
  final num amount;
  final String type;
  final String description;
  final String createdAt;

  CreditLedgerEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory CreditLedgerEntry.fromJson(Map<String, dynamic> json) => CreditLedgerEntry(
    id: json['id'] as String,
    amount: json['amount'] as num,
    type: json['type'] as String,
    description: json['description'] as String,
    createdAt: json['createdAt'] as String,
  );
}

class PaginatedCursorResult<T> {
  final List<T> items;
  final String? nextCursor;

  PaginatedCursorResult({
    required this.items,
    this.nextCursor,
  });

  factory PaginatedCursorResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemMapper,
  ) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map(itemMapper)
        .toList();

    return PaginatedCursorResult(
      items: items,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}
