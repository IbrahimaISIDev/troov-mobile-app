import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:troov_app/models/user.dart';
import 'package:troov_app/models/enums.dart';


class AuthService {
  static const String baseUrl = 'https://troov.api.com';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // Sauvegarder le token et les données utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userKey, jsonEncode(userData));

        return User.fromJson(userData);
      } else {
        throw Exception('Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Inscription
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required UserRole role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role.toString().split('.').last,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // Sauvegarder le token et les données utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userKey, jsonEncode(userData));

        return User.fromJson(userData);
      } else {
        throw Exception('Erreur d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer l'utilisateur connecté
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(userKey);
      
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // Connexion par téléphone
  Future<void> sendPhoneVerification(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/phone/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur d\'envoi du code');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérifier le code de téléphone
  Future<User?> verifyPhoneCode(String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/phone/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // Sauvegarder le token et les données utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userKey, jsonEncode(userData));

        return User.fromJson(userData);
      } else {
        throw Exception('Code invalide');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mise à jour du profil
  Future<User?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        
        // Mettre à jour les données utilisateur sauvegardées
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userKey, jsonEncode(userData));

        return User.fromJson(userData);
      } else {
        throw Exception('Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérification d'identité
  Future<void> submitIdentityVerification({
    required String documentType,
    required String documentNumber,
    required String frontImagePath,
    required String backImagePath,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Non connecté');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/verify-identity'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['documentType'] = documentType;
      request.fields['documentNumber'] = documentNumber;
      
      request.files.add(await http.MultipartFile.fromPath('frontImage', frontImagePath));
      request.files.add(await http.MultipartFile.fromPath('backImage', backImagePath));

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Erreur de vérification');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}

