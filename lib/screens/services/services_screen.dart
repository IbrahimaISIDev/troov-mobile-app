import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import './service_header.dart';
import './service_categories.dart';
import './popular_services.dart';
import './service_provider_list.dart';
import './service_provider_detail.dart';
import '../../models/service_model.dart' as sm;
import '../../models/product.dart';
import '../../models/provider_model.dart';
import '../../models/category_model.dart' as cm;
import '../../services/product_service.dart';
import '../../services/provider_service.dart';
import '../../services/category_service.dart';
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../home/components/product_card.dart';

class ServicesScreen extends StatefulWidget {
  final sm.ServiceCategory? initialCategory;
  final Function(bool)? onHideBottomBar;

  const ServicesScreen({super.key, this.initialCategory, this.onHideBottomBar});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ProductService _productService = ProductService();
  final ProviderService _providerService = ProviderService();
  final CategoryService _categoryService = CategoryService();
  final ActivityService _activityService = ActivityService();

  String _searchQuery = '';
  sm.ServiceCategory? _selectedCategory;
  ProviderProfile? _selectedProvider;
  List<ProviderProfile> _filteredProviders = [];

  List<Product> _popularProducts = [];
  List<ProviderProfile> _nearbyProviders = [];
  List<cm.Category> _categories = [];
  bool _isLoading = true;

