import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/provider_model.dart';
import 'auth_service.dart';

class ProviderService {
  static String _baseUrl = AuthService.baseUrl;

  Future<ProviderProfile?> getProviderByUserId(String userId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/providers/user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return ProviderProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      print('ProviderService: Error fetching provider by userId: $e');
      return null;
    }
  }

  Future<ProviderProfile?> getCurrentProvider() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return null;
    return getProviderByUserId(user.id);
  }

  Future<ProviderProfile?> createProvider(
      String userId, Map<String, dynamic> providerData) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/providers/user/$userId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(providerData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        return ProviderProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      print('ProviderService: Error creating provider: $e');
      return null;
    }
  }

  Future<ProviderProfile?> updateProvider(
      String id, Map<String, dynamic> providerData) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/providers/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(providerData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return ProviderProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      print('ProviderService: Error updating provider: $e');
      return null;
    }
  }

  Future<List<ProviderProfile>> getAllProviders() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/providers');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => ProviderProfile.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('ProviderService: Error fetching all providers: $e');
      return [];
    }
  }
}
