import 'package:troov_app/models/enums.dart';
import 'package:troov_app/models/user.dart';
import 'package:troov_app/models/service_location.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final ServiceCategory category;
  final double price;
  final PriceType priceType;
  final String providerId;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final ServiceLocation? location;
  final Duration? estimatedDuration;
  final List<String> tags;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.priceType,
    required this.providerId,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.location,
    this.estimatedDuration,
    this.tags = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ServiceCategory.values.firstWhere(
        (e) => e.toString() == 'ServiceCategory.${json['category']}',
      ),
      price: json['price'].toDouble(),
      priceType: PriceType.values.firstWhere(
        (e) => e.toString() == 'PriceType.${json['priceType']}',
      ),
      providerId: json['providerId'],
      images: List<String>.from(json['images'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      location: json['location'] != null 
          ? ServiceLocation.fromJson(json['location']) 
          : null,
      estimatedDuration: json['estimatedDuration'] != null
          ? Duration(minutes: json['estimatedDuration'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'price': price,
      'priceType': priceType.toString().split('.').last,
      'providerId': providerId,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'location': location?.toJson(),
      'estimatedDuration': estimatedDuration?.inMinutes,
      'tags': tags,
    };
  }
}