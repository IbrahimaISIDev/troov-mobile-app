import 'package:troov_app/models/enums.dart';

class SearchFilters {
  final ServiceCategory? category;
  final double? maxDistance;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? availableNow;
  final List<String>? tags;
  final PriceType? priceType;

  SearchFilters({
    this.category,
    this.maxDistance,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.availableNow,
    this.tags,
    this.priceType,
  });

  SearchFilters copyWith({
    ServiceCategory? category,
    double? maxDistance,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? availableNow,
    List<String>? tags,
    PriceType? priceType,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      maxDistance: maxDistance ?? this.maxDistance,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      availableNow: availableNow ?? this.availableNow,
      tags: tags ?? this.tags,
      priceType: priceType ?? this.priceType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category?.toString().split('.').last,
      'maxDistance': maxDistance,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'availableNow': availableNow,
      'tags': tags,
      'priceType': priceType != null ? priceType!.toString().split('.').last : null,
    };
  }
}

