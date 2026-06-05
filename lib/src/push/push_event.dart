class PushEvent {
  final String channel;
  final String event;
  final dynamic data;
  final DateTime timestamp;

  const PushEvent({
    required this.channel,
    required this.event,
    required this.data,
    required this.timestamp,
  });

  factory PushEvent.fromJson(Map<String, dynamic> json) => PushEvent(
        channel: json['channel'] as String,
        event: json['event'] as String,
        data: json['data'],
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
