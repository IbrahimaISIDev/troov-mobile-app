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
        id: 'sante',
        name: 'Santé',
        icon: Icons.medical_services_rounded,
        color: Colors.red,
        description: 'Professionnels de santé et services médicaux',
        providerCount: 89,
      ),
      ServiceCategory(
        id: 'education',
        name: 'Éducation',
        icon: Icons.school_rounded,
        color: Colors.green,
        description: 'Formation, cours et coaching',
        providerCount: 200,
      ),
      ServiceCategory(
        id: 'reparation',
        name: 'Réparation',
        icon: Icons.build_rounded,
        color: Colors.orange,
        description: 'Maintenance et réparation tous domaines',
        providerCount: 175,
      ),
      ServiceCategory(
        id: 'transport',
        name: 'Transport',
        icon: Icons.local_shipping_rounded,
        color: Colors.purple,
        description: 'Transport et livraison',
        providerCount: 280,
      ),
      ServiceCategory(
        id: 'beaute',
        name: 'Beauté',
        icon: Icons.content_cut_rounded,
        color: Colors.pink,
        description: 'Coiffure, esthétique et bien-être',
        providerCount: 95,
      ),
      ServiceCategory(
        id: 'evenements',
        name: 'Événements',
        icon: Icons.event_rounded,
        color: Colors.teal,
        description: 'Organisation d\'événements et fêtes',
        providerCount: 45,
      ),
      ServiceCategory(
        id: 'technologie',
        name: 'Technologie',
        icon: Icons.computer_rounded,
        color: Colors.indigo,
        description: 'Services informatiques et digitaux',
        providerCount: 67,
      ),
    ];
  }

  static List<PopularService> getPopularServices() {
    final categories = getCategories();
    final categoriesMap = {for (var c in categories) c.id: c};

    return [
      PopularService(
        id: 'reparation-electronique',
        name: 'Réparation',
        icon: Icons.build_rounded,
        color: Colors.orange,
        subtitle: '150+ techniciens',
        category: categoriesMap['reparation']!,
      ),
      PopularService(
        id: 'transport-livraison',
        name: 'Livraison',
        icon: Icons.local_shipping_rounded,
        color: Colors.green,
        subtitle: '200+ livreurs',
        category: categoriesMap['transport']!,
      ),
      PopularService(
        id: 'sante-consultation',
        name: 'Consultation',
        icon: Icons.medical_services_rounded,
        color: Colors.red,
        subtitle: '80+ médecins',
        category: categoriesMap['sante']!,
      ),
      PopularService(
        id: 'education-cours',
        name: 'Cours privés',
        icon: Icons.school_rounded,
        color: Colors.blue,
        subtitle: '120+ profs',
        category: categoriesMap['education']!,
      ),
    ];
  }
}