import 'provider_model.dart';
import 'product.dart';

class Portfolio {
  final String id;
  final ProviderProfile? provider;
  final String title;
  final String? description;
  final Product? product;
  final List<String> tags;
  final List<String> images;
  final DateTime createdAt;

  Portfolio({
    required this.id,
    this.provider,
    required this.title,
    this.description,
    this.product,
    this.tags = const [],
    this.images = const [],
    required this.createdAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      provider: json['provider'] != null
          ? ProviderProfile.fromJson(json['provider'])
          : null,
      title: json['title'] ?? '',
      description: json['description'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider?.toJson(),
      'title': title,
      'description': description,
      'product': product?.toJson(),
      'tags': tags,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
