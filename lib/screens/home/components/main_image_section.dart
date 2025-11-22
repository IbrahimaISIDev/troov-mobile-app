import 'package:flutter/material.dart';

class MainImageSection extends StatelessWidget {
  final VoidCallback onDiscoverTap;

  const MainImageSection({
    Key? key,
    required this.onDiscoverTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth < 600 ? 350 : 400,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: screenWidth < 600 ? 260 : 280,
            height: screenWidth < 600 ? 300 : 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/images/burger.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Erreur de chargement de l'image principale: $error");
                  return Container(
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: screenWidth < 600 ? 100 : 120,
                        color: Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: screenWidth * 0.05,
            child: Semantics(
              button: true,
              label: 'Découvrir maintenant',
              child: GestureDetector(
                onTap: onDiscoverTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenWidth * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Découvrir maintenant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}