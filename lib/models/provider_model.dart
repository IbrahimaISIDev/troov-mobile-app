import 'user.dart';

class ProviderProfile {
  final String? id;
  final User? user; // Can be minimal parsed user
  final String? agencyName;
  final List<String> specialties;
  final double rating;
  final double distance;
  final int reviewCount;
  final int totalMissions;
  final int serviceCount;
  final String? address;
  final String? responseTime;
  final String? bio;
  final bool isVerified;
  final ProviderStatus status;
  final int likes;
  final String? profession;
  final String? logoUrl;
  final String subscriptionType;

  ProviderProfile({
    this.id,
    this.user,
    this.agencyName,
    this.specialties = const [],
    this.rating = 0.0,
    this.distance = 0.0,
    this.reviewCount = 0,
    this.totalMissions = 0,
    this.serviceCount = 0,
    this.address,
    this.responseTime,
    this.bio,
    this.isVerified = false,
    this.status = ProviderStatus.AVAILABLE,
    this.likes = 0,
    this.profession,
    this.logoUrl,
    this.subscriptionType = 'STANDARD',
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      agencyName: json['agencyName'],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      totalMissions: json['totalMissions'] ?? 0,
      serviceCount: json['serviceCount'] ?? 0,
      address: json['address'],
      responseTime: json['responseTime'],
      bio: json['bio'],
      isVerified: json['isVerified'] ?? false,
      status: _parseStatus(json['status']),
      likes: json['likes'] ?? 0,
      profession: json['profession'],
      logoUrl: json['logoUrl'],
      subscriptionType: json['subscriptionType'] ?? 'STANDARD',
    );
  }
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'agencyName': agencyName,
      'specialties': specialties,
      'rating': rating,
      'distance': distance,
      'reviewCount': reviewCount,
      'totalMissions': totalMissions,
      'serviceCount': serviceCount,
      'address': address,
      'responseTime': responseTime,
      'bio': bio,
      'isVerified': isVerified,
      'status': status.toString().split('.').last,
      'likes': likes,
      'profession': profession,
      'logoUrl': logoUrl,
      'subscriptionType': subscriptionType,
    };
  }

  static ProviderStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return ProviderStatus.AVAILABLE;
    switch (statusStr.toUpperCase()) {
      case 'BUSY':
        return ProviderStatus.BUSY;
      case 'OFFLINE':
        return ProviderStatus.OFFLINE;
      case 'VACATION':
        return ProviderStatus.VACATION;
      default:
        return ProviderStatus.AVAILABLE;
    }
  }
}

enum ProviderStatus {
  AVAILABLE,
  BUSY,
  OFFLINE,
  VACATION,
}
