/// Configuration de l'API pour développement et production
class ApiConfig {
  // Changer à true pour utiliser l'API de production (Render)
  // Changer à false pour utiliser l'API locale (localhost)
  static const bool isProduction = false;

  // URLs selon l'environnement
  static const String localUrl = 'http://localhost:8000';
  static const String renderUrl = 'https://votre-service.onrender.com';
  
  // URL active selon l'environnement
  static const String baseUrl = isProduction ? renderUrl : localUrl;

  // Méthode helper pour tester rapidement
  static String getUrl() => baseUrl;
}

/// Points d'extrémité de l'API
class ApiEndpoints {
  static String get signs => '${ApiConfig.baseUrl}/api/signs';
  static String get auth => '${ApiConfig.baseUrl}/api/auth';
  static String get challenges => '${ApiConfig.baseUrl}/api/challenges';
  static String get profile => '${ApiConfig.baseUrl}/api/users';
  static String get docs => '${ApiConfig.baseUrl}/docs';
}

