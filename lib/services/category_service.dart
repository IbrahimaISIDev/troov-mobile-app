import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../utils/config.dart';
import 'auth_service.dart';

class CategoryService {
  final String baseUrl = '${AppConfig.baseUrl}/categories';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Category.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('CategoryService: Error fetching categories: $e');
      return [];
    }
  }

  Future<Category?> getCategoryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData['status'] == 'success') {
          return Category.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('CategoryService: Error fetching category: $e');
      return null;
    }
  }
}
