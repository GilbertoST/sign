import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/sign.dart';
import '../models/progress.dart';
import '../models/learning_session.dart';
import '../models/attempt.dart';
import '../models/user_stats.dart';
import '../models/challenge.dart';

class ApiService {
  // Changez cette URL selon votre configuration
  // Pour iOS Simulator: http://localhost:8000
  // Pour Android Emulator: http://10.0.2.2:8000
  // Pour device physique: http://VOTRE_IP:8000
  static const String baseUrl = ApiConfig.baseUrl;

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  String? get token => _token;

  void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  bool _handleAuthError(http.Response response) {
    if (response.statusCode == 401) {
      // Token expiré ou invalide - déconnecter l'utilisateur
      clearToken();
      return true;
    }
    return false;
  }

  // ==================== AUTHENTIFICATION ====================

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  Future<String> login(String username, String password) async {
    debugPrint('POST $baseUrl/api/auth/login');
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    debugPrint('login status: ${response.statusCode} body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return _token!;
    } else {
      throw Exception('Échec de la connexion: ${response.body}');
    }
  }

  Future<User> getCurrentUser() async {
    debugPrint('GET $baseUrl/api/auth/me');
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: _getHeaders(includeAuth: true),
    );

    debugPrint('me status: ${response.statusCode} body: ${response.body}');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (_handleAuthError(response)) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw Exception('Échec de récupération de l\'utilisateur');
    }
  }

  // ==================== SIGNES ====================

  Future<List<Sign>> getSigns() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/signs'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sign.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération des signes');
    }
  }

  Future<Sign> getSign(int signId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/signs/$signId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Sign.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de récupération du signe');
    }
  }

  // ==================== PROGRESSION ====================

  Future<List<Progress>> getUserProgress(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/progress'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Progress.fromJson(json)).toList();
    } else {
      throw Exception('Échec de récupération de la progression');
    }
  }

  Future<Progress> createProgress(
      int userId, int signId, bool mastered, int attempts) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/progress'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode({
        'user_id': userId,
        'sign_id': signId,
        'mastered': mastered,
        'attempts': attempts,
      }),
    );

    if (response.statusCode == 201) {
      return Progress.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de création de la progression');
    }
  }

  Future<Progress> updateProgress(
    int progressId, {
    bool? mastered,
    int? attempts,
    DateTime? lastPracticeDate,
  }) async {
    final body = <String, dynamic>{};
    if (mastered != null) body['mastered'] = mastered;
    if (attempts != null) body['attempts'] = attempts;
    if (lastPracticeDate != null) {
      body['last_practice_date'] = lastPracticeDate.toIso8601String();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/progress/$progressId'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Progress.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de mise à jour de la progression');
    }
  }

  // ==================== SESSIONS ====================

  Future<LearningSession> createSession(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/sessions'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 201) {
      return LearningSession.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de création de la session');
    }
  }

  Future<LearningSession> updateSession(
    int sessionId, {
    DateTime? endTime,
    double? score,
  }) async {
    final body = <String, dynamic>{};
    if (endTime != null) body['end_time'] = endTime.toIso8601String();
    if (score != null) body['score'] = score;

    final response = await http.put(
      Uri.parse('$baseUrl/api/sessions/$sessionId'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return LearningSession.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de mise à jour de la session');
    }
  }

  // ==================== TENTATIVES ====================

  Future<Attempt> createAttempt(
      int sessionId, int signId, bool success) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/attempts'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode({
        'session_id': sessionId,
        'sign_id': signId,
        'success': success,
      }),
    );

    if (response.statusCode == 201) {
      return Attempt.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec d\'enregistrement de la tentative');
    }
  }

  // ==================== STATISTIQUES ====================

  Future<UserStats> getUserStats(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/stats'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de récupération des statistiques');
    }
  }

  // ==================== MODE INVITÉ ====================

  Future<String> loginAsGuest() async {
    debugPrint('POST $baseUrl/api/auth/guest');
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/guest'),
      headers: _getHeaders(),
    );

    debugPrint('guest status: ${response.statusCode} body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      return _token!;
    } else {
      throw Exception('Échec de connexion invité');
    }
  }

  Future<Map<String, dynamic>> incrementGuestLesson() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/increment-guest-lesson'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec d\'incrémentation de leçon');
    }
  }

  Future<Map<String, dynamic>> incrementGuestQuiz() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/increment-guest-quiz'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec d\'incrémentation de quiz');
    }
  }

  Future<void> convertGuestToUser(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/convert-guest'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Erreur de conversion');
    }
  }

  // ==================== PROFIL ====================

  Future<User> updateUserProfile(
    int userId, {
    String? username,
    String? email,
    String? bio,
    String? profilePictureUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (bio != null) body['bio'] = bio;
    if (profilePictureUrl != null) body['profile_picture_url'] = profilePictureUrl;

    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de mise à jour du profil');
    }
  }

  Future<void> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/change-password'),
      headers: _getHeaders(includeAuth: true),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Erreur de changement de mot de passe');
    }
  }

  // ==================== RGPD ====================

  Future<Map<String, dynamic>> exportUserData(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/export'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec export données');
    }
  }

  Future<void> deleteUserAccount(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec suppression compte');
    }
  }

  // ==================== DÉFIS ====================

  Future<List<Challenge>> getChallenges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/challenges'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else if (_handleAuthError(response)) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw Exception('Échec chargement défis');
    }
  }

  Future<Map<String, dynamic>> completeChallenge(int challengeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/challenges/$challengeId/complete'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec complétion défi');
    }
  }

  Future<Map<String, dynamic>> updateChallengeProgress(int challengeId, {int increment = 1}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/challenges/$challengeId/progress?increment=$increment'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec mise à jour progression');
    }
  }

  Future<Map<String, dynamic>> updateChallengeProgressByType(String challengeType, {int increment = 1}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/challenges/by-type/$challengeType/progress?increment=$increment'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec mise à jour progression');
    }
  }

  Future<Map<String, dynamic>> addXP(int userId, int xpAmount, {String actionType = 'general'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/add-xp?xp_amount=$xpAmount&action_type=$actionType'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec ajout XP');
    }
  }

  // ==================== FAVORIS ====================

  Future<void> addFavorite(int signId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites?sign_id=$signId'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec ajout favori');
    }
  }

  Future<void> removeFavorite(int signId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/favorites/$signId'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Échec suppression favori');
    }
  }

  Future<bool> isFavorite(int signId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/favorites/$signId/check'),
      headers: _getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_favorite'] ?? false;
    } else {
      return false;
    }
  }
}

