import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class FeedbackModel {
  final String id;
  final String? userName;
  final String? userProfileImage;
  final String? message;
  final int? rating;
  final String? comment;
  final DateTime date;

  FeedbackModel({
    required this.id,
    this.userName,
    this.userProfileImage,
    this.message,
    this.rating,
    this.comment,
    required this.date,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userName: json['user']?['pseudo'] ?? json['user']?['firstName'],
      userProfileImage: json['user']?['profileImage'],
      message: json['message'],
      rating: json['rating'],
      comment: json['comment'],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FeedbackService {
  static String _baseUrl = AuthService.baseUrl;

  Future<List<FeedbackModel>> getProviderFeedbacks(String providerId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/feedbacks/provider/$providerId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((item) => FeedbackModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }
}
