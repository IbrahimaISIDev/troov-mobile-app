import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'auth_service.dart';

class PostService {
  final AuthService authService = AuthService();
  static String _baseUrl = AuthService.baseUrl;

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
        if (body['status'] == 'success' && body['data'] != null) {
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
    final url = Uri.parse('$_baseUrl/posts/user');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('PostService: getUserPosts status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(response.bodyBytes));
        if (body['status'] == 'success' && body['data'] != null) {
          // Backend simplified GET still returns Page object, so we access 'content'
          final List<dynamic> content = body['data']['content'] ?? [];
          print('PostService: fetched ${content.length} user posts');
          return content.map((json) => Post.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('PostService: Error fetching user posts: $e');
      return [];
    }
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/user/$userId');

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
        if (body['status'] == 'success' && body['data'] != null) {
          final List<dynamic> content = body['data']['content'] ?? [];
          return content.map((json) => Post.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('PostService: Error fetching posts for user $userId: $e');
      return [];
    }
  }

  Future<Post> createPost({
    required String description,
    required String mediaUrl,
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
          'mediaUrl': mediaUrl,
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(response.bodyBytes));
        if (body['status'] == 'success' && body['data'] != null) {
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

  Future<void> sharePost(String postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/$postId/share');

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error sharing post: $e');
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/$postId/comments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        if (body['status'] == 'success' && body['data'] != null) {
          final List<dynamic> content = body['data']['content'] ?? [];
          return content.map((json) => Comment.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Comment?> addComment(String postId, String content) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/posts/$postId/comments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        if (body['status'] == 'success' && body['data'] != null) {
          return Comment.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/uploads');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        if (body['status'] == 'success' && body['data'] != null) {
          return body['data'].toString(); // Renvoie l'URL
        }
        throw Exception("Invalid response format: $body");
      } else {
        print('HTTP Error uploading image: ${response.statusCode} - ${response.body}');
        throw Exception("Backend HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print('Exception in uploadImage: $e');
      rethrow;
    }
  }
}
