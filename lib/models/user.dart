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
  final double balance; // Added balance
  final UserLocation? location;
  final String? pseudo; // Ajouté
  final List<String>? preferences; // Ajouté
  final List<String>? paymentMethods; // Ajouté
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
    this.balance = 0.0, // Default to 0.0
    this.location,
    this.pseudo,
    this.preferences,
    this.paymentMethods,
    this.languages = const ['fr'],
    this.accountType = AccountType.essential,
    this.subscriptionStatus = SubscriptionStatus.active,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      firstName: json['firstName'] ?? json['prenom'] ?? '',
      lastName: json['lastName'] ?? json['nom'] ?? '',
      profileImage: json['profileImage'] ?? json['photoUrl'],
      role: UserRole.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toUpperCase() ==
            (json['role'] as String).toUpperCase(),
        orElse: () => UserRole.client,
      ),
      isVerified: json['isVerified'] ?? json['phoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ??
          json['dateCreation'] ??
          DateTime.now().toIso8601String()),
      balance: (json['balance'] ?? 0.0).toDouble(), // Parse balance
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'])
          : null,
      pseudo: json['pseudo'],
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : [],
      paymentMethods: json['paymentMethods'] != null
          ? List<String>.from(json['paymentMethods'])
          : [],
      languages: List<String>.from(json['languages'] ?? ['fr']),
      accountType: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['accountType'],
        orElse: () => AccountType.essential,
      ),
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['subscriptionStatus'],
        orElse: () => SubscriptionStatus.active,
      ),
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
      'pseudo': pseudo,
      'preferences': preferences,
      'paymentMethods': paymentMethods,
      'languages': languages,
      'accountType': accountType.toString().split('.').last,
      'subscriptionStatus': subscriptionStatus.toString().split('.').last,
    };
  }

  // New fields
  final AccountType accountType;
  final SubscriptionStatus subscriptionStatus;
}

enum UserRole { client, provider }

enum AccountType { essential, pro, business }

enum SubscriptionStatus { active, inactive, past_due }

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
          .map((e) => ServiceCategory.values
              .firstWhere((cat) => cat.toString() == 'ServiceCategory.$e'))
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
      'categories':
          categories.map((e) => e.toString().split('.').last).toList(),
      'hourlyRate': hourlyRate,
      'isAvailable': isAvailable,
      'photos': photos,
      'rating': rating,
      'reviewCount': reviewCount,
      'availability': availability,
    };
  }
}
