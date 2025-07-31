import 'package:flutter/material.dart';
import '../utils/localization.dart';
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

  Widget _buildImageGrid(List<String> images) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.35; // Réduit pour s'adapter aux petits écrans
    
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
                      borderRadius: BorderRadius.circular(16), // Réduit pour petits écrans
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10, // Réduit
                              offset: Offset(0, 5), // Réduit
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
                                  size: 24, // Réduit
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
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
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
                                  size: 24,
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
          SizedBox(height: 6), // Réduit
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
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
                                  size: 24,
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
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
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
                                  size: 24,
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

  Widget _buildServicePage(ServiceData service) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildImageGrid(service.images),
          SizedBox(height: 300.0), // Espacement avec le cadre du bas
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.05),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo_troov-mini.jpeg',
                                  width: isSmallScreen ? 40 : 50,
                                  height: isSmallScreen ? 40 : 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Troov',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                        Text(
                          'Bienvenue sur Troov',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 30,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Votre allié pour dénicher des services fiables près de chez vous.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0), // Espacement avec les images
                Expanded(
                  child: AnimatedBuilder(
                    animation: _contentAnimationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _contentFadeAnimation.value,
                        child: Column(
                          children: [
                            Expanded(
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
                                        return _buildServicePage(_services[index]);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _services[_currentServiceIndex].icon,
                            color: AppTheme.primaryBlue,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 16.0 : 24.0),
                        Expanded(
                          child: Text(
                            _services[_currentServiceIndex].title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22.0 : 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                      child: Text(
                        _services[_currentServiceIndex].description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            _services.length,
                            (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              width: _currentServiceIndex == index ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentServiceIndex == index
                                    ? AppTheme.primaryBlue
                                    : AppTheme.primaryBlue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward, 
                              color: AppTheme.primaryBlue,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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