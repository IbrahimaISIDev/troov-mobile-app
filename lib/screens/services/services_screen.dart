import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import './service_header.dart';
import './service_categories.dart';
import './popular_services.dart';
import './service_provider_list.dart';
import './service_provider_detail.dart';
import '../../models/service_model.dart';
import '../chat/chat_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';
  ServiceCategory? _selectedCategory;
  ServiceProvider? _selectedProvider;
  List<ServiceProvider> _filteredProviders = [];

  // Navigation States
  bool _showProvidersList = false;
  bool _showProviderDetail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(showBack: true),
            ),
          );
        },
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_showProviderDetail && _selectedProvider != null) {
      return ServiceProviderDetail(
        provider: _selectedProvider!,
        onBack: () {
          setState(() {
            _showProviderDetail = false;
            _selectedProvider = null;
          });
        },
      );
    }

    if (_showProvidersList && _selectedCategory != null) {
      return ServiceProviderList(
        category: _selectedCategory!,
        providers: _filteredProviders,
        onBack: () {
          setState(() {
            _showProvidersList = false;
            _selectedCategory = null;
            _filteredProviders.clear();
          });
        },
        onProviderTap: (provider) {
          setState(() {
            _selectedProvider = provider;
            _showProviderDetail = true;
          });
        },
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
            _filterProviders();
          });
        },
      );
    }

    return _buildMainView();
  }

  Widget _buildMainView() {
    return CustomScrollView(
      slivers: [
        // Header avec recherche
        SliverToBoxAdapter(
          child: ServiceHeader(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onSearchSubmitted: (query) {
              if (query.isNotEmpty) {
                _searchGlobally(query);
              }
            },
          ),
        ),

        // Services populaires
        SliverToBoxAdapter(
          child: PopularServices(
            onServiceTap: (service) {
              _selectServiceCategory(service.category);
            },
          ),
        ),

        // Section "Près de chez vous"
        SliverToBoxAdapter(
          child: _buildNearbySection(),
        ),

        // Catégories de services
        SliverToBoxAdapter(
          child: ServiceCategories(
            onCategoryTap: (category) {
              _selectServiceCategory(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbySection() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Près de chez vous',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Découvrez les services les mieux notés dans votre région',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expert ${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '4.8',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectServiceCategory(ServiceCategory category) {
    setState(() {
      _selectedCategory = category;
      _filteredProviders = _getProvidersForCategory(category);
      _showProvidersList = true;
    });
  }

  void _searchGlobally(String query) {
    // Recherche globale dans tous les services
    final allProviders = _getAllProviders();
    final filtered = allProviders.where((provider) {
      return provider.name.toLowerCase().contains(query.toLowerCase()) ||
             provider.specialties.any((specialty) => 
                specialty.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      _filteredProviders = filtered;
      _selectedCategory = ServiceCategory(
        id: 'search',
        name: 'Résultats pour "$query"',
        icon: Icons.search,
        color: AppTheme.primaryBlue,
      );
      _showProvidersList = true;
    });
  }

  void _filterProviders() {
    if (_selectedCategory == null) return;
    
    final providers = _getProvidersForCategory(_selectedCategory!);
    if (_searchQuery.isEmpty) {
      _filteredProviders = providers;
    } else {
      _filteredProviders = providers.where((provider) {
        return provider.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               provider.specialties.any((specialty) => 
                  specialty.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
  }

  List<ServiceProvider> _getProvidersForCategory(ServiceCategory category) {
    // Simulation de données - à remplacer par un appel API
    final random = [4.2, 4.5, 4.7, 4.8, 4.9];
    final distances = [0.5, 1.2, 2.1, 3.0, 5.5];
    
    return List.generate(10, (index) {
      return ServiceProvider(
        id: '${category.id}_$index',
        name: _getProviderName(category, index),
        rating: random[index % random.length],
        distance: distances[index % distances.length],
        reviewCount: 50 + (index * 20),
        profileImage: null,
        specialties: _getSpecialties(category),
        description: 'Expert en ${category.name.toLowerCase()} avec plusieurs années d\'expérience.',
        phone: '+221 77 123 45 6$index',
        address: 'Quartier ${index + 1}, Dakar',
        isVerified: index < 5,
        responseTime: '${(index % 3) + 1}h',
        completedJobs: 100 + (index * 50),
        hourlyRate: 5000 + (index * 1000),
        availability: index % 2 == 0,
        portfolio: List.generate(3, (i) => 'image_${index}_$i.jpg'),
      );
    })..sort((a, b) {
      // Tri par distance puis par note
      final distanceComparison = a.distance.compareTo(b.distance);
      if (distanceComparison != 0) return distanceComparison;
      return b.rating.compareTo(a.rating);
    });
  }

  String _getProviderName(ServiceCategory category, int index) {
    final names = {
      'immobilier': ['Agence Premium', 'Dakar Properties', 'Sénégal Immo', 'Royal Estate', 'Urban Homes'],
      'sante': ['Dr. Diallo', 'Cabinet Médical Plus', 'Clinique Moderne', 'Dr. Ndiaye', 'Centre Santé'],
      'education': ['Prof. Sarr', 'École Excellence', 'Formation Pro', 'Institut Qualité', 'Académie Success'],
      'reparation': ['Tech Expert', 'Répar\' Tout', 'Service Rapide', 'Artisan Pro', 'Fix Master'],
      'transport': ['Taxi Premium', 'Transport Sûr', 'Livraison Express', 'Moov Transport', 'Quick Delivery'],
    };
    
    final categoryNames = names[category.id] ?? ['Service ${index + 1}'];
    return categoryNames[index % categoryNames.length];
  }

  List<String> _getSpecialties(ServiceCategory category) {
    final specialties = {
      'immobilier': ['Vente', 'Location', 'Gestion'],
      'sante': ['Consultation', 'Urgences', 'Spécialiste'],
      'education': ['Cours particuliers', 'Formation', 'Coaching'],
      'reparation': ['Électronique', 'Plomberie', 'Électricité'],
      'transport': ['Taxi', 'Livraison', 'Déménagement'],
    };
    
    return specialties[category.id] ?? ['Service général'];
  }

  List<ServiceProvider> _getAllProviders() {
    final allCategories = ServiceData.getCategories();
    List<ServiceProvider> allProviders = [];
    
    for (final category in allCategories) {
      allProviders.addAll(_getProvidersForCategory(category));
    }
    
    return allProviders;
  }
}