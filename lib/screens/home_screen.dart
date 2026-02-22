import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';
import 'home/home_tab_screen.dart';
import 'transfert/transfer_screen.dart';
import 'services/services_screen.dart';
import 'settings/settings_screen.dart';
import 'welcome_screen.dart' hide ServiceData;
import 'troov/troov_screen.dart';
import '../models/service_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;
  final bool isDarkMode;
  final Locale currentLocale;

  const HomeScreen({
    Key? key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.isDarkMode,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  ServiceCategory? _selectedServiceCategory;
  final GlobalKey _servicesIconKey = GlobalKey();
  bool _hideBottomBar = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeTabScreen(
            onThemeToggle: widget.onThemeToggle,
            onLogout: () async {
              await AuthService().logout();

              if (!mounted) return;

              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('À bientôt'),
                  duration: Duration(milliseconds: 800),
                ),
              );
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (route) => false,
              );
            },
            onProfile: () {
              setState(() {
                _currentIndex = 4;
              });
              _pageController.animateToPage(
                4,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            onNavigateToServices: () {
              setState(() {
                _currentIndex = 3;
              });
              _pageController.animateToPage(
                3,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            onNavigateToTransfer: () {
              setState(() {
                _currentIndex = 1;
              });
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            isDarkMode: widget.isDarkMode,
          ),
          TransferScreen(),
          TroovScreen(isActive: _currentIndex == 2),
          ServicesScreen(
            initialCategory: _selectedServiceCategory,
            onHideBottomBar: (hide) {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    _hideBottomBar = hide;
                  });
                }
              });
            },
          ),
          SettingsScreen(
            onThemeToggle: widget.onThemeToggle,
            onLanguageChange: widget.onLanguageChange,
            isDarkMode: widget.isDarkMode,
            currentLocale: widget.currentLocale,
          ),
        ],
      ),
      extendBody:
          true, // Allow content to go behind the transparent floating bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    if (_hideBottomBar) return const SizedBox.shrink();

    final bool isTroovTab = _currentIndex == 2;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + (isTroovTab ? 0 : 5),
        left: 10,
        right: 10,
      ),
      child: SizedBox(
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: isTroovTab ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: isTroovTab
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: _buildNavItem(
                          0, Icons.home_rounded, 'Accueil', isTroovTab)),
                  Expanded(
                      child: _buildNavItem(
                          1, Icons.compare_arrows, 'Transfert', isTroovTab)),
                  const SizedBox(width: 70), // Space for center button
                  Expanded(
                      child: _buildNavItem(
                          3,
                          _selectedServiceCategory?.icon ??
                              Icons.design_services_rounded,
                          _selectedServiceCategory?.name ?? 'Services',
                          isTroovTab)),
                  Expanded(
                      child: _buildNavItem(
                          4, Icons.manage_accounts, 'Paramètres', isTroovTab)),
                ],
              ),
            ),
            // Center overlapping button
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = 2);
                  _pageController.animateToPage(2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isTroovTab ? Colors.transparent : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: isTroovTab
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  padding: EdgeInsets.all(isTroovTab ? 0 : 12),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo_troov-mini.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.play_circle_fill_rounded,
                          color: isTroovTab ? Colors.white : Colors.white,
                          size: 30,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OverlayEntry? _overlayEntry;

  void _hideServicesCategoriesDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showServicesCategoriesDropdown() {
    if (_overlayEntry != null) {
      _hideServicesCategoriesDropdown();
      return;
    }

    final categories = ServiceData.getCategories();
    final RenderBox? renderBox =
        _servicesIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the popup width and position
    final popupWidth = 220.0;
    // Try to center it above the icon, but keep within screen bounds
    double leftPosition = offset.dx + (size.width / 2) - (popupWidth / 2);
    if (leftPosition < 10) leftPosition = 10;
    if (leftPosition + popupWidth > MediaQuery.of(context).size.width - 10) {
      leftPosition = MediaQuery.of(context).size.width - popupWidth - 10;
    }

    // Bottom of the popup should be exactly at the top of the icon (with a small margin)
    final bottomPosition = screenHeight - offset.dy + 10;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideServicesCategoriesDropdown,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: leftPosition,
              bottom: bottomPosition,
              width: popupWidth,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Material(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          leading: const Icon(Icons.design_services_rounded,
                              color: Colors.blueGrey, size: 20),
                          title: const Text('Tous les services',
                              style: TextStyle(fontSize: 14)),
                          onTap: () {
                            _hideServicesCategoriesDropdown();
                            setState(() {
                              _selectedServiceCategory = null;
                              _currentIndex = 3;
                            });
                            _pageController.jumpToPage(3);
                          },
                        ),
                        const Divider(height: 1),
                        ...categories
                            .map((category) => ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  leading: Icon(category.icon,
                                      color: category.color, size: 20),
                                  title: Text(category.name,
                                      style: const TextStyle(fontSize: 14)),
                                  onTap: () {
                                    _hideServicesCategoriesDropdown();
                                    setState(() {
                                      _selectedServiceCategory = category;
                                      _currentIndex = 3;
                                    });
                                    _pageController.jumpToPage(3);
                                  },
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, bool isTroovTab) {
    final isSelected = _currentIndex == index;
    final defaultUnselectedColor = Colors.grey[600]!;
    final iconColor = isSelected
        ? AppTheme.primaryBlue
        : (isTroovTab ? Colors.white70 : defaultUnselectedColor);
    final labelColor = isSelected
        ? AppTheme.primaryBlue
        : (isTroovTab ? Colors.white70 : defaultUnselectedColor);

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      },
      onLongPress: () {
        if (index == 3) {
          _showServicesCategoriesDropdown();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                key: index == 3 ? _servicesIconKey : null,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: labelColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
