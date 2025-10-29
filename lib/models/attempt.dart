class Attempt {
  final int id;
  final int sessionId;
  final int signId;
  final bool success;
  final DateTime timestamp;

  Attempt({
    required this.id,
    required this.sessionId,
    required this.signId,
    required this.success,
    required this.timestamp,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      id: json['id'],
      sessionId: json['session_id'],
      signId: json['sign_id'],
      success: json['success'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'sign_id': signId,
      'success': success,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