  // Navigation States
  bool _showProvidersList = false;
  bool _showProviderDetail = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
      // We'll need to fetch providers for this category from backend
      _fetchProvidersForCategory(widget.initialCategory!.id);
      _showProvidersList = true;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _productService.getAllProducts(),
        _providerService.getAllProviders(),
        _categoryService.getAllCategories(),
      ]);

      setState(() {
        _popularProducts = (futures[0] as List<Product>)
          ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
        _nearbyProviders = (futures[1] as List<ProviderProfile>)
          ..sort((a, b) => a.distance.compareTo(b.distance));
        _categories = futures[2] as List<cm.Category>;
        _isLoading = false;
      });
    } catch (e) {
      print('ServicesScreen: Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProvidersForCategory(String categoryId) async {
    // For now, filter from nearby if we have them, or fetch all
    if (_nearbyProviders.isEmpty) {
      final providers = await _providerService.getAllProviders();
      setState(() {
        _nearbyProviders = providers;
        _filteredProviders = providers
            .where((p) => p.specialties.any((s) =>
                s.toLowerCase() == _selectedCategory?.name.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        _filteredProviders = _nearbyProviders
            .where((p) => p.specialties.any((s) =>
                s.toLowerCase() == _selectedCategory?.name.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      if (widget.initialCategory != null) {
        setState(() {
          _selectedCategory = widget.initialCategory;
          _fetchProvidersForCategory(widget.initialCategory!.id);
          _showProvidersList = true;
          _showProviderDetail = false;
        });
      } else {
        setState(() {
          _selectedCategory = null;
          _showProvidersList = false;
          _showProviderDetail = false;
        });
        widget.onHideBottomBar?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_showProviderDetail && _selectedProvider != null) {
      // Map ProviderProfile to ServiceProvider if needed, or update detail screen
      final smProvider = _mapProfileToServiceProvider(_selectedProvider!);
      return ServiceProviderDetail(
        provider: smProvider,
        onBack: () {
          setState(() {
            _showProviderDetail = false;
            _selectedProvider = null;
          });
          widget.onHideBottomBar?.call(false);
        },
      );
    }

    if (_showProvidersList && _selectedCategory != null) {
      final smProviders =
          _filteredProviders.map(_mapProfileToServiceProvider).toList();
      return ServiceProviderList(
        category: _selectedCategory!,
        providers: smProviders,
        onBack: () {
          setState(() {
            _showProvidersList = false;
            _selectedCategory = null;
            _filteredProviders.clear();
          });
        },
        onProviderTap: (provider) {
          setState(() {
            _selectedProvider =
                _nearbyProviders.firstWhere((p) => p.id == provider.id);
            _showProviderDetail = true;
          });
          widget.onHideBottomBar?.call(true);
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
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: CustomScrollView(
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

          // 1. Catégories de services (En premier !)
          SliverToBoxAdapter(
            child: ServiceCategories(
              categories: _categories
                  .map((c) => sm.ServiceCategory(
                        id: c.id?.toString() ?? 'cat',
                        name: c.title,
                        icon: _getIconForCategory(c.title),
                        color: _getColorForCategory(c.color),
                        description: c.description,
                        providerCount: c.totalProducts,
                      ))
                  .toList(),
              onCategoryTap: (category) {
                _selectServiceCategory(category);
              },
            ),
          ),

          // 2. Section "Près de chez vous"
          SliverToBoxAdapter(
            child: _buildNearbySection(),
          ),

          // 3. Services populaires
          SliverToBoxAdapter(
            child: PopularServices(
              products: _popularProducts,
              onSeeAll: () {
                // TODO: Navigate to all popular products
              },
              onServiceTap: (product) {
                _showPurchaseModal(product);
              },
            ),
          ),

          // 4. Tous les services (Nouveau !)
          SliverToBoxAdapter(
            child: _buildAllServicesSection(),
          ),

          // Espace pour la navigation
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildAllServicesSection() {
    final sw = MediaQuery.of(context).size.width;
    final displayProducts = _popularProducts;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: sw * 0.05,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tous les services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Montserrat',
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (displayProducts.isEmpty)
            const Center(child: Text('Aucun service pour le moment'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.76, // Generous height room to avoid any RenderFlex overflow
              ),
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => _showPurchaseModal(product),
                  width: null, // Fill the grid cell width
                  margin: EdgeInsets.zero, // Remove horizontal list right margins
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String title) {
    title = title.toLowerCase();
    if (title.contains('immo')) return Icons.home_work_rounded;
    if (title.contains('sant')) return Icons.medical_services_rounded;
    if (title.contains('éduc')) return Icons.school_rounded;
    if (title.contains('répar')) return Icons.build_rounded;
    if (title.contains('transpor')) return Icons.local_shipping_rounded;
    if (title.contains('beauté')) return Icons.spa_rounded;
    if (title.contains('alim')) return Icons.restaurant_rounded;
    return Icons.category_rounded;
  }

  Color _getColorForCategory(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return AppTheme.primaryBlue;
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryBlue;
    }
  }

  Widget _buildNearbySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Près de chez vous',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_nearbyProviders.isEmpty)
            const Text('Aucun prestataire à proximité')
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    _nearbyProviders.length > 10 ? 10 : _nearbyProviders.length,
                itemBuilder: (context, index) {
                  final provider = _nearbyProviders[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProvider = provider;
                        _showProviderDetail = true;
                      });
                      widget.onHideBottomBar?.call(true);
                    },
                    child: Container(
                      width: 100,
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
                            radius: 25,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: (provider.logoUrl != null &&
                                    provider.logoUrl!.isNotEmpty)
                                ? NetworkImage(provider.logoUrl!)
                                : null,
                            child: (provider.logoUrl == null ||
                                    provider.logoUrl!.isEmpty)
                                ? const Icon(Icons.person,
                                    color: Colors.grey, size: 25)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              provider.user?.firstName ??
                                  provider.agencyName ??
                                  'Expert',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              Text(
                                provider.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showPurchaseModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PurchaseModal(
        product: product,
        onOrder: (qty) async {
          final user = await AuthService().getCurrentUser();
          if (user == null) return;

          try {
            await _activityService.createActivity(product.id, user.id, {
              'type': 'PURCHASE',
              'status': 'PENDING',
              'price': product.numericPrice,
              'quantity': qty,
              'description': 'Commande de ${product.title}',
            });
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Commande effectuée avec succès !'),
                    backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Erreur lors de la commande: $e'),
                  backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _selectServiceCategory(sm.ServiceCategory category) {
    setState(() {
      _selectedCategory = category;
      _filterProviders();
      _showProvidersList = true;
    });
  }

  void _searchGlobally(String query) {
    final filtered = _nearbyProviders.where((provider) {
      return (provider.agencyName
                  ?.toLowerCase()
                  .contains(query.toLowerCase()) ??
              false) ||
          (provider.user?.firstName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ??
              false) ||
          provider.specialties.any((specialty) =>
              specialty.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    setState(() {
      _filteredProviders = filtered;
      _selectedCategory = sm.ServiceCategory(
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

    final providers = _nearbyProviders;
    if (_searchQuery.isEmpty) {
      _filteredProviders = providers
          .where((p) => p.specialties.any(
              (s) => s.toLowerCase() == _selectedCategory?.name.toLowerCase()))
          .toList();
    } else {
      _filteredProviders = providers.where((provider) {
        final matchesQuery = (provider.agencyName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            provider.specialties.any((specialty) =>
                specialty.toLowerCase().contains(_searchQuery.toLowerCase()));
        final matchesCategory = provider.specialties.any(
            (s) => s.toLowerCase() == _selectedCategory?.name.toLowerCase());
        return matchesQuery && matchesCategory;
      }).toList();
    }
  }

  sm.ServiceProvider _mapProfileToServiceProvider(ProviderProfile profile) {
    return sm.ServiceProvider(
      id: profile.id ?? '',
      name: profile.agencyName ?? profile.user?.firstName ?? 'Expert',
      rating: profile.rating,
      distance: profile.distance,
      reviewCount: profile.reviewCount,
      profileImage: profile.logoUrl,
      specialties: profile.specialties,
      description: profile.bio ?? 'Aucune description disponible',
      phone: profile.user?.phoneNumber ?? '',
      address: profile.address ?? '',
      isVerified: profile.isVerified,
      responseTime: profile.responseTime ?? '1h',
      completedJobs: profile.totalMissions,
      hourlyRate: 5000, // Default or fetch from somewhere
      availability: profile.status == ProviderStatus.AVAILABLE,
      portfolio: [],
    );
  }
}

class _PurchaseModal extends StatefulWidget {
  final Product product;
  final Function(int) onOrder;

  const _PurchaseModal({required this.product, required this.onOrder});

  @override
  State<_PurchaseModal> createState() => _PurchaseModalState();
}

class _PurchaseModalState extends State<_PurchaseModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###", "fr_FR");

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: widget.product.getThumbnailUrl().isNotEmpty
                          ? Image.network(widget.product.getThumbnailUrl(),
                              fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 50)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catégorie: ${widget.product.category}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${currencyFormat.format(widget.product.numericPrice)} FCFA',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue),
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  // Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantité',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                  () => _quantity > 1 ? _quantity-- : null),
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Footer with Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${currencyFormat.format(widget.product.numericPrice * _quantity)} F',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => widget.onOrder(_quantity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      'Commandé',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
