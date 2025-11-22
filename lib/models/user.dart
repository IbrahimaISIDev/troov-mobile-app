class User {
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;
  final UserLocation? location;
  final List<String> languages;

  User({
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    this.location,
    this.languages = const ['fr'],
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImage'],
      role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${json['role']}'),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      location: json['location'] != null ? UserLocation.fromJson(json['location']) : null,
      languages: List<String>.from(json['languages'] ?? ['fr']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'location': location?.toJson(),
      'languages': languages,
    };
  }
}

enum UserRole { client, provider }

enum ServiceCategory {
  cleaning,
  repair,
  delivery,
  cooking,
  health,
  beauty,
  education,
  transport,
  gardening,
  technology
}

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
    };
  }
}

class ProviderProfile {
  final String userId;
  final String description;
  final List<String> skills;
  final List<ServiceCategory> categories;
  final double hourlyRate;
  final bool isAvailable;
  final List<String> photos;
  final double rating;
  final int reviewCount;
  final Map<String, bool> availability; // jour -> disponible

  ProviderProfile({
    required this.userId,
    required this.description,
    required this.skills,
    required this.categories,
    required this.hourlyRate,
    this.isAvailable = true,
    this.photos = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.availability = const {},
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      userId: json['userId'],
      description: json['description'],
      skills: List<String>.from(json['skills']),
      categories: (json['categories'] as List)
          .map((e) => ServiceCategory.values.firstWhere(
              (cat) => cat.toString() == 'ServiceCategory.$e'))
          .toList(),
      hourlyRate: json['hourlyRate'].toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      photos: List<String>.from(json['photos'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      availability: Map<String, bool>.from(json['availability'] ?? {}),
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
      'photos': photos,
      'rating': rating,
      'reviewCount': reviewCount,
      'availability': availability,
    };
  }
}

