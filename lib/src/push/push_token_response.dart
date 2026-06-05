class PushTokenResponse {
  final String token;
  final DateTime expiresAt;
  final List<String> channels;

  const PushTokenResponse({
    required this.token,
    required this.expiresAt,
    required this.channels,
  });

  factory PushTokenResponse.fromJson(Map<String, dynamic> json) =>
      PushTokenResponse(
        token: json['token'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        channels: List<String>.from(json['channels'] as List),
      );
}
