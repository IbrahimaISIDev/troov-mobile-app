import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/auth_service.dart';
import 'auth/app_lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final AuthService _authService = AuthService();

  bool _isVideoReady = false;

  // Blue background to match the logo video
  final Color primaryBlue = const Color(0xFFD9ECF8);

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

          // Delay to match video length or desired animation timing
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              _scaleController.forward();
              _handleNavigation();
            }
          });
        }
      }).catchError((error) {
        setState(() {
          _isVideoReady = false;
        });
        // Fallback navigation if video fails
        _handleNavigation();
      });
  }

  Future<void> _handleNavigation() async {
    // Check auth state
    print('DEBUG: SplashScreen checking auth state...');
    final isLoggedIn = await _authService.isLoggedIn();
    print('DEBUG: SplashScreen auth state result: $isLoggedIn');

    // Simulate animation wait if needed, but usually parallel is fine
    // waiting for scale animation to complete visual effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (isLoggedIn) {
      print(
          'DEBUG: User is logged in. Navigating to AppLockScreen (isLaunch: true)');
      // Wave-like behavior: If logged in, show App Lock
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AppLockScreen(isLaunch: true),
        ),
      );
    } else {
      print('DEBUG: User is NOT logged in. Navigating to Welcome');
      // Not logged in -> Welcome
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 20.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInExpo),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
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
        child: SizedBox(
          // Removed Container decoration (circle/shadow)
          width: 250, // Slightly larger for better fit
          height: 250,
          child: _isVideoReady
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Image.asset(
                  'assets/images/logo_troov-mini.jpeg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain, // Contain to avoid cropping
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue, // Set background to primaryBlue
      body: Stack(
        children: [
          _buildContent(),
        ],
      ),
    );
  }
}
