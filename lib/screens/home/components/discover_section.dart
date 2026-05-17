import 'package:flutter/material.dart';

class DiscoverItem {
  final String image;
  final String title;

  const DiscoverItem({required this.image, required this.title});
}

class DiscoverSection extends StatelessWidget {
  final VoidCallback? onTap;

  const DiscoverSection({Key? key, this.onTap}) : super(key: key);

  static const List<DiscoverItem> _items = [
    DiscoverItem(
      image: 'assets/images/image.png',
      title: 'Réseau\nCollocation',
    ),
    DiscoverItem(
      image: 'assets/images/image8.png',
      title: '+350 produits\nafro ouest, central',
    ),
    DiscoverItem(
      image: 'assets/images/image6.png',
      title: '+35 Coiffeuses',
    ),
    DiscoverItem(
      image: 'assets/images/image4.png',
      title: '+46 livreurs\naux tarifs compétitifs',
    ),
    DiscoverItem(
      image: 'assets/images/image7.png',
      title: '+120 artisans\npour la maison',
    ),
    DiscoverItem(
      image: 'assets/images/image5.png',
      title: 'Recherche\nde logements',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Troov. ',
                  style: TextStyle(
                    fontSize: sw < 600 ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                TextSpan(
                  text: 'Plus facilement ce que tu cherches.',
                  
                  style: TextStyle(
                    fontSize: sw < 600 ? 13 : 15,
                    color: Colors.grey.shade600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.05 - 8),
            itemCount: _items.length,
            itemBuilder: (ctx, i) => _buildDiscoverCard(_items[i], sw),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDiscoverCard(DiscoverItem item, double sw) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.transparent, // Ensure gesture detector is hit even on transparent spaces
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  item.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
                height: 1.2,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
