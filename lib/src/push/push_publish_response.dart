class PushPublishResponse {
  final String messageId;
  final int delivered;
  final double creditsUsed;

  const PushPublishResponse({
    required this.messageId,
    required this.delivered,
    required this.creditsUsed,
  });

  factory PushPublishResponse.fromJson(Map<String, dynamic> json) =>
      PushPublishResponse(
        messageId: json['messageId'] as String,
        delivered: json['delivered'] as int,
        creditsUsed: (json['creditsUsed'] as num).toDouble(),
      );
}
