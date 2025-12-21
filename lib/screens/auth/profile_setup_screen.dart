import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import 'preferences_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _pseudoController = TextEditingController();
  bool _isLoading = false;

  void _submitProfile() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.updateProfile({
        'pseudo': _pseudoController.text.trim(),
        // 'photo': ... // TODO: Implement photo upload
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PreferencesScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PreferencesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Ignorer'),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // TODO: Image picker
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ajouter une photo',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _pseudoController,
                decoration: InputDecoration(
                  labelText: 'Choisissez un pseudo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continuer'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
