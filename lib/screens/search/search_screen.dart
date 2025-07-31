import 'package:flutter/material.dart';
import '../../utils/localization.dart';
import '../../utils/theme.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../services/service_service.dart';
import '../../widgets/service_card.dart';
import '../../widgets/provider_card.dart';
import 'filter_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _serviceService = ServiceService();
  
  late TabController _tabController;
  
  List<Service> _services = [];
  List<ServiceProvider> _providers = [];
  bool _isLoading = false;
  SearchFilters _filters = SearchFilters();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _serviceService.searchServices(
        query: '',
        filters: _filters,
      );
      final providers = await _serviceService.getNearbyProviders();

      setState(() {
        _services = services;
        _providers = providers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final services = await _serviceService.searchServices(
        query: _searchQuery,
        filters: _filters,
      );

      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de recherche: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(initialFilters: _filters),
      ),
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
      _search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Recherche'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Services'),
            Tab(text: 'Prestataires'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: localizations.searchServices,
                        prefixIcon: Icon(Icons.search, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onSubmitted: (value) {
                        _search();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: Colors.white),
                    onPressed: _showFilters,
                  ),
                ),
              ],
            ),
          ),

          // Filtres actifs
          if (_hasActiveFilters())
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildActiveFilters(),
              ),
            ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildProvidersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucun service trouvé',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return ServiceCard(
          service: _services[index],
          onTap: () {
            // TODO: Naviguer vers les détails du service
          },
        );
      },
    );
  }

  Widget _buildProvidersTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucun prestataire trouvé',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aucun prestataire disponible dans votre zone',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        return ProviderCard(
          provider: _providers[index],
          onTap: () {
            // TODO: Naviguer vers le profil du prestataire
          },
        );
      },
    );
  }

  bool _hasActiveFilters() {
    return _filters.category != null ||
           _filters.maxDistance != null ||
           _filters.minPrice != null ||
           _filters.maxPrice != null ||
           _filters.minRating != null ||
           _filters.availableNow == true ||
           (_filters.tags?.isNotEmpty ?? false);
  }

  List<Widget> _buildActiveFilters() {
    List<Widget> filters = [];

    if (_filters.category != null) {
      filters.add(_buildFilterChip(
        label: _getCategoryName(_filters.category!),
        onRemove: () {
          setState(() {
            _filters = SearchFilters(
              maxDistance: _filters.maxDistance,
              minPrice: _filters.minPrice,
              maxPrice: _filters.maxPrice,
              minRating: _filters.minRating,
              availableNow: _filters.availableNow,
              tags: _filters.tags,
              priceType: _filters.priceType,
            );
          });
          _search();
        },
      ));
    }

    if (_filters.maxDistance != null) {
      filters.add(_buildFilterChip(
        label: '< ${_filters.maxDistance!.toInt()}km',
        onRemove: () {
          setState(() {
            _filters = SearchFilters(
              category: _filters.category,
              minPrice: _filters.minPrice,
              maxPrice: _filters.maxPrice,
              minRating: _filters.minRating,
              availableNow: _filters.availableNow,
              tags: _filters.tags,
              priceType: _filters.priceType,
            );
          });
          _search();
        },
      ));
    }

    if (_filters.minRating != null) {
      filters.add(_buildFilterChip(
        label: '${_filters.minRating!.toInt()}+ ⭐',
        onRemove: () {
          setState(() {
            _filters = SearchFilters(
              category: _filters.category,
              maxDistance: _filters.maxDistance,
              minPrice: _filters.minPrice,
              maxPrice: _filters.maxPrice,
              availableNow: _filters.availableNow,
              tags: _filters.tags,
              priceType: _filters.priceType,
            );
          });
          _search();
        },
      ));
    }

    if (_filters.availableNow == true) {
      filters.add(_buildFilterChip(
        label: 'Disponible maintenant',
        onRemove: () {
          setState(() {
            _filters = SearchFilters(
              category: _filters.category,
              maxDistance: _filters.maxDistance,
              minPrice: _filters.minPrice,
              maxPrice: _filters.maxPrice,
              minRating: _filters.minRating,
              tags: _filters.tags,
              priceType: _filters.priceType,
            );
          });
          _search();
        },
      ));
    }

    return filters;
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: AppTheme.primaryBlue,
        deleteIcon: Icon(Icons.close, color: Colors.white, size: 16),
        onDeleted: onRemove,
      ),
    );
  }

  String _getCategoryName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return 'Ménage';
      case ServiceCategory.repair:
        return 'Réparation';
      case ServiceCategory.delivery:
        return 'Livraison';
      case ServiceCategory.cooking:
        return 'Cuisine';
      case ServiceCategory.health:
        return 'Santé';
      case ServiceCategory.beauty:
        return 'Beauté';
      case ServiceCategory.education:
        return 'Éducation';
      case ServiceCategory.transport:
        return 'Transport';
      case ServiceCategory.gardening:
        return 'Jardinage';
      case ServiceCategory.technology:
        return 'Technologie';
      default:
        return category.toString().split('.').last;
    }
  }
}

