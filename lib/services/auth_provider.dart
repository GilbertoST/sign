import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isGuest => _currentUser?.isGuest ?? false;
  ApiService get apiService => _apiService;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      // Log l'URL courante pour debug
      debugPrint('API baseUrl: ${ApiConfig.baseUrl}');

      // Forcer un reset de token au tout premier démarrage après installation
      final didBootstrapOnce = prefs.getBool('did_bootstrap_once') ?? false;
      if (!didBootstrapOnce) {
        await prefs.remove('auth_token');
        await prefs.setBool('did_bootstrap_once', true);
      }
      // Invalider tout token si l'URL de l'API a changé (ex: localhost -> Render)
      final lastBaseUrl = prefs.getString('api_base_url');
      const currentBaseUrl = ApiConfig.baseUrl;
      if (lastBaseUrl != currentBaseUrl) {
        await prefs.remove('auth_token');
        await prefs.setString('api_base_url', currentBaseUrl);
      }
      final token = prefs.getString('auth_token');

      if (token != null) {
        _apiService.setToken(token);
        _currentUser = await _apiService.getCurrentUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Erreur de chargement du token: $e');
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.login(username, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('api_base_url', ApiConfig.baseUrl);

      _currentUser = await _apiService.getCurrentUser();
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(username, email, password);
      // Après l'inscription, connecter automatiquement
      await login(username, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _apiService.clearToken();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_isAuthenticated) {
      try {
        _currentUser = await _apiService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        debugPrint('Erreur de rafraîchissement de l\'utilisateur: $e');
      }
    }
  }

  // ==================== MODE INVITÉ ====================

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.loginAsGuest();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('api_base_url', ApiConfig.baseUrl);

      _currentUser = await _apiService.getCurrentUser();
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> incrementGuestLesson() async {
    if (!isGuest) return false;

    try {
      final result = await _apiService.incrementGuestLesson();
      // Rafraîchir l'utilisateur pour avoir les compteurs à jour
      await refreshUser();
      return result['should_prompt'] == true;
    } catch (e) {
      debugPrint('Erreur incrémentation leçon: $e');
      return false;
    }
  }

  Future<bool> incrementGuestQuiz() async {
    if (!isGuest) return false;

    try {
      final result = await _apiService.incrementGuestQuiz();
      // Rafraîchir l'utilisateur pour avoir les compteurs à jour
      await refreshUser();
      return result['should_prompt'] == true;
    } catch (e) {
      debugPrint('Erreur incrémentation quiz: $e');
      return false;
    }
  }

  Future<void> convertGuestToUser(
      String username, String email, String password) async {
    if (!isGuest) throw Exception('Pas un compte invité');

    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.convertGuestToUser(username, email, password);
      _currentUser = await _apiService.getCurrentUser();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    _currentUser = await _apiService.getCurrentUser();
    notifyListeners();
  }
}

