import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _gridAnimationController;

  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _gridFadeAnimation;

  PageController _pageController = PageController();
  Timer? _timer;
  int _currentServiceIndex = 0;

  final List<ServiceData> _services = [
    ServiceData(
      icon: Icons.home_repair_service,
      title: 'Réparations',
      description: 'Trouvez des artisans qualifiés pour tous vos travaux de réparation et maintenance',
      images: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
      ],
    ),
    ServiceData(
      icon: Icons.cleaning_services,
      title: 'Ménage',
      description: 'Services de ménage professionnels à domicile pour un intérieur impeccable',
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1527515637462-cff94eecc1b2?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=400&h=300&fit=crop',
      ],
    ),
    ServiceData(
      icon: Icons.local_shipping,
      title: 'Livraison',
      description: 'Livraison rapide et sécurisée pour tous vos besoins du quotidien',
      images: [
        'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      ],
    ),
    ServiceData(
      icon: Icons.restaurant,
      title: 'Restauration',
      description: 'Chefs à domicile et traiteurs pour des moments culinaires exceptionnels',
      images: [
        'https://images.unsplash.com/photo-1556909114-f6e7add3136?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop',
      ],
    ),
    ServiceData(
      icon: Icons.health_and_safety,
      title: 'Santé & Bien-être',
      description: 'Professionnels de santé et bien-être pour prendre soin de vous',
      images: [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1506629905607-48bccf9b0f74?w=400&h=300&fit=crop',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _startServiceCarousel();
  }

  void _initAnimations() {
    _logoAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _gridAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeIn,
    ));

    _gridFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _logoAnimationController.forward();
    await Future.delayed(Duration(milliseconds: 200));
    _contentAnimationController.forward();
    await Future.delayed(Duration(milliseconds: 300));
    _gridAnimationController.forward();
  }

  void _startServiceCarousel() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (_currentServiceIndex < _services.length - 1) {
        _currentServiceIndex++;
      } else {
        _currentServiceIndex = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentServiceIndex,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _contentAnimationController.dispose();
    _gridAnimationController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildImageGrid(List<String> images, double availableHeight) {
    return Container(
      height: availableHeight,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.network(
                          images[0],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(left: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.network(
                          images[1],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
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
          SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.network(
                          images[2],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(left: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.network(
                          images[3],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildServicePage(ServiceData service, double imageHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(height: 8.0),
          _buildImageGrid(service.images, imageHeight),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;
    
    // Calculs dynamiques pour la responsivité
    final headerHeight = isVerySmallScreen ? 110.0 : (isSmallScreen ? 130.0 : 150.0);
    final bottomPanelHeight = isVerySmallScreen ? 140.0 : (isSmallScreen ? 200.0 : 240.0);
    final statsHeight = isVerySmallScreen ? 70.0 : (isSmallScreen ? 80.0 : 90.0);
    final onEstFaitHeight = isVerySmallScreen ? 45.0 : 55.0;
    
    final availableHeight = screenHeight - headerHeight - bottomPanelHeight - statsHeight - onEstFaitHeight - 60; // 60 pour les marges
    final imageHeight = availableHeight * 1;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.05),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  children: [
                    // Header Section
                    SlideTransition(
                      position: _logoSlideAnimation,
                      child: Container(
                        height: headerHeight,
                        padding: EdgeInsets.all(isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo et nom Troov
                            Center(
                              child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                'assets/images/logo_troov-mini.jpeg',
                                width: isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50),
                                height: isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50),
                                fit: BoxFit.contain,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Text(
                                      'Troov.',
                                      style: TextStyle(
                                      fontSize: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                      'tout ce que tu cherches',
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 11.0 : (isSmallScreen ? 13.0 : 16.0),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                      ),
                                    ),
                                    ],
                                  ),
                                  Text(
                                    'là où tes recherches s\'arrêtent.',
                                    style: TextStyle(
                                    fontSize: isVerySmallScreen ? 11.0 : (isSmallScreen ? 13.0 : 16.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    height: 1.2,
                                    ),
                                  ),
                                  ],
                                ),
                                ),
                              ],
                              ),
                            ),
                            SizedBox(height: isVerySmallScreen ? 10.0 : (isSmallScreen ? 20.0 : 40.0)),
                            // Les trois textes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'ton artisan',
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 14.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'tr00v',
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 14.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'un bon plan',
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 14.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Images carousel
                    SizedBox(height: isVerySmallScreen ? 1.0 : (isSmallScreen ? 1.0 : 20.0)),
                    AnimatedBuilder(
                      animation: _contentAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _contentFadeAnimation.value,
                          child: Container(
                            height: imageHeight,
                            child: AnimatedBuilder(
                              animation: _gridAnimationController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _gridFadeAnimation.value,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _services.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentServiceIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return _buildServicePage(_services[index], imageHeight - 16);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: isVerySmallScreen ? 1.0 : (isSmallScreen ? 10.0 : 20.0)),
                    
                    // Section "Encore plus de raisons" - fixe
                    Container(
                      height: statsHeight,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Encore plus de raisons de nous reTROOVer',
                              style: TextStyle(
                                fontSize: isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 15.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // Statistiques en grille 3x2
                          Expanded(
                            child: Column(
                              children: [
                                // Première ligne
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildStatItem('+ 350 artisans', isVerySmallScreen, isSmallScreen)),
                                      Expanded(child: _buildStatItem('+ 8500 membres', isVerySmallScreen, isSmallScreen)),
                                      Expanded(child: _buildStatItem('+ 769 produits', isVerySmallScreen, isSmallScreen)),
                                    ],
                                  ),
                                ),
                                // Deuxième ligne
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildStatItem('+33 partenaires', isVerySmallScreen, isSmallScreen)),
                                      Expanded(child: _buildStatItem('+ 400 collaborateurs', isVerySmallScreen, isSmallScreen)),
                                      Expanded(child: _buildStatItem('+ 4 pays', isVerySmallScreen, isSmallScreen)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: bottomPanelHeight + onEstFaitHeight),
                  ],
                ),
              ),
            ),
            
            // Bottom panels
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section "On est fait pour être ensemble" avec border-top
                  Container(
                    height: onEstFaitHeight,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isVerySmallScreen ? 8.0 : 12.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.8),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'On est fait pour être ensemble',
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 15.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Panneau noir principal
                  Container(
                    constraints: BoxConstraints(
                      minHeight: bottomPanelHeight,
                      maxHeight: bottomPanelHeight,
                    ),
                    padding: EdgeInsets.all(isVerySmallScreen ? 10.0 : (isSmallScreen ? 12.0 : 16.0)),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header du service
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
                              child: Icon(
                                _services[_currentServiceIndex].icon,
                                color: AppTheme.primaryBlue,
                                size: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28),
                              ),
                            ),
                            SizedBox(width: isVerySmallScreen ? 12.0 : 16.0),
                            Expanded(
                              child: Text(
                                _services[_currentServiceIndex].title,
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 14.0 : (isSmallScreen ? 28.0 : 24.0),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Description
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: Text(
                                _services[_currentServiceIndex].description,
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0),
                                  color: Colors.grey[300],
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        
                        // Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(
                                _services.length,
                                (index) => AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 2),
                                  width: _currentServiceIndex == index ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentServiceIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward, 
                                  color: Colors.white,
                                  size: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/home');
                                },
                                constraints: BoxConstraints(
                                  minWidth: isVerySmallScreen ? 35 : 40,
                                  minHeight: isVerySmallScreen ? 35 : 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String text, bool isVerySmallScreen, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.0,
        vertical: 2.0,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 8.0 : (isSmallScreen ? 9.0 : 11.0),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class ServiceData {
  final IconData icon;
  final String title;
  final String description;
  final List<String> images;

  ServiceData({
    required this.icon,
    required this.title,
    required this.description,
    required this.images,
  });
}