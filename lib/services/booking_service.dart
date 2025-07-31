import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  static const String baseUrl = 'https://troov.api.com';
  final AuthService _authService = AuthService();

  // Créer une nouvelle réservation
  Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Erreur de création de réservation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les réservations de l'utilisateur
  Future<List<Booking>> getUserBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      Map<String, String> params = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        params['status'] = status.toString().split('.').last;
      }

      final uri = Uri.parse('$baseUrl/bookings/user').replace(
        queryParameters: params,
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
        return (data['bookings'] as List)
            .map((e) => Booking.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les réservations d'un prestataire
  Future<List<Booking>> getProviderBookings({
    BookingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      Map<String, String> params = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        params['status'] = status.toString().split('.').last;
      }

      final uri = Uri.parse('$baseUrl/bookings/provider').replace(
        queryParameters: params,
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
        return (data['bookings'] as List)
            .map((e) => Booking.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les détails d'une réservation
  Future<Booking> getBookingDetails(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Réservation non trouvée');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Confirmer une réservation (pour les prestataires)
  Future<Booking> confirmBooking(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Erreur de confirmation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Démarrer une réservation (pour les prestataires)
  Future<Booking> startBooking(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Erreur de démarrage');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Terminer une réservation (pour les prestataires)
  Future<Booking> completeBooking(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Erreur de finalisation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Annuler une réservation
  Future<Booking> cancelBooking(String bookingId, String reason) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Erreur d\'annulation');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Signaler un litige
  Future<void> reportDispute(String bookingId, String reason, List<String> attachments) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/dispute'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
          'attachments': attachments,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de signalement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les statistiques des réservations (pour les prestataires)
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/stats'),
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

  // Rechercher des créneaux disponibles
  Future<List<DateTime>> getAvailableSlots({
    required String providerId,
    required DateTime date,
    required Duration serviceDuration,
  }) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/available-slots')
            .replace(queryParameters: {
          'providerId': providerId,
          'date': date.toIso8601String(),
          'duration': serviceDuration.inMinutes.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['slots'] as List)
            .map((e) => DateTime.parse(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement des créneaux');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Envoyer un rappel de réservation
  Future<void> sendBookingReminder(String bookingId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/reminder'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur d\'envoi du rappel');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}

