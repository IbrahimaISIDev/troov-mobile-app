import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class AppLockScreen extends StatefulWidget {
  final bool isLaunch;
  const AppLockScreen({Key? key, this.isLaunch = false}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final List<String> _digits = List.filled(4, '');
  final AuthService _authService = AuthService();
  final LocalAuthentication auth = LocalAuthentication();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck && isDeviceSupported;
      });

      if (_canCheckBiometrics) {
        // Auto-trigger biometrics on load
        _authenticateWithBiometrics();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à Troov',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        _unlock();
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Biometrics not available
      }
    }
  }

  void _unlock() {
    if (mounted) {
      if (widget.isLaunch) {
        // Fresh launch: replace to Home
        // Note: HomeScreen creation requires args. Ideally use named route if main.dart sets it up,
        // but HomeScreen constructor is complex. Let's redirect to named /home if it exists,
        // or build it. For now, assuming /home or similar standard route pattern,
        // or simply pushReplacement to the configured home widget.
        // Let's assume standard named route '/home' is NOT setup with args in main.dart easily,
        // so we rely on main.dart's home builder or pushAndRemoveUntil.
        // Actually, HomeScreen requires params. Let's check main.dart for how it's built or if we can use a wrapper.
        // Simpler: Push replacement to '/' or '/home' if configured, but HomeScreen has required args.
        // Best practice: Use Navigator.pushNamedAndRemoveUntil(context, '/home', ...) if registered.
        // If not registered, we must construct it.
        // However, we don't have the args here (theme callbacks etc).
        // TRICK: We can just pop IF the main.dart handles the initial route based on auth?
        // No, Splash pushed us here. So "underneath" is Splash.
        // We must navigate to the main app skeleton.
        // Let's try named route '/home', assuming main.dart registers it or onGenerateRoute handles it.
        // If not, we might need to fix main.dart to provide a clean route for Home.
        // Let's use named route '/home' and ensure main.dart supports it.
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Resume: just pop the lock screen
        Navigator.of(context).pop();
      }
    }
  }

  void _onKeyTap(String value) {
    setState(() {
      _errorMessage = '';
      if (value == 'back') {
        for (int i = 3; i >= 0; i--) {
          if (_digits[i].isNotEmpty) {
            _digits[i] = '';
            break;
          }
        }
      } else {
        for (int i = 0; i < 4; i++) {
          if (_digits[i].isEmpty) {
            _digits[i] = value;
            if (i == 3) {
              _verifyCode();
            }
            break;
          }
        }
      }
    });
  }

  Future<void> _verifyCode() async {
    final code = _digits.join();
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _authService.verifyAppLockCode(code);
      if (isValid) {
        _unlock();
      } else {
        setState(() {
          _errorMessage = 'Code incorrect';
          _digits.fillRange(0, 4, '');
        });
        HapticFeedback.vibrate();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de vérification';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(isSmallScreen),
                      SizedBox(height: isSmallScreen ? 30 : 50),
                      _buildPinRow(),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (_canCheckBiometrics) ...[
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: _authenticateWithBiometrics,
                          icon: Icon(Icons.fingerprint,
                              color: AppTheme.primaryBlue, size: 32),
                          label: Text('Utiliser l\'empreinte',
                              style: TextStyle(color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _buildKeypad(),
              TextButton(
                onPressed: _logout,
                child: Text(
                  'Code oublié ? Se déconnecter',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    // Keep existing header
    final logoSize = isSmallScreen ? 70.0 : 90.0;
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_troov-mini.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.lock_outline_rounded,
                  size: isSmallScreen ? 32 : 40,
                  color: AppTheme.primaryBlue,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bon retour !',
          style: TextStyle(
            fontSize: isSmallScreen ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez votre code secret ou utilisez votre empreinte',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinRow() {
    // Keep existing implementation
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = _digits[index].isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppTheme.primaryBlue : Colors.grey[300],
            border: Border.all(
              color: isFilled ? AppTheme.primaryBlue : Colors.grey[300]!,
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    // Keep existing implementation
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'back'];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = (constraints.maxWidth - 2 * 24) / 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 0; row < 4; row++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int col = 0; col < 3; col++)
                        _buildKeyButton(
                          keys[row * 3 + col],
                          buttonSize,
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKeyButton(String value, double size) {
    // Keep existing implementation
    if (value.isEmpty) {
      return SizedBox(width: size, height: size * 0.7);
    }

    return SizedBox(
      width: size,
      height: size * 0.7,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black87,
          shape: const CircleBorder(),
        ),
        onPressed: () => _onKeyTap(value),
        child: value == 'back'
            ? const Icon(Icons.backspace_outlined)
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
