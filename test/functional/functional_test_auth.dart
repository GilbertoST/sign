import 'package:flutter_test/flutter_test.dart';
import 'package:sign/models/user.dart';
import 'package:sign/services/api_service.dart';

void main() {
  group('Tests fonctionnels - Authentification', () {

    test('Test : Désérialisation User depuis JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'created_at': '2024-01-01T00:00:00.000Z',
        'level': 5,
        'is_guest': false,
        'guest_lessons_count': 0,
        'guest_quiz_count': 0,
        'profile_picture_url': 'https://example.com/avatar.jpg',
        'bio': 'Ma bio de test',
        'gdpr_consent': true,
        'gdpr_consent_at': '2024-01-01T00:00:00.000Z',
        'data_processing_consent': true,
        'data_processing_consent_at': '2024-01-01T00:00:00.000Z',
        'xp': 250,
        'total_xp': 500,
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals(1));
      expect(user.username, equals('testuser'));
      expect(user.email, equals('test@example.com'));
      expect(user.level, equals(5));
      expect(user.gdprConsent, isTrue);
      expect(user.gdprConsentAt, isNotNull);
      expect(user.dataProcessingConsent, isTrue);
      expect(user.xp, equals(250));
      expect(user.totalXp, equals(500));
      expect(user.bio, equals('Ma bio de test'));
    });

    test('Test : Sérialisation User vers JSON', () {
      // Arrange
      final user = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        level: 5,
        gdprConsent: true,
        gdprConsentAt: DateTime(2024, 1, 1),
        dataProcessingConsent: true,
        dataProcessingConsentAt: DateTime(2024, 1, 1),
        xp: 250,
        totalXp: 500,
        bio: 'Ma bio de test',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals(1));
      expect(json['username'], equals('testuser'));
      expect(json['email'], equals('test@example.com'));
      expect(json['level'], equals(5));
      expect(json['gdpr_consent'], isTrue);
      expect(json['gdpr_consent_at'], isNotNull);
      expect(json['xp'], equals(250));
      expect(json['total_xp'], equals(500));
      expect(json['bio'], equals('Ma bio de test'));
    });

    test('Test : User avec valeurs par défaut', () {
      // Arrange & Act
      final user = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        level: 1,
      );

      // Assert
      expect(user.isGuest, isFalse);
      expect(user.guestLessonsCount, equals(0));
      expect(user.gdprConsent, isFalse);
      expect(user.dataProcessingConsent, isFalse);
      expect(user.xp, equals(0));
      expect(user.totalXp, equals(0));
    });

    test('Test : User invité', () {
      // Arrange & Act
      final user = User(
        id: 1,
        username: 'guest_abc123',
        email: 'guest_abc123@example.com',
        createdAt: DateTime.now(),
        level: 1,
        isGuest: true,
        guestLessonsCount: 3,
        guestQuizCount: 2,
      );

      // Assert
      expect(user.isGuest, isTrue);
      expect(user.guestLessonsCount, equals(3));
      expect(user.guestQuizCount, equals(2));
    });

    test('Test : ApiService token management', () {
      // Arrange
      final apiService = ApiService();
      
      // Act & Assert - Token initialement null
      expect(apiService.token, isNull);
      
      // Act - Définir un token
      apiService.setToken('test_token_123');
      expect(apiService.token, equals('test_token_123'));
      
      // Act - Nettoyer le token
      apiService.clearToken();
      expect(apiService.token, isNull);
    });
  });
}

