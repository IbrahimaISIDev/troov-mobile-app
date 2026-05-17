import 'package:flutter/material.dart';
import '../../../models/product.dart';
import 'product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Function(int) onProductTap;
  final VoidCallback onSeeMoreTap;

  const ProductSection({
    Key? key,
    required this.title,
    required this.products,
    required this.onProductTap,
    required this.onSeeMoreTap,
  }) : super(key: key);

  bool get _isReTroov => title.startsWith('reTroov.');

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildTitle(sw)),
              TextButton(
                onPressed: onSeeMoreTap,
                child: const Text(
                  'Voir plus',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.05, right: sw * 0.01),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ProductCard(
              product: products[i],
              onTap: () => onProductTap(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTitle(double sw) {
    final prefix = _isReTroov ? 'reTroov.' : 'Troov.';
    final subtitle = title.replaceFirst(RegExp(r'^(re)?Troov\. ?'), '');
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$prefix ',
            style: TextStyle(
              fontSize: sw < 600 ? 15 : 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: subtitle,
            style: TextStyle(
              fontSize: sw < 600 ? 13 : 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
