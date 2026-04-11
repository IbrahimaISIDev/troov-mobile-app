import 'dart:convert';
import 'package:http/http.dart' as http;
import './auth_service.dart';
import '../models/story_model.dart';

class StoryService {
  final String baseUrl = AuthService.baseUrl; // Reuse base URL
  final AuthService _authService = AuthService();

  Future<List<Story>> getStories() async {
    // This method merges "My Status" and "Others" for now, or just returns others?
    // The UI likely calls this for the main list.
    // Let's implement specific methods and keep this as a wrapper if needed.
    try {
      final others = await getOtherStatuses();
      return others;
    } catch (e) {
      print('Error fetching stories: $e');
      return [];
    }
  }

  Future<List<Story>> getMyStatuses() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/v1/statuses/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching my statuses: $e');
      return [];
    }
  }

  Future<List<Story>> getOtherStatuses() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/v1/statuses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Story.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching other statuses: $e');
      return [];
    }
  }

  Future<void> postStatus(String type, String content,
      {String? caption, String? color, String? filePath}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final statusData = {
        'type': type, // TEXT, IMAGE, VIDEO
        'content': content, // URL if already uploaded, or text
        'caption': caption,
        'backgroundColor': color,
        'visibility': 'PUBLIC'
      };

      if (filePath != null && filePath.isNotEmpty) {
        // Multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/v1/statuses'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        
        // Add file
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
        
        // Add status JSON as a string part
        request.fields['status'] = jsonEncode(statusData);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to post status with file: ${response.body}');
        }
      } else {
        // Regular JSON request
        await http.post(
          Uri.parse('$baseUrl/v1/statuses'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(statusData),
        );
      }
    } catch (e) {
      print('Error posting status: $e');
      throw e;
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      await http.post(
        Uri.parse('$baseUrl/v1/statuses/$storyId/view'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Error viewing story: $e');
    }
  }

  // Helpers for UI (synchronous checks need cached data - this is tricky with async API)
  // The existing UI uses synchronous checks like 'hasStories'.
  // We need to refactor the UI to use FutureBuilder or Stream.
  // OR we cache result in Service (singleton or provider).
  // For now, I will remove these synchronous methods and update UI to match.
  // OR keep them but they might return empty until data is fetched.
  // Actually, 'StoryStatusAvatar' logic relies on these.
  // I need to provide a way to check status. A Future is best.
  // But modifying all avatars to be FutureBuilder is expensive UI-wise.
  // The list of chats/providers should include "hasStatus" flag from their own API endpoints?
  // User asked for "Backend must expose ... is_viewed".
  // The StatusService handles "Status Feed".
  // But Avatar rings appear in Chat List and Provider List.
  // Ideally, Chat API and Provider API should return "hasStatus" flag.
  // I can't easily update Chat/Provider APIs right now.
  // Workaround: Fetch ALL statuses once (periodically) and cache in StoryService.
  // Then synchronous checks work against cache.

  // Cache
  List<Story> _cachedStories = [];

  // Method to refresh cache
  Future<void> refreshStories() async {
    _cachedStories = await getOtherStatuses(); // And maybe mine?
    // Also fetch mine?
    // "Others" endpoint returns list of statuses.
    // If a user has multiple statuses, they appear as multiple items or grouped?
    // Current backend returns LIST of StatusDTO.
    // If User A has 3 statuses, User A appears 3 times?
    // UI expects Grouped by User?
    // WhatsApp shows 1 ring per user (split).
    // The current StoryModel is per-story.
    // The UI 'StoryViewScreen' expects list of Stories.
    // But 'HomeTab' shows avatars.

    // We need to group by user for the rings.
  }

  // Initial compatibility with existing sync calls
  List<Story> getUserStories(String userId) {
    return _cachedStories.where((s) => s.authorId == userId).toList();
  }

  bool hasStories(String userId) {
    return _cachedStories.any((s) => s.authorId == userId);
  }

  bool hasUnreadStories(String userId) {
    return _cachedStories.any((s) => s.authorId == userId && !s.isRead);
  }
}
