import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import 'auth_service.dart';

class PaymentService {
  static const String baseUrl = 'https://troov.api.com';
  final AuthService _authService = AuthService();

  // Traiter un paiement mobile (Wave, Orange Money)
  Future<PaymentInfo?> processMobilePayment({
    required PaymentMethod method,
    required String phoneNumber,
    required double amount,
    required String bookingId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/mobile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'method': method.toString().split('.').last,
          'phoneNumber': phoneNumber,
          'amount': amount,
          'bookingId': bookingId,
          'currency': 'XOF',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentInfo.fromJson(data['payment']);
      } else {
        throw Exception('Erreur de paiement mobile');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Traiter un paiement par carte bancaire
  Future<PaymentInfo?> processCreditCardPayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required double amount,
    required String bookingId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/card'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cvv': cvv,
          'amount': amount,
          'bookingId': bookingId,
          'currency': 'XOF',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentInfo.fromJson(data['payment']);
      } else {
        throw Exception('Erreur de paiement par carte');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Traiter un paiement en espèces
  Future<PaymentInfo?> processCashPayment({
    required double amount,
    required String bookingId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/cash'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'bookingId': bookingId,
          'currency': 'XOF',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentInfo.fromJson(data['payment']);
      } else {
        throw Exception('Erreur de paiement en espèces');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Vérifier le statut d'un paiement
  Future<PaymentInfo> getPaymentStatus(String paymentId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentInfo.fromJson(data);
      } else {
        throw Exception('Erreur de vérification du paiement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir l'historique des paiements
  Future<List<PaymentInfo>> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final uri = Uri.parse('$baseUrl/payments/history').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['payments'] as List)
            .map((e) => PaymentInfo.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement de l\'historique');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Demander un remboursement
  Future<void> requestRefund(String paymentId, String reason) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de demande de remboursement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Confirmer un paiement mobile (avec code OTP)
  Future<PaymentInfo?> confirmMobilePayment({
    required String paymentId,
    required String otpCode,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otpCode': otpCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentInfo.fromJson(data['payment']);
      } else {
        throw Exception('Code de confirmation invalide');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les méthodes de paiement disponibles
  Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/methods'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['methods'] as List)
            .map((e) => PaymentMethod.values.firstWhere(
                  (method) => method.toString().split('.').last == e,
                ))
            .toList();
      } else {
        // Retourner les méthodes par défaut en cas d'erreur
        return [
          PaymentMethod.wave,
          PaymentMethod.orangeMoney,
          PaymentMethod.creditCard,
          PaymentMethod.cash,
        ];
      }
    } catch (e) {
      // Retourner les méthodes par défaut en cas d'erreur
      return [
        PaymentMethod.wave,
        PaymentMethod.orangeMoney,
        PaymentMethod.creditCard,
        PaymentMethod.cash,
      ];
    }
  }

  // Calculer les frais de transaction
  Future<double> calculateTransactionFees({
    required PaymentMethod method,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/calculate-fees'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'method': method.toString().split('.').last,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fees'].toDouble();
      } else {
        // Retourner 0 en cas d'erreur
        return 0.0;
      }
    } catch (e) {
      // Retourner 0 en cas d'erreur
      return 0.0;
    }
  }

  // Obtenir les statistiques de paiement (pour les prestataires)
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/payments/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur de chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un reçu de paiement par email
  Future<void> sendPaymentReceipt(String paymentId, String email) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/receipt'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur d\'envoi du reçu');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}

