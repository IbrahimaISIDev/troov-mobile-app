class User {
  final String id;
  final String email;
  final String? phone;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;
  final UserLocation? location;
  final String? pseudo;
  final List<String>? preferences;
  final String? acquisitionSource;
  final String? referralCode;

  // Legacy fields to suppress screen compilation errors
  final double balance;
  final List<String> paymentMethods;

  User({
    required this.id,
    required this.email,
    this.phone,
    this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    this.location,
    this.pseudo,
    this.preferences,
    this.acquisitionSource,
    this.referralCode,
    this.balance = 0.0,
    this.paymentMethods = const [],
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
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
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'])
          : null,
      pseudo: json['pseudo'],
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : [],
      acquisitionSource: json['acquisitionSource'],
      referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'location': location?.toJson(),
      'pseudo': pseudo,
      'preferences': preferences,
      'acquisitionSource': acquisitionSource,
      'referralCode': referralCode,
    };
  }
}

enum UserRole { client, provider, admin, dev }

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

// ProviderProfile removed as it is now in provider_model.dart
