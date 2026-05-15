import 'package:flutter/material.dart';
import '../../../models/product.dart';

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
          height: 215,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.05, right: sw * 0.01),
            itemCount: products.length,
            itemBuilder: (ctx, i) => _buildCard(products[i], i),
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

  Widget _buildCard(Product product, int index) {
    const cardW = 130.0;
    const imgH = 110.0;
    final hasPromo = product.promoLabel != null && product.promoLabel!.isNotEmpty;
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : product.getThumbnailUrl();
    final isNet = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    return GestureDetector(
      onTap: () => onProductTap(index),
      child: Container(
        width: cardW,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: cardW,
                    height: imgH,
                    child: _buildImage(imageUrl, isNet),
                  ),
                ),
                if (hasPromo)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.promoLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.price.isNotEmpty)
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    product.title,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  _buildStatusBadge(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Product product) {
    final label = (product.status != null && product.status!.isNotEmpty)
        ? product.status!
        : product.category;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 3),
          Icon(Icons.shopping_cart_outlined,
              size: 10, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildImage(String url, bool isNet) {
    if (isNet) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
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
