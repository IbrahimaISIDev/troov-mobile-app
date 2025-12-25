import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/post_model.dart';

class PostService {
  final String baseUrl = AuthService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthService.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get Feed
  Future<List<Post>> getFeed({int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/posts?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> content = data['data']['content'];
        return content.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }

  // Create Post
  Future<Post> createPost({
    required String description,
    required List<String> mediaUrls,
    String? category,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
        body: jsonEncode({
          'description': description,
          'mediaUrls': mediaUrls,
          'category': category,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data['data']);
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  // Get Single Post
  Future<Post> getPostById(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data['data']);
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  // Get User Posts
  Future<List<Post>> getUserPosts(
      {String? userId, int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final url = userId != null
          ? '$baseUrl/posts/user/$userId?page=$page&size=$size'
          : '$baseUrl/posts/user?page=$page&size=$size';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> content = data['data']['content'];
        return content.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user posts');
      }
    } catch (e) {
      throw Exception('Error fetching user posts: $e');
    }
  }

  // Toggle Like Post
  Future<void> toggleLikePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      throw Exception('Error liking post: $e');
    }
  }

  // Get Comments
  Future<List<Comment>> getComments(String postId,
      {int page = 0, int size = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> content = data['data']['content'];
        return content.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  // Add Comment
  Future<Comment> addComment(String postId, String content) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: headers,
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Comment.fromJson(data['data']);
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  // Toggle Like Comment
  Future<void> toggleLikeComment(String commentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/comments/$commentId/like'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle comment like');
      }
    } catch (e) {
      throw Exception('Error liking comment: $e');
    }
  }

  // Increment View Count
  Future<void> incrementViewCount(String postId) async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/posts/$postId/view'),
        headers: headers,
      );
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }
}
