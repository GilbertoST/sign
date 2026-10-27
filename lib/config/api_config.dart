/// Configuration de l'API pour développement et production
class ApiConfig {
  // Changer à true pour utiliser l'API de production (Render)
  // Changer à false pour utiliser l'API locale (localhost)
  static const bool isProduction = true;

  // URLs selon l'environnement
  static const String localUrl = 'http://localhost:8000';
  static const String renderUrl = 'https://sign-4yrc.onrender.com';
  
  // URL active selon l'environnement
  static const String baseUrl = isProduction ? renderUrl : localUrl;
}

