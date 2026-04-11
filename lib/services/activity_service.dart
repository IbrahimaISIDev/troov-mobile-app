import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';
import '../utils/config.dart';
import 'auth_service.dart';

class ActivityService {
  final String baseUrl = '${AppConfig.baseUrl}/activities';

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Activity>> getAllActivities() async {
    final response =
        await http.get(Uri.parse(baseUrl), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<Activity> getActivityById(String id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/$id'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load activity');
    }
  }

  Future<List<Activity>> getActivitiesByProvider(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/provider/$providerId'),
        headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities by provider');
    }
  }

  Future<List<Activity>> getActivitiesByUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'),
        headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities by user');
    }
  }

  Future<Activity> createActivity(String productId, String buyerId, Map<String, dynamic> activityData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/product/$productId/buyer/$buyerId'),
      headers: await _getHeaders(),
      body: jsonEncode(activityData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create activity');
    }
  }

  Future<Activity> updateActivity(
      String id, Map<String, dynamic> activityData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(activityData),
    );
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update activity');
    }
  }

  Future<void> deleteActivity(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete activity');
    }
  }
}
