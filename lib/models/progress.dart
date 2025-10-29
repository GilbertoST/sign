class Progress {
  final int id;
  final int userId;
  final int signId;
  final bool mastered;
  final int attempts;
  final DateTime? lastPracticeDate;

  Progress({
    required this.id,
    required this.userId,
    required this.signId,
    required this.mastered,
    required this.attempts,
    this.lastPracticeDate,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['user_id'],
      signId: json['sign_id'],
      mastered: json['mastered'],
      attempts: json['attempts'],
      lastPracticeDate: json['last_practice_date'] != null
          ? DateTime.parse(json['last_practice_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sign_id': signId,
      'mastered': mastered,
      'attempts': attempts,
      'last_practice_date': lastPracticeDate?.toIso8601String(),
    };
  }
}

