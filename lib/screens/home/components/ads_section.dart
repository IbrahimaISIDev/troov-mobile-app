import 'package:flutter/material.dart';

class AdsSection extends StatelessWidget {
  final Function(int) onAdTap;

  const AdsSection({
    Key? key,
    required this.onAdTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publicités',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
            Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.02),
            child: Container(
              height: screenWidth < 600 ? 160 : 180,
              child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildAdCard(index, screenWidth);
              },
              ),
            ),
            ),
          SizedBox(height: screenWidth * 0.05),
        ],
      ),
    );
  }

  Widget _buildAdCard(int index, double screenWidth) {
    List<Color> adColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
    ];

    return GestureDetector(
      onTap: () => onAdTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: screenWidth < 600 ? 260 : 280,
        margin: EdgeInsets.only(
            right: screenWidth * 0.04, left: screenWidth * 0.0125),
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
            label: 'Publicité ${index + 1}',
            child: Image.asset(
              'assets/images/refri.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                    "Erreur de chargement de l'image publicitaire ${index + 1}: $error");
                return Container(
                  color: adColors[index % adColors.length],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: screenWidth < 600 ? 50 : 60,
                          color: Colors.white70,
                        ),
                        SizedBox(height: screenWidth * 0.025),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Publicité ${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth < 600 ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
