import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? description;
  final int providerCount;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
    this.providerCount = 0,
  });
}

class ServiceProvider {
  final String id;
  final String name;
  final double rating;
  final double distance; // en km
  final int reviewCount;
  final String? profileImage;
  final List<String> specialties;
  final String description;
  final String phone;
  final String address;
  final bool isVerified;
  final String responseTime;
  final int completedJobs;
  final double hourlyRate; // en FCFA
  final bool availability;
  final List<String> portfolio;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.reviewCount,
    this.profileImage,
    required this.specialties,
    required this.description,
    required this.phone,
    required this.address,
    required this.isVerified,
    required this.responseTime,
    required this.completedJobs,
    required this.hourlyRate,
    required this.availability,
    required this.portfolio,
  });
}

class PopularService {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String subtitle;
  final ServiceCategory category;

  PopularService({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.category,
  });
}

class ServiceData {
  static List<ServiceCategory> getCategories() {
    return [
      ServiceCategory(
        id: 'immobilier',
        name: 'Immobilier',
        icon: Icons.home_rounded,
        color: Colors.blue,
        description: 'Vente, location et gestion immobilière',
        providerCount: 150,
      ),
      ServiceCategory(
        id: 'beaute',
        name: 'Beauté',
        icon: Icons.content_cut_rounded,
        color: Colors.pink,
        description: 'Coiffure femmes, esthétique et bien-être',
        providerCount: 95,
      ),
    ];
  }

  static List<PopularService> getPopularServices() {
    final categories = getCategories();
    final categoriesMap = {for (var c in categories) c.id: c};

    final immobilier = categoriesMap['immobilier'];
    final beaute = categoriesMap['beaute'];

    return [
      if (immobilier != null)
        PopularService(
          id: 'immobilier-location',
          name: 'Immobilier',
          icon: Icons.home_rounded,
          color: Colors.blue,
          subtitle: 'Location & colocation',
          category: immobilier,
        ),
      if (beaute != null)
        PopularService(
          id: 'beaute-coiffure-femmes',
          name: 'Coiffure femmes',
          icon: Icons.content_cut_rounded,
          color: Colors.pink,
          subtitle: 'Salons & coiffeuses',
          category: beaute,
        ),
    ];
  }
}