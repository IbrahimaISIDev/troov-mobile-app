import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class HomeTabHeader extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onMySpaceTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeTabHeader({
    Key? key,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onMySpaceTap,
    required this.onLogoutTap,
    required this.onThemeToggle,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenWidth * 0.05,
        screenWidth * 0.05,
        screenWidth * 0.03,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth < 600 ? 32 : 36,
                height: screenWidth < 600 ? 32 : 36,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo_troov-mini.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Troov.',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            children: [
              PopupMenuButton<String>(
                elevation: 8,
                offset: Offset(0, screenWidth * 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'notif1',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.notifications_active_rounded, size: 20),
                      title: Text('Nouveau message'),
                      subtitle: Text('Tu as reçu un nouveau message.'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'notif2',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.discount_rounded, size: 20),
                      title: Text('Promo sur tes services'),
                      subtitle: Text('Profite de nouvelles offres personnalisées.'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'notif3',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.home_repair_service_rounded, size: 20),
                      title: Text('Nouvel artisan disponible'),
                      subtitle: Text('Un nouvel artisan correspond à ta recherche.'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'see_more',
                    child: Center(
                      child: Text(
                        'Voir plus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'see_more') {
                    onNotificationsTap();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.022),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: AppTheme.primaryBlue,
                    size: screenWidth < 600 ? 20 : 22,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              PopupMenuButton<String>(
                elevation: 8,
                offset: Offset(0, screenWidth * 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      onProfileTap();
                      break;
                    case 'myspace':
                      onMySpaceTap();
                      break;
                    case 'theme':
                      onThemeToggle();
                      break;
                    case 'logout':
                      onLogoutTap();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_outline_rounded, size: 20),
                      title: Text('Profil'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'myspace',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.storefront_rounded, size: 20),
                      title: Text('Mon espace'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'theme',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.color_lens_outlined, size: 20),
                      title: Text('Thème'),
                      trailing: Icon(
                        isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 18,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.logout_rounded, size: 20),
                      title: Text('Déconnexion'),
                    ),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.015,
                    vertical: screenWidth * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth < 600 ? 14 : 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const AssetImage('assets/images/profile.png'),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: screenWidth < 600 ? 20 : 22,
                        color: Colors.grey.shade700,
                      ),
                    ],
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