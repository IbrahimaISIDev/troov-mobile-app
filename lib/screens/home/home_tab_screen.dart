import 'package:flutter/material.dart';
import 'components/home_tab_header.dart';
import 'components/main_image_section.dart';
import 'components/product_section.dart';
import '../services/services_screen.dart';
import '../notifications/notifications_screen.dart';
import '../space/my_space_screen.dart';

class HomeTabScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  final bool isDarkMode;

  const HomeTabScreen({
    Key? key,
    required this.onThemeToggle,
    required this.onLogout,
    required this.onProfile,
    required this.isDarkMode,
  }) : super(key: key);

    @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
              minWidth: 320,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeTabHeader(
                    onNotificationsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    onProfileTap: onProfile,
                    onMySpaceTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MySpaceScreen(),
                        ),
                      );
                    },
                    onLogoutTap: onLogout,
                    onThemeToggle: onThemeToggle,
                    isDarkMode: isDarkMode,
                  ),
                  MainImageSection(
                    onDiscoverTap: () {},
                  ),
                  _buildHomeTaglineAndStats(context),
                  ProductSection(
                    title: "Troov. le mobilier d'occasion à bon prix",
                    images: const [
                      'assets/images/image.png',
                      'assets/images/image3.png',
                      'assets/images/image4.png',
                    ],
                    onProductTap: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServicesScreen(),
                        ),
                      );
                    },
                    onSeeMoreTap: () {
                      // TODO: action Voir plus Mobilier
                    },
                  ),
                  ProductSection(
                    title: "Troov. transferts d'argent au meilleur prix",
                    images: const [
                      'assets/images/image1.png',
                      'assets/images/image2.png',
                      'assets/images/image5.png',
                    ],
                    onProductTap: (index) {
                      // TODO: action produit Transferts
                    },
                    onSeeMoreTap: () {
                      // TODO: action Voir plus Transferts
                    },
                  ),
                  SizedBox(height: screenWidth * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTaglineAndStats(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    final isVerySmall = h < 600;

    final titleStyle = TextStyle(
      fontSize: isVerySmall ? 14 : (isSmall ? 16 : 18),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final subtitleStyle = TextStyle(
      fontSize: isVerySmall ? 12 : (isSmall ? 13 : 14),
      color: Colors.grey[700],
      height: 1.3,
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "On est dans le même monde\nmais pas dans le même réseau",
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildStatsGrid(isVerySmall, isSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Divider(
            color: Colors.grey[500],
            thickness: 0.5,
            height: 30,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "On est fait pour être ensemble",
            style: TextStyle(
              fontSize: isVerySmall ? 11 : (isSmall ? 12 : 14),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isVerySmall, bool isSmall) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem("+ 350 artisans", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem("+33 partenaires", isVerySmall, isSmall),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem("+ 8500 membres", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem("+ de 400 collaborateurs", isVerySmall, isSmall),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem("+ 769 produits en ligne", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem("+ 4 pays", isVerySmall, isSmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String text, bool isVerySmall, bool isSmall) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isVerySmall ? 9 : (isSmall ? 10 : 11),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}