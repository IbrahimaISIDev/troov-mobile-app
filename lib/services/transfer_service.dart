import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TransferService {
  static const String baseUrl = 'http://192.168.1.36:8086/api';
  final AuthService _authService = AuthService();

  // === COUNTRIES ===

  Future<List<dynamic>> getCountries() async {
    final response = await _authenticatedRequest('GET', '$baseUrl/countries');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // ApiResponse wrapper
    } else {
      throw Exception('Impossible de charger les pays');
    }
  }

  // === OPERATORS ===

  Future<List<dynamic>> getOperators({String? country}) async {
    final uri = Uri.parse('$baseUrl/operators')
        .replace(queryParameters: {if (country != null) 'country': country});

    print('DEBUG: Fetching operators from $uri');
    final response = await _authenticatedRequest('GET', uri.toString());
    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // ApiResponse wrapper
    } else {
      throw Exception('Impossible de charger les opérateurs');
    }
  }

  Future<Map<String, dynamic>> initiateTransfer({
    required String destinationCountry,
    required String recipientPhone,
    required String recipientName,
    required double amount,
    required String serviceSlug,
    required String userId,
  }) async {
    final uri = Uri.parse('$baseUrl/transaction/initiate')
        .replace(queryParameters: {'userId': userId});

    final response = await _authenticatedRequest(
      'POST',
      uri.toString(),
      body: {
        'destinationCountry': destinationCountry,
        'recipientPhone': recipientPhone,
        'recipientName': recipientName,
        'amount': amount,
        'serviceSlug': serviceSlug,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Erreur d\'initiation du transfert');
    }
  }

  // === TRANSACTIONS ===

  Future<void> deposit({
    required String operatorId,
    required double amount,
    required String phone,
    required String userId,
  }) async {
    await _performTransaction(
        '/transaction/deposit',
        {
          'operatorId': operatorId,
          'amount': amount,
          'phone': phone,
        },
        userId);
  }

  Future<void> withdraw({
    required String operatorId,
    required double amount,
    required String phone,
    required String userId,
  }) async {
    await _performTransaction(
        '/transaction/withdraw',
        {
          'operatorId': operatorId,
          'amount': amount,
          'phone': phone,
        },
        userId);
  }

  Future<void> sendMoney({
    required double amount,
    required String phone,
    required String userId,
  }) async {
    await _performTransaction(
        '/transaction/send',
        {
          'amount': amount,
          'phone': phone, // Recipient phone
        },
        userId);
  }

  Future<void> _performTransaction(
      String endpoint, Map<String, dynamic> body, String userId) async {
    final uri = Uri.parse('$baseUrl$endpoint')
        .replace(queryParameters: {'userId': userId});

    final response = await _authenticatedRequest(
      'POST',
      uri.toString(),
      body: body,
    );

    if (response.statusCode != 200) {
      print('DEBUG: Transaction Error: ${response.statusCode}');
      print('DEBUG: Response Body: "${response.body}"');

      if (response.body.isEmpty) {
        throw Exception(
            'Erreur serveur (${response.statusCode}): Réponse vide');
      }

      try {
        final data = jsonDecode(response.body);
        // Backend returns "message" in ApiResponse, not "error"
        throw Exception(
            data['message'] ?? data['error'] ?? 'Erreur de transaction');
      } catch (e) {
        if (e is FormatException) {
          throw Exception(
              'Erreur serveur (${response.statusCode}): Format de réponse invalide');
        }
        rethrow;
      }
    }
  }

  // === HISTORY ===

  Future<List<dynamic>> getTransactionHistory(String userId) async {
    final url = '$baseUrl/transaction/user/$userId';
    print('DEBUG: GET History URL: $url');
    final response = await _authenticatedRequest('GET', url);
    print('DEBUG: History Status: ${response.statusCode}');
    print('DEBUG: History Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // ApiResponse wrapper
    } else {
      throw Exception(
          'Impossible de charger l\'historique: ${response.statusCode}');
    }
  }

  // === AUTHENTICATED REQUEST HELPER (Duplicated from AuthService logic) ===

  Future<http.Response> _authenticatedRequest(String method, String url,
      {Map<String, dynamic>? body}) async {
    String? token = await _authService.getToken();

    var response = await _sendRequest(method, url, token, body);

    if (response.statusCode == 401) {
      final refreshSuccess = await _authService.tryRefreshToken();
      if (refreshSuccess) {
        token = await _authService.getToken();
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
    } else {
      throw Exception('Method $method not supported');
    }
  }
}
