import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _waveController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _morphController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _morphAnimation;

  final Color primaryBlue = Color(0xFF215E8C);
  final Color accentBlue = Color(0xFF4A90E2);
  
  List<FloatingParticle> particles = [];
  List<WaveData> waves = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();
    _generateWaves();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Animation principale du logo (3 secondes)
    _logoController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animation des vagues (4 secondes en boucle)
    _waveController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    );

    // Animation du texte (2 secondes)
    _textController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation des particules (5 secondes en boucle)
    _particleController = AnimationController(
      duration: Duration(milliseconds: 5000),
      vsync: this,
    );

    // Animation de morphing (6 secondes en boucle)
    _morphController = AnimationController(
      duration: Duration(milliseconds: 6000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Wave animation
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    // Text animations
    _textSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Particle animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Morph animation
    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );
  }

  void _generateParticles() {
    final random = math.Random();
    particles.clear();
    
    for (int i = 0; i < 40; i++) {
      particles.add(FloatingParticle(
        startX: random.nextDouble() * 400 - 200,
        startY: random.nextDouble() * 800 - 400,
        endX: random.nextDouble() * 400 - 200,
        endY: random.nextDouble() * 800 - 400,
        size: random.nextDouble() * 6 + 2,
        speed: random.nextDouble() * 0.8 + 0.3,
        color: [primaryBlue, accentBlue, Colors.white][random.nextInt(3)],
        opacity: random.nextDouble() * 0.7 + 0.3,
        phase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _generateWaves() {
    waves.clear();
    for (int i = 0; i < 3; i++) {
      waves.add(WaveData(
        amplitude: 30.0 + i * 15,
        frequency: 0.02 + i * 0.01,
        phase: i * math.pi / 3,
        speed: 0.5 + i * 0.2,
        opacity: 0.1 - i * 0.02,
      ));
    }
  }

  void _startAnimationSequence() async {
    // Démarrer les animations de fond
    _waveController.repeat();
    _particleController.repeat();
    _morphController.repeat();
    
    // Séquence d'animation principale
    await Future.delayed(Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(Duration(milliseconds: 1500));
    _textController.forward();
    
    // Navigation après l'animation complète
    await Future.delayed(Duration(milliseconds: 5000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _waveController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFEBF4FF),
            Colors.white,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildAnimatedWaves() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WavesPainter(
            waves: waves,
            animation: _waveAnimation.value,
            primaryColor: primaryBlue,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            particles: particles,
            animation: _particleAnimation.value,
            morphAnimation: _morphAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleAnimation,
        _logoRotationAnimation,
        _logoGlowAnimation,
        _morphAnimation,
      ]),
      builder: (context, child) {
        double breathingScale = 1.0 + 0.05 * math.sin(_morphAnimation.value * 4 * math.pi);
        
        return Transform.scale(
          scale: _logoScaleAnimation.value * breathingScale,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * math.pi,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Glow effect principal
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3 * _logoGlowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                  // Glow effect secondaire
                  BoxShadow(
                    color: accentBlue.withOpacity(0.2 * _logoGlowAnimation.value),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                  // Ombre portée
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Image du logo
                    Image.asset(
                      'assets/images/logo_troov-mini.jpeg',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryBlue, accentBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            size: 70,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    // Overlay brillant animé
                    AnimatedBuilder(
                      animation: _morphAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.5, 1.0],
                              transform: GradientRotation(_morphAnimation.value * 2 * math.pi),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textSlideAnimation, _textFadeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre principal avec animation de typing
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryBlue, accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'TROOV',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Sous-titre avec animation
                AnimatedBuilder(
                  animation: _morphAnimation,
                  builder: (context, child) {
                    double glowIntensity = 0.5 + 0.3 * math.sin(_morphAnimation.value * 3 * math.pi);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.1),
                            accentBlue.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: primaryBlue.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.1 * glowIntensity),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        'Trouvez mieux, trouvez proche',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryBlue,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(top: 60),
          child: Column(
            children: [
              // Indicateur de chargement personnalisé
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey[200],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_logoController.value + _textController.value) / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [primaryBlue, accentBlue],
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Points animés
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _morphAnimation,
                    builder: (context, child) {
                      double delay = index * 0.3;
                      double animation = (_morphAnimation.value + delay) % 1.0;
                      double scale = 0.5 + 0.5 * math.sin(animation * 2 * math.pi);
                      
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryBlue.withOpacity(0.6),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(),
          
          // Animated waves
          _buildAnimatedWaves(),
          
          // Floating particles
          _buildFloatingParticles(),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal
                _buildLogo(),
                
                SizedBox(height: 40),
                
                // Texte animé
                _buildAnimatedText(),
                
                // Indicateur de chargement
                _buildLoadingIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Classes pour les données d'animation
class FloatingParticle {
  final double startX, startY, endX, endY, size, speed, opacity, phase;
  final Color color;
  
  FloatingParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.speed,
    required this.color,
    required this.opacity,
    required this.phase,
  });
}

class WaveData {
  final double amplitude, frequency, phase, speed, opacity;
  
  WaveData({
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.speed,
    required this.opacity,
  });
}

// Painter pour les vagues animées
class WavesPainter extends CustomPainter {
  final List<WaveData> waves;
  final double animation;
  final Color primaryColor;

  WavesPainter({
    required this.waves,
    required this.animation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var wave in waves) {
      final paint = Paint()
        ..color = primaryColor.withOpacity(wave.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      
      for (double x = 0; x <= size.width; x += 2) {
        double y = size.height / 2 + 
                  wave.amplitude * math.sin(x * wave.frequency + animation * wave.speed * 2 * math.pi + wave.phase);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour les particules flottantes
class ParticlesPainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double animation;
  final double morphAnimation;

  ParticlesPainter({
    required this.particles,
    required this.animation,
    required this.morphAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (var particle in particles) {
      // Position interpolée avec mouvement sinusoïdal
      double t = (animation * particle.speed + particle.phase) % 1.0;
      double morphOffset = 20 * math.sin(morphAnimation * 2 * math.pi + particle.phase);
      
      double x = center.dx + particle.startX + 
                (particle.endX - particle.startX) * t + 
                morphOffset * math.cos(t * 2 * math.pi);
      double y = center.dy + particle.startY + 
                (particle.endY - particle.startY) * t + 
                morphOffset * math.sin(t * 2 * math.pi);
      
      // Taille animée
      double animatedSize = particle.size * (0.5 + 0.5 * math.sin(animation * 3 * math.pi + particle.phase));
      
      // Opacité animée
      double animatedOpacity = particle.opacity * (0.3 + 0.7 * math.sin(animation * 2 * math.pi + particle.phase));
      
      final paint = Paint()
        ..color = particle.color.withOpacity(animatedOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), animatedSize, paint);
      
      // Effet de halo pour certaines particules
      if (particle.size > 4) {
        final haloPaint = Paint()
          ..color = particle.color.withOpacity(animatedOpacity * 0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), animatedSize * 2, haloPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}