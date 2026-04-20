import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/service_hub_service.dart';
import '../../widgets/video_feed_item.dart';

class TroovScreen extends StatefulWidget {
  final bool isActive;

  const TroovScreen({super.key, this.isActive = true});

  @override
  State<TroovScreen> createState() => _TroovScreenState();
}

class _TroovScreenState extends State<TroovScreen> {
  final PageController _pageController = PageController();
  final ServiceHubService _serviceHubService = ServiceHubService();
  final TextEditingController _searchController = TextEditingController();
  
  int _currentPage = 0;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPublications();
  }

  Future<void> _loadPublications() async {
    try {
      final items = await _serviceHubService.getPublications();
      if (mounted) {
        setState(() {
          _products = items.map((item) => Product.fromJson(item)).toList();
          _filteredProducts = _products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          final title = product.title.toLowerCase();
          final desc = product.description.toLowerCase();
          final cat = product.category.toLowerCase();
          final q = query.toLowerCase();
          return title.contains(q) || desc.contains(q) || cat.contains(q);
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredProducts = _products;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $_error',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPublications,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Feed
          RefreshIndicator(
            onRefresh: _loadPublications,
            color: Colors.white,
            backgroundColor: Colors.black,
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune publication trouvée',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: _filteredProducts.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isFocused = (index == _currentPage) && widget.isActive;
                      return VideoFeedItem(product: product, isFocused: isFocused);
                    },
                  ),
          ),

          // Top Overlay (Search Icon and Animated Search Bar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isSearching ? MediaQuery.of(context).size.width - 100 : 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isSearching)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    onChanged: _onSearchChanged,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Rechercher...',
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                splashRadius: 28,
                                onPressed: _toggleSearch,
                                icon: Icon(
                                  _isSearching ? Icons.close : Icons.search,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
