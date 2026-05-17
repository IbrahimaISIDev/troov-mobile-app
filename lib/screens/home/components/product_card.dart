import 'package:flutter/material.dart';
import '../../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.width = 170,
    this.margin = const EdgeInsets.only(right: 16, bottom: 4, top: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : product.getThumbnailUrl();
    final isNet = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: margin,
        color: Colors.transparent, // No blue background on the outer container!
        child: Column(
          children: [
            // Top half: Blue container that covers ONLY the image and price tag
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFB4D2EA), // Soft mockup blue
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // The image covers the entire div container
                    Positioned.fill(
                      child: _buildImage(imageUrl, isNet, fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Bottom half: Details capsule outside the blue container
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 219, 219, 219),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                product.price,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 30,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.black,
                                ),
                                child: const Center(
                                  child: Text(
                                    '-15%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4D50),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_basket_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url, bool isNet, {BoxFit fit = BoxFit.cover}) {
    if (isNet) {
      return Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: 28,
        ),
      ),
    );
  }
}
