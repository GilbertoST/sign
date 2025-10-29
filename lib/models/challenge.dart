class Challenge {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String challengeType;
  final int requirement;
  final int xpReward;
  final String color;
  final bool isSeasonal;
  final DateTime? startDate;
  final DateTime? endDate;
  final int progress;
  final bool completed;
  final DateTime? completedAt;
  final int xpEarned;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.challengeType,
    required this.requirement,
    required this.xpReward,
    required this.color,
    this.isSeasonal = false,
    this.startDate,
    this.endDate,
    this.progress = 0,
    this.completed = false,
    this.completedAt,
    this.xpEarned = 0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      challengeType: json['challenge_type'],
      requirement: json['requirement'],
      xpReward: json['xp_reward'],
      color: json['color'] ?? 'blue',
      isSeasonal: json['is_seasonal'] ?? false,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      progress: json['progress'] ?? 0,
      completed: json['completed'] ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      xpEarned: json['xp_earned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'challenge_type': challengeType,
      'requirement': requirement,
      'xp_reward': xpReward,
      'color': color,
      'is_seasonal': isSeasonal,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'progress': progress,
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'xp_earned': xpEarned,
    };
  }

  double get progressPercentage {
    if (requirement == 0) return 0.0;
    return (progress / requirement).clamp(0.0, 1.0);
  }

  bool get isActive {
    if (!isSeasonal) return true;
    
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    
    return true;
  }

  Challenge copyWith({
    int? id,
    String? title,
    String? description,
    String? icon,
    String? challengeType,
    int? requirement,
    int? xpReward,
    String? color,
    bool? isSeasonal,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
    bool? completed,
    DateTime? completedAt,
    int? xpEarned,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      challengeType: challengeType ?? this.challengeType,
      requirement: requirement ?? this.requirement,
      xpReward: xpReward ?? this.xpReward,
      color: color ?? this.color,
      isSeasonal: isSeasonal ?? this.isSeasonal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, progress: $progress/$requirement, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}




