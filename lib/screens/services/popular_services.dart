import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../home/components/product_card.dart';

class PopularServices extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onServiceTap;
  final VoidCallback onSeeAll;

  const PopularServices({
    super.key,
    required this.products,
    required this.onServiceTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Limit to 10 products
    final displayProducts = products.take(10).toList();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Services populaires',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Montserrat',
                  ),
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth < 600 ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          if (displayProducts.isEmpty)
            const Center(child: Text('Aucun service populaire pour le moment'))
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.01,
                ),
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  final product = displayProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => onServiceTap(product),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}