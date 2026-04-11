import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../utils/config.dart';

class ServiceHubService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }
    throw Exception('Failed to load categories');
  }

  Future<List<dynamic>> getPublications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?size=20'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['content']; // data['data'] is Page object
    }
    throw Exception(
        'Failed to load publications (Status: ${response.statusCode})');
  }

  Future<void> toggleLike(String postId) async {
    final token = await AuthService().getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like post');
    }
  }

  Future<void> incrementView(String postId) async {
    // This can be anonymous or authenticated
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/view'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('Failed to increment view counter: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['content'];
    }
    throw Exception('Failed to load comments');
  }

  Future<dynamic> addComment(String postId, String content) async {
    final token = await AuthService().getToken();
    if (token == null)
      throw Exception('Veuillez vous connecter pour commenter');

    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Failed to add comment');
  }

  Future<List<dynamic>> getPublicationsByCategory(String categoryId,
      {int page = 0, int size = 10}) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/services/items/category/$categoryId?page=$page&size=$size'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['content'];
    }
    throw Exception('Failed to load publications by category');
  }
}
