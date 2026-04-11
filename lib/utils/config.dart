class AppConfig {
  static String _baseUrl = 'https://troov-backend.onrender.com/api';

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  // URL par défaut
  static const String defaultBaseUrl = 'http://192.168.1.69:8081/api';
  static const String productionBaseUrl = 'https://troov-backend.onrender.com/api';
}
