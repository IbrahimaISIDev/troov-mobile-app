import 'product.dart';
import 'user.dart';
import 'provider_model.dart';

class Activity {
  final String id;
  final ActivityType type;
  final Product? product;
  final User? user; // The buyer
  final ProviderProfile? provider; // The seller/provider
  final ActivityStatus status;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.type,
    this.product,
    this.user,
    this.provider,
    required this.status,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: _parseType(json['type']),
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      provider: json['provider'] != null
          ? ProviderProfile.fromJson(json['provider'])
          : null,
      status: _parseStatus(json['status']),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'product': product?.toJson(),
      'user': user?.toJson(),
      'provider': provider?.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ActivityType _parseType(String? typeStr) {
    if (typeStr == 'SALE') return ActivityType.SALE;
    return ActivityType.PURCHASE;
  }

  static ActivityStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toUpperCase()) {
      case 'DELIVERED':
        return ActivityStatus.DELIVERED;
      case 'SOLD':
        return ActivityStatus.SOLD;
      case 'CANCELLED':
        return ActivityStatus.CANCELLED;
      case 'PENDING':
        return ActivityStatus.PENDING;
      case 'NEW':
      default:
        return ActivityStatus.NEW;
    }
  }
}

enum ActivityType { PURCHASE, SALE }

enum ActivityStatus { NEW, PENDING, DELIVERED, SOLD, CANCELLED }
