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
  int _currentPage = 0;
  List<Product> _products = [];
  bool _isLoading = true;
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

  @override
  void dispose() {
    _pageController.dispose();
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
      body: RefreshIndicator(
        onRefresh: _loadPublications,
        color: Colors.white,
        backgroundColor: Colors.black,
        child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _products.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final product = _products[index];
          // We can use isActive from widget to control playback if the tab is switched
          final isFocused = (index == _currentPage) && widget.isActive;

          return VideoFeedItem(product: product, isFocused: isFocused);
        },
        ),
      ),
    );
  }
}
