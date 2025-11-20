class User {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final int level;
  final bool isGuest;
  final int guestLessonsCount;
  final int guestQuizCount;
  final String? profilePictureUrl;
  final String? bio;
  final bool gdprConsent;
  final DateTime? gdprConsentAt;
  final bool dataProcessingConsent;
  final DateTime? dataProcessingConsentAt;
  final int xp;
  final int totalXp;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.level,
    this.isGuest = false,
    this.guestLessonsCount = 0,
    this.guestQuizCount = 0,
    this.profilePictureUrl,
    this.bio,
    this.gdprConsent = false,
    this.gdprConsentAt,
    this.dataProcessingConsent = false,
    this.dataProcessingConsentAt,
    this.xp = 0,
    this.totalXp = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      level: json['level'],
      isGuest: json['is_guest'] ?? false,
      guestLessonsCount: json['guest_lessons_count'] ?? 0,
      guestQuizCount: json['guest_quiz_count'] ?? 0,
      profilePictureUrl: json['profile_picture_url'],
      bio: json['bio'],
      gdprConsent: json['gdpr_consent'] ?? true,
      gdprConsentAt: json['gdpr_consent_at'] != null
          ? DateTime.tryParse(json['gdpr_consent_at'])
          : null,
      dataProcessingConsent: json['data_processing_consent'] ?? true,
      dataProcessingConsentAt: json['data_processing_consent_at'] != null
          ? DateTime.tryParse(json['data_processing_consent_at'])
          : null,
      xp: json['xp'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'level': level,
      'is_guest': isGuest,
      'guest_lessons_count': guestLessonsCount,
      'guest_quiz_count': guestQuizCount,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'gdpr_consent': gdprConsent,
      'gdpr_consent_at': gdprConsentAt?.toIso8601String(),
      'data_processing_consent': dataProcessingConsent,
      'data_processing_consent_at': dataProcessingConsentAt?.toIso8601String(),
      'xp': xp,
      'total_xp': totalXp,
    };
  }
}
