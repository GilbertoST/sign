class UserStats {
  final int totalSigns;
  final int masteredSigns;
  final int totalAttempts;
  final double successRate;
  final int currentLevel;
  final int totalSessions;

  UserStats({
    required this.totalSigns,
    required this.masteredSigns,
    required this.totalAttempts,
    required this.successRate,
    required this.currentLevel,
    required this.totalSessions,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalSigns: json['total_signs'],
      masteredSigns: json['mastered_signs'],
      totalAttempts: json['total_attempts'],
      successRate: (json['success_rate'] as num).toDouble(),
      currentLevel: json['current_level'],
      totalSessions: json['total_sessions'],
    );
  }

  double get progressPercentage {
    if (totalSigns == 0) return 0.0;
    return (masteredSigns / totalSigns) * 100;
  }
}

