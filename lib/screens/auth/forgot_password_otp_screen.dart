import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String login;
  final String method;

  const ForgotPasswordOtpScreen({
    Key? key,
    required this.login,
    required this.method,
  }) : super(key: key);

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<String> _digits = List.filled(6, '');
  bool _isLoading = false;

  final _focusNode = FocusNode();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onKeyTapNative(String value) {
    setState(() {
      for (int i = 0; i < 6; i++) {
        _digits[i] = i < value.length ? value[i] : '';
      }
    });

    if (value.length == 6) {
      _focusNode.unfocus();
    }
  }

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
      final isValid = await authService.verifyResetOtp(widget.login, code);

      if (isValid) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(login: widget.login),
          ),
        );
      } else {
        throw Exception('Code invalide ou expiré');
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
    try {
      final authService = AuthService();
      await authService.forgotPassword(widget.login);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code renvoyé avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                )
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                'CODE DE VÉRIFICATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shield_rounded,
                            size: 120,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Essential
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Veuillez entrer le code que nous venons d\'envoyer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Stack(
                        children: [
                          // Visual boxes
                          Container(
                            color: Colors.transparent,
                            child: _buildOtpRow(),
                          ),
                          // Native semi-hidden textfield overlaying for exact native behavior
                          Positioned.fill(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              autofocus: true,
                              cursorColor: Colors.transparent,
                              showCursor: false,
                              style: const TextStyle(color: Colors.transparent),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                counterText: "",
                                fillColor: Colors.transparent,
                              ),
                              onChanged: _onKeyTapNative,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous n\'avez pas reçu de code ?',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          TextButton(
                            onPressed: _resendCode,
                            child: const Text(
                              'Renvoyer le code',
                              style: TextStyle(
                                color: Colors.amber, // Accent color
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onVerify,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return const Color(0xFF15486d).withOpacity(0.5);
                              }
                              return const Color(0xFF15486d);
                            }),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Continuer',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final value = _digits[index];
        final isFocused = _digits.join().length == index || 
            (index == 5 && _digits.join().length == 6);
        return Container(
          width: 45,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused && _focusNode.hasFocus ? Colors.lightBlueAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        );
      }),
    );
  }
}
