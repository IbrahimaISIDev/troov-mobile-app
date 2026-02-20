import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feed_item.dart';
import 'auth_service.dart';

class FeedService {
  // Replace with actual base URL or import from constants
  // Replace with actual base URL or import from constants
  static const String _baseUrl = AuthService.baseUrl;

  Future<List<FeedItem>> getFeed({int page = 0, int size = 10}) async {
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
          return content.map((json) => FeedItem.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching feed: $e');
      return [];
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
