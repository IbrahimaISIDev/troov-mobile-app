import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:troov_app/models/enums.dart';
import 'package:troov_app/models/search_filters.dart';
import 'package:troov_app/models/service.dart';
import 'package:troov_app/models/user.dart';
import 'package:troov_app/models/service_provider.dart';
import 'package:troov_app/services/auth_service.dart';

class ServiceService {
  static const String baseUrl = 'https://troov.api.com';
  final AuthService _authService = AuthService();

  // Rechercher des services
  Future<List<Service>> searchServices({
    required String query,
    SearchFilters? filters,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await _authService.getToken();
      
      Map<String, dynamic> params = {
        'query': query,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      if (filters != null) {
        params.addAll(filters.toJson());
      }

      final uri = Uri.parse('$baseUrl/services/search').replace(
        queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['services'] as List)
            .map((e) => Service.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de recherche');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les prestataires à proximité
  Future<List<ServiceProvider>> getNearbyProviders({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final token = await _authService.getToken();
      
      Map<String, String> params = {};
      if (latitude != null) params['latitude'] = latitude.toString();
      if (longitude != null) params['longitude'] = longitude.toString();
      if (radius != null) params['radius'] = radius.toString();

      final uri = Uri.parse('$baseUrl/providers/nearby').replace(
        queryParameters: params,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['providers'] as List)
            .map((e) => ServiceProvider.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les détails d'un service
  Future<Service> getServiceDetails(String serviceId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Service.fromJson(data);
      } else {
        throw Exception('Service non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les services populaires
  Future<List<Service>> getPopularServices() async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/services/popular'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['services'] as List)
            .map((e) => Service.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les services par catégorie
  Future<List<Service>> getServicesByCategory(ServiceCategory category) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/services/category/${category.toString().split('.').last}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['services'] as List)
            .map((e) => Service.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Créer un nouveau service (pour les prestataires)
  Future<Service> createService(Map<String, dynamic> serviceData) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Service.fromJson(data);
      } else {
        throw Exception('Erreur de création');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mettre à jour un service
  Future<Service> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.put(
        Uri.parse('$baseUrl/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Service.fromJson(data);
      } else {
        throw Exception('Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Supprimer un service
  Future<void> deleteService(String serviceId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Non connecté');

      final response = await http.delete(
        Uri.parse('$baseUrl/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur de suppression');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Obtenir les services d'un prestataire
  Future<List<Service>> getProviderServices(String providerId) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/providers/$providerId/services'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['services'] as List)
            .map((e) => Service.fromJson(e))
            .toList();
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Calculer la distance entre deux points
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    // Implémentation simplifiée de la formule de Haversine
    const double earthRadius = 6371; // Rayon de la Terre en km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}

