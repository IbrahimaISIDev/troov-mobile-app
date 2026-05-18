import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailModal extends StatefulWidget {
  final Product product;

  const ProductDetailModal({Key? key, required this.product}) : super(key: key);

  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => ProductDetailModal(product: product),
    );
  }

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Dynamic images list fallback
    final List<String> images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [widget.product.getThumbnailUrl()];

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF9CD1F7), // The exact beautiful sky blue background shown in the screenshot
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Drag handle indicator
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Main Image inside a beautiful blue/light-blue gradient container
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF86BFEA),
                        Color(0xFFC1DFF6),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Image layer
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: _buildProductImage(images[_selectedImageIndex]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Thumbnails row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThumbnail(0, images.isNotEmpty ? images[0] : null),
                    _buildThumbnail(1, images.length > 1 ? images[1] : null),
                    _buildThumbnail(2, images.length > 2 ? images[2] : null, isLastWithArrow: true),
                  ],
                ),
                const SizedBox(height: 28),

                // Product Title
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Badges row: "Ocasion", "G" logo, and dynamic description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A5568),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                          widget.product.duration ?? "G",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ] 
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price tag
                Text(
                  widget.product.price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Ratings Stars
                Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < 3; // Default 3 stars as shown in screenshot mockup
                    return Icon(
                      Icons.star_rounded,
                      color: isFilled ? const Color(0xFFFFA000) : Colors.grey.shade400,
                      size: 26,
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Seller's word section
                const Text(
                  'Mot du vendeur concernant le produit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 140,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      widget.product.description.isNotEmpty
                          ? widget.product.description
                          : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida. Risus.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Footer row: Stateful Quantity selector card and Action Pill Button
                SafeArea(
                  minimum: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Selector Card (replacing Caractéristiques)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _decrement,
                              child: const Icon(Icons.remove, size: 20, color: Colors.blueAccent),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 14),
                            GestureDetector(
                              onTap: _increment,
                              child: const Icon(Icons.add, size: 20, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),

                      // Checkout Share/Cart Pill Button
                      GestureDetector(
                        onTap: () {
                          // Perform add to cart / checkout confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$_quantity x ${widget.product.title} ajouté au panier !'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF4A5D70),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF566D85), // Elegant slate-grey/blue button color
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.reply_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 18,
                                color: Colors.white30,
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(int index, String? imageUrl, {bool isLastWithArrow = false}) {
    final isSelected = _selectedImageIndex == index;

    return GestureDetector(
      onTap: () {
        if (imageUrl != null) {
          setState(() {
            _selectedImageIndex = index;
          });
        }
      },
      child: Container(
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFCBE3FB), // Beautiful light blue thumbnail background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              if (imageUrl != null)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: _buildProductImage(imageUrl),
                  ),
                ),
              if (isLastWithArrow)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.25),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black54,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.photo_rounded,
        color: Colors.white70,
        size: 32,
      ),
    );
  }
}
