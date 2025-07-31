import 'enums.dart';
import 'user.dart';
import 'service_location.dart';

class ServiceProvider {
  final String userId;
  final String description;
  final List<String> skills;
  final List<ServiceCategory> categories;
  final double hourlyRate;
  final double distance;
  final List<Service> services;
  final bool isAvailable;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> photos;
  final double rating;
  final int reviewCount;
  final Map<String, bool> availability; // jour -> disponible
  final User user; // Informations de l'utilisateur associées

  ServiceProvider({
    required this.userId,
    required this.description,
    required this.skills,
    required this.categories,
    required this.hourlyRate,
    this.distance = 0.0,
    this.services = const [],
    this.isAvailable = true,
    this.isOnline = false,
    this.lastSeen,
    this.photos = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.availability = const {},
    required this.user,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      userId: json["userId"],
      description: json["description"],
      skills: List<String>.from(json["skills"]),
      categories: (json["categories"] as List)
          .map((e) => ServiceCategory.values.firstWhere(
              (cat) => cat.toString() == "ServiceCategory.$e"))
          .toList(),
      hourlyRate: json["hourlyRate"].toDouble(),
      distance: json["distance"]?.toDouble() ?? 0.0,
      services: (json["services"] as List)
          .map((e) => Service.fromJson(e))
          .toList(),
      isAvailable: json["isAvailable"] ?? true,
      isOnline: json["isOnline"] ?? false,
      lastSeen: json["lastSeen"] != null ? DateTime.parse(json["lastSeen"]) : null,
      photos: List<String>.from(json["photos"] ?? []),
      rating: json["rating"]?.toDouble() ?? 0.0,
      reviewCount: json["reviewCount"] ?? 0,
      availability: Map<String, bool>.from(json["availability"] ?? {}),
      user: User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'description': description,
      'skills': skills,
      'categories': categories.map((e) => e.toString().split('.').last).toList(),
      'hourlyRate': hourlyRate,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'photos': photos,
      'rating': rating,
      'reviewCount': reviewCount,
      'availability': availability,
      'user': user.toJson(),
    };
  }
}

