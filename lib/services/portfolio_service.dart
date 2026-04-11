import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio_model.dart';
import 'auth_service.dart';

class PortfolioService {
  static String _baseUrl = AuthService.baseUrl;

  Future<List<Portfolio>> getPortfolio(String providerId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$_baseUrl/portfolios/provider/$providerId');

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
        return data.map((json) => Portfolio.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('PortfolioService: Error fetching portfolio: $e');
      return [];
    }
  }

  Future<Portfolio?> createPortfolioItem(String providerId, {
    required String title,
    String? description,
    String? productId,
    List<String> tags = const [],
    List<String> images = const [],
  }) async {
    final token = await AuthService().getToken();
    var urlString = '$_baseUrl/portfolios/provider/$providerId';
    if (productId != null) {
      urlString += '?productId=$productId';
    }
    final url = Uri.parse(urlString);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'tags': tags,
          'images': images,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return Portfolio.fromJson(data);
      }
      return null;
    } catch (e) {
      print('PortfolioService: Error creating portfolio item: $e');
      return null;
    }
  }
}
