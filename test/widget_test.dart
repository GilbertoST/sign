import 'package:flutter_test/flutter_test.dart';
import 'package:sign/models/sign.dart';
import 'package:sign/models/user.dart';

void main() {
  test('Sign.fromJson parses a letter', () {
    final sign = Sign.fromJson({
      'id': 1,
      'letter': 'A',
      'difficulty': 1,
    });
    expect(sign.letter, 'A');
    expect(sign.difficultyLabel, 'Facile');
  });

  test('User.fromJson uses defaults for optional fields', () {
    final user = User.fromJson({
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'created_at': '2024-01-01T00:00:00.000Z',
      'level': 1,
    });
    expect(user.username, 'testuser');
    expect(user.isGuest, isFalse);
    expect(user.xp, 0);
  });
}
