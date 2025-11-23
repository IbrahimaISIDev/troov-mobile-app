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
      height: screenWidth < 600 ? 360 : 420,
      margin: EdgeInsets.zero,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Légère ambiance bleutée derrière l'image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 0.9,
                  colors: [
                    Colors.blue.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Image plein écran du bloc, sans arrondi ni ombre
          Positioned.fill(
            child: Image.asset(
              'assets/images/burger.png',
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