class LearningSession {
  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime? endTime;
  final double score;

  LearningSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.score,
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'],
      userId: json['user_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'score': score,
    };
  }

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }
}

