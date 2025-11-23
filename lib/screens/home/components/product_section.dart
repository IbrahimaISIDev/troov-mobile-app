import 'package:flutter/material.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<String> images;
  final Function(int) onProductTap;
  final VoidCallback onSeeMoreTap;

  const ProductSection({
    Key? key,
    required this.title,
    required this.images,
    required this.onProductTap,
    required this.onSeeMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Troov. ',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: title.replaceFirst('Troov. ', ''),
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 14 : 16,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Semantics(
                button: true,
                label: 'Voir plus',
                child: TextButton(
                  onPressed: onSeeMoreTap,
                  child: Text(
                    'Voir plus',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 12 : 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.025),
          Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return _buildSimpleProductCard(
                  images[index],
                  screenWidth,
                  index,
                );
              },
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
        ],
      ),
    );
  }

  Widget _buildSimpleProductCard(String imagePath, double screenWidth, int index) {
    return GestureDetector(
      onTap: () => onProductTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: screenWidth < 600 ? 140 : 120,
        height: screenWidth < 600 ? 140 : 120,
        margin: EdgeInsets.only(
          right: screenWidth * 0.04,
          left: screenWidth * 0.0125,
          bottom: screenWidth * 0.025,
          top: screenWidth * 0.0125,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Semantics(
            image: true,
            label: 'Produit ${index + 1}',
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Erreur de chargement de l'image produit: $error");
                return Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: screenWidth < 600 ? 35 : 40,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}