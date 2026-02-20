import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';
import 'subscription_screen.dart';
import 'profile_setup_screen.dart';

class OtpCodeScreen extends StatefulWidget {
  final String? phone;
  final String? login; // Email ou Phone pour reset password
  final bool isAccountActivation;
  final bool isResetPassword;
  final bool isProvider;

  const OtpCodeScreen({
    Key? key,
    this.phone,
    this.login,
    this.isAccountActivation = false,
    this.isResetPassword = false,
    this.isProvider = false,
  }) : super(key: key);

  @override
  State<OtpCodeScreen> createState() => _OtpCodeScreenState();
}

class _OtpCodeScreenState extends State<OtpCodeScreen> {
  final List<String> _digits = List.filled(6, '');

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'back') {
        for (int i = 5; i >= 0; i--) {
          if (_digits[i].isNotEmpty) {
            _digits[i] = '';
            break;
          }
        }
      } else {
        for (int i = 0; i < 6; i++) {
          if (_digits[i].isEmpty) {
            _digits[i] = value;
            break;
          }
        }
      }
    });
  }

  bool _isLoading = false;

  void _onVerify() async {
    final code = _digits.join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();

    try {
      if (widget.isAccountActivation && widget.phone != null) {
        // Activation de compte
        final isValid =
            await authService.verifyRegisterOtp(widget.phone!, code);

        if (isValid) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte activé avec succès !')),
          );

          if (widget.isProvider) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfileSetupScreen()),
            );
          }
        } else {
          throw Exception('Code invalide ou expiré');
        }
      } else if (widget.isResetPassword && widget.login != null) {
        // Réinitialisation de mot de passe
        final isValid = await authService.verifyResetOtp(widget.login!, code);

        if (isValid) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(login: widget.login!),
            ),
          );
        } else {
          throw Exception('Code invalide ou expiré');
        }
      } else {
        // Fallback or Error
        throw Exception(
            'Mode de vérification non supporté ou paramètres manquants');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resendCode() async {
    if (widget.phone != null) {
      try {
        final authService = AuthService();
        await authService.sendRegisterOtp(widget.phone!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code renvoyé avec succès.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(isSmallScreen),
                      const SizedBox(height: 24),
                      _buildOtpRow(isSmallScreen),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _onVerify,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Vérifier le code'),
                        ),
                      ),
                      if (widget.isAccountActivation) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _resendCode,
                          child: const Text('Renvoyer le code'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    final logoSize = isSmallScreen ? 70.0 : 90.0;

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.7, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                        Icons.shield_rounded,
                        size: isSmallScreen ? 32 : 40,
                        color: AppTheme.primaryBlue,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: isSmallScreen ? 20 : 26),
        Text(
          'Code de vérification',
          style: TextStyle(
            fontSize: isSmallScreen ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.isAccountActivation
              ? 'Entrez le code envoyé au ${widget.phone ?? "numéro indiqué"}.'
              : 'Entrez le code à 6 chiffres envoyé à votre email.',
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpRow(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final value = _digits[index];
        return Container(
          width: 44,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: value.isNotEmpty
                  ? AppTheme.primaryBlue
                  : Colors.grey.shade300,
              width: value.isNotEmpty ? 2 : 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'back'];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = (constraints.maxWidth - 2 * 12) / 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 0; row < 4; row++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
    if (value.isEmpty) {
      return SizedBox(width: size, height: size * 0.7);
    }

    IconData? icon;
    String? label;

    if (value == 'back') {
      icon = Icons.backspace_rounded;
    } else {
      label = value;
    }

    return SizedBox(
      width: size,
      height: size * 0.7,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _onKeyTap(value),
        child: icon != null
            ? Icon(icon)
            : Text(
                label!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
