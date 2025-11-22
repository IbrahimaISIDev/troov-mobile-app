import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isVideoReady = false;

  final Color primaryBlue = const Color(0xFF215E8C);

  @override
  void initState() {
    super.initState();
    _initVideo();
    _initAnimations();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/troov.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoReady = true;
          });
          _videoController.play();
          _videoController.setLooping(false);
          _videoController.setVolume(0.0);

          // Après 5 secondes → on lance l’animation (scale + fade) + navigation
          Future.delayed(const Duration(seconds: 6), () {
            if (mounted) {
              _scaleController.forward();

              // Navigation au même moment que le scale (pas avant)
              Navigator.pushReplacementNamed(context, '/welcome');
            }
          });
        }
      }).catchError((error) {
        setState(() {
          _isVideoReady = false;
        });
      });
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(seconds: 3), // scale dure 3s → total ≈ 9s
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 6.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _isVideoReady
                ? VideoPlayer(_videoController)
                : Image.asset(
                    'assets/images/logo_troov-mini.jpeg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          _buildContent(),
        ],
      ),
    );
  }
}
