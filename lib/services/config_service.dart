import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class ConfigService {
  static const String _baseUrlKey = 'baseUrl';

  /// Charge la configuration du serveur depuis le stockage local
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseUrl = prefs.getString(_baseUrlKey);
      
      if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
        AppConfig.setBaseUrl(savedBaseUrl);
      }
    } catch (e) {
      print('Erreur lors du chargement de la configuration: $e');
    }
  }

  /// Sauvegarde l'URL du serveur
  static Future<bool> saveBaseUrl(String baseUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Valider l'URL
      if (!isValidUrl(baseUrl)) {
        throw Exception('URL invalide');
      }
      
      // Mettre à jour la variable globale
      AppConfig.setBaseUrl(baseUrl);
      
      // Sauvegarder dans les préférences
      return await prefs.setString(_baseUrlKey, baseUrl);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'URL: $e');
      return false;
    }
  }

  /// Récupère l'URL actuelle
  static String getBaseUrl() {
    return AppConfig.baseUrl;
  }

  /// Réinitialise l'URL par défaut
  static Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      AppConfig.setBaseUrl(AppConfig.defaultBaseUrl);
      return await prefs.setString(_baseUrlKey, AppConfig.defaultBaseUrl);
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
      return false;
    }
  }

  /// Valide si l'URL est correctement formatée
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  /// Test de connexion au serveur
  static Future<bool> testConnection(String baseUrl) async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      final response = await http
          .get(uri)
          .timeout(Duration(seconds: 5))
          .then((response) => response.statusCode == 200);
      return response;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }
}
