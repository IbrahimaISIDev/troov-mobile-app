import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.36:8086/api';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];

        // Sauvegarder les tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, accessToken);
        await prefs.setString(refreshTokenKey, refreshToken);

        // Récupérer les informations de l'utilisateur
        final userResponse = await http.get(
          Uri.parse('$baseUrl/users/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (userResponse.statusCode == 200) {
          final userDataResponse = jsonDecode(userResponse.body);
          final userProfile = userDataResponse['data'];

          await prefs.setString(userKey, jsonEncode(userProfile));
          print('DEBUG: Login successful. Token saved.');
          return User.fromJson(userProfile);
        } else {
          throw Exception('Impossible de récupérer le profil utilisateur');
        }
      } else {
        throw _handleError(response);
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
    required String phone,
    String? pseudo,
    String? codeSecret,
    UserRole role = UserRole.client,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/register'));

      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['prenom'] = firstName;
      request.fields['nom'] = lastName;
      request.fields['phone'] = phone;
      request.fields['role'] = role.toString().split('.').last;

      if (pseudo != null && pseudo.isNotEmpty) {
        request.fields['pseudo'] = pseudo;
      }

      if (codeSecret != null && codeSecret.isNotEmpty) {
        request.fields['codeSecret'] = codeSecret;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userData = data['data']; // Le backend renvoie 'data': User

        // Note: L'inscription ne connecte pas automatiquement l'utilisateur
        // car le compte est en attente d'activation par OTP.
        // On retourne l'utilisateur pour info, mais pas de token stocké ici.

        return User.fromJson(userData);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow; // Relancer erreur gérée
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mot de passe oublié
  Future<String> forgotPassword(String login) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'login': login}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Code envoyé';
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérifier OTP pour réinitialisation
  Future<bool> verifyResetOtp(String login, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] == true;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String login, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message'] ?? data['error'] ?? 'Erreur inconnue';
      return Exception(message);
    } catch (_) {
      return Exception('Erreur serveur (${response.statusCode})');
    }
  }

  // Récupérer l'utilisateur connecté (Cache)
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

  // Rafraîchir les données utilisateur depuis le serveur
  Future<User?> refreshUser() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _fetchAndSaveUserProfile(token);
        return await getCurrentUser();
      }
      return null;
    } catch (e) {
      print('DEBUG: Error refreshing user: $e');
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);
    print('DEBUG: isLoggedIn check. Token found: ${token != null}');
    return token != null;
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Déconnexion
  Future<void> logout() async {
    print('DEBUG: Logging out...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(tokenKey);
      final refreshToken = prefs.getString(refreshTokenKey);

      if (accessToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken' // Needed for security if backend requires it
          },
          body: jsonEncode(
              {'accessToken': accessToken, 'refreshToken': refreshToken ?? ''}),
        );
      }
    } catch (e) {
      print('DEBUG: Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(userKey);
      await prefs.remove(refreshTokenKey);
      print('DEBUG: Local tokens cleared.');
    }
  }

  // Récupérer les sessions actives
  Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final response = await _authenticatedRequest(
        'GET',
        '$baseUrl/auth/sessions',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Impossible de récupérer les sessions');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Déconnecter tous les appareils
  Future<void> logoutAll() async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '$baseUrl/auth/logout-all',
      );

      if (response.statusCode == 200) {
        await logout(); // Nettoyage local aussi
      } else {
        throw Exception('Erreur lors de la déconnexion globale');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
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

      final response = await http.patch(
        Uri.parse('$baseUrl/users/me'),
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
        await prefs.setString(userKey, jsonEncode(userData['data']));

        return User.fromJson(userData['data']);
      } else {
        throw Exception('Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mise à jour du mot de passe
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _authenticatedRequest(
        'PATCH',
        '$baseUrl/users/me/password',
        body: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mise à jour du code secret (Transaction)
  Future<void> updateSecretCode(String password, String newCode) async {
    try {
      final response = await _authenticatedRequest(
        'PATCH',
        '$baseUrl/users/me/secret-code',
        body: {'password': password, 'newCode': newCode},
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un feedback
  Future<void> submitFeedback(
      String message, int rating, String type, String? comment) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception('Utilisateur non connecté');

      final uri = Uri.parse('$baseUrl/feedbacks').replace(queryParameters: {
        'userId': user.id,
        'type': type,
        'message': message,
        'rating': rating.toString(),
        if (comment != null) 'comment': comment,
      });

      // Feedback endpoint is POST but takes RequestParams in QueryString as per Controller definition?
      // Controller: @RequestParam ... => Query Params.
      // Usually POST uses body, but the controller signature shows @RequestParam.
      // Warning: POST with query params is valid but unusual for creation.
      // Let's check Controller again. Yes, @RequestParam.

      final response = await _authenticatedRequest(
        'POST',
        uri.toString(),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
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

      request.files
          .add(await http.MultipartFile.fromPath('frontImage', frontImagePath));
      request.files
          .add(await http.MultipartFile.fromPath('backImage', backImagePath));

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Erreur de vérification');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérifier OTP d'inscription
  Future<bool> verifyRegisterOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = data['data']; // JwtResponse {accessToken, refreshToken}
        final accessToken = tokens['accessToken'];

        // Sauvegarder les tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, accessToken);
        await prefs.setString(refreshTokenKey, tokens['refreshToken']);

        // Récupérer le profil utilisateur pour compléter la session
        await _fetchAndSaveUserProfile(accessToken);

        return true;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow; // Relancer erreur gérée
      throw Exception('Erreur réseau: $e');
    }
  }

  // Helper pour récupérer et sauvegarder le profil
  Future<void> _fetchAndSaveUserProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final userDataResponse = jsonDecode(response.body);
      final userProfile = userDataResponse['data'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userKey, jsonEncode(userProfile));
    }
  }

  // Renvoyer OTP d'inscription
  Future<void> sendRegisterOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau: $e');
    }
  }

  // --- App Lock (Code Secret Local) ---

  static const String appLockCodeKey = 'app_lock_code';

  Future<void> setAppLockCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLockCodeKey, code);
  }

  Future<String?> getAppLockCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(appLockCodeKey);
  }

  Future<bool> verifyAppLockCode(String code) async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '$baseUrl/auth/verify-secret-code',
        body: {'codeSecret': code},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] == true;
      }
      return false;
    } catch (e) {
      print('DEBUG: Verify secret code error: $e');
      return false;
    }
  }

  // --- Gestion des Tokens et Requêtes Authentifiées ---

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Tentative de rafraîchissement du token
  Future<bool> tryRefreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        print('DEBUG: No refresh token found. Logging out.');
        await logout();
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['data']['accessToken'];
        final newRefreshToken = data['data']['refreshToken'];

        await _saveTokens(newAccessToken, newRefreshToken);
        print('DEBUG: Token refreshed successfully');
        return true;
      } else {
        print(
            'DEBUG: Failed to refresh token (Status ${response.statusCode}). Login required.');
        await logout(); // Session expirée définitivement
        return false;
      }
    } catch (e) {
      print('DEBUG: Error refreshing token: $e');
      // En cas d'erreur réseau, on ne déconnecte pas forcément tout de suite,
      // mais le retry échouera.
      return false;
    }
  }

  // Helper pour les requêtes authentifiées avec retry
  Future<http.Response> _authenticatedRequest(String method, String url,
      {Map<String, dynamic>? body}) async {
    String? token = await getToken();

    // 1ere tentative
    var response = await _sendRequest(method, url, token, body);

    // Si 401 (Unauthorized), on tente de refresh le token
    if (response.statusCode == 401) {
      print('DEBUG: 401 Unauthorized. Attempting to refresh token...');
      final refreshSuccess = await tryRefreshToken();

      if (refreshSuccess) {
        // Nouvelle tentative avec le nouveau token
        token = await getToken();
        response = await _sendRequest(method, url, token, body);
      }
    }

    return response;
  }

  Future<http.Response> _sendRequest(
      String method, String url, String? token, Map<String, dynamic>? body) {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (method == 'POST') {
      return http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
    } else if (method == 'GET') {
      return http.get(Uri.parse(url), headers: headers);
    } else if (method == 'PATCH') {
      return http.patch(Uri.parse(url),
          headers: headers, body: jsonEncode(body));
    } else if (method == 'DELETE') {
      return http.delete(Uri.parse(url), headers: headers);
    } else {
      throw Exception('Method $method not supported');
    }
  }

  Future<bool> hasAppLock() async {
    final storedCode = await getAppLockCode();
    return storedCode != null && storedCode.isNotEmpty;
  }
}
