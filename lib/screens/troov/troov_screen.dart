import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../data/mock_database.dart';
import '../../widgets/video_feed_item.dart';

class TroovScreen extends StatefulWidget {
  final bool isActive;

  const TroovScreen({super.key, this.isActive = true});

  @override
  State<TroovScreen> createState() => _TroovScreenState();
}

class _TroovScreenState extends State<TroovScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _products = List<Product>.from(MockDatabase.products)..shuffle();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
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
    );
  }
}
