import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class HomeTabHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onSearchTap;

  const HomeTabHeader({
    Key? key,
    required this.onNotificationsTap,
    required this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.05,
        screenWidth * 0.05,
        screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth < 600 ? 36 : 40,
                height: screenWidth < 600 ? 36 : 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo_troov-mini.jpeg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print("Erreur de chargement du logo: $error");
                      return Container(
                        color: Colors.yellow.shade400,
                        child: Center(
                          child: Text(
                            'T',
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.025),
              Text(
                'Troov.',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 22 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Semantics(
                button: true,
                label: 'Notifications',
                child: GestureDetector(
                  onTap: onNotificationsTap,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: AppTheme.primaryBlue,
                      size: screenWidth < 600 ? 22 : 24,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Semantics(
                button: true,
                label: 'Deconnexion',
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                      size: screenWidth < 600 ? 22 : 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}