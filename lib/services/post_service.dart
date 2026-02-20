import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'auth_service.dart';

class PostService {
  // Replace with actual base URL or import from constants
  // Replace with actual base URL or import from constants
  static const String _baseUrl = AuthService.baseUrl;

  Future<List<Post>> getFeed({int page = 0, int size = 10}) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts?page=$page&size=$size');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> content = body['data']['content'];
          return content.map((json) => Post.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching feed: $e');
      return [];
    }
  }

  Future<List<Post>> getUserPosts() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/my-posts');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> content = body['data'];
          return content.map((json) => Post.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  Future<Post> createPost({
    required String description,
    required List<String> mediaUrls,
    String? category,
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'description': description,
          'mediaUrls': mediaUrls,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          return Post.fromJson(body['data']);
        }
      }
      throw Exception('Failed to create post');
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<bool> toggleLike(String postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/$postId/like');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  Future<void> viewPost(String postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/$postId/view');

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error viewing post: $e');
    }
  }
}
