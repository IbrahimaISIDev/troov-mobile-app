import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../models/user.dart' show ServiceCategory;
import '../../../services/auth_service.dart';
import 'onboarding_provider_screen.dart';

class OnboardingCategoriesScreen extends StatefulWidget {
  final String acquisitionSource;

  const OnboardingCategoriesScreen({
    Key? key,
    required this.acquisitionSource,
  }) : super(key: key);

  @override
  State<OnboardingCategoriesScreen> createState() => _OnboardingCategoriesScreenState();
}

class _OnboardingCategoriesScreenState extends State<OnboardingCategoriesScreen> {
  final List<String> _selectedCategories = [];
  bool _isLoading = false;

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _submit(bool skip) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.updateProfile({
        'acquisitionSource': widget.acquisitionSource,
        'preferences': skip ? [] : _selectedCategories,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingProviderScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can use the enum values from ServiceCategory
    final categories = ServiceCategory.values;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _submit(true),
            child: const Text('Passer', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Quelles catégories vous intéressent ?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nous vous recommanderons des services pertinents.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 16.0,
                    children: categories.map((cat) {
                      final categoryName = cat.name.toUpperCase();
                      final isSelected = _selectedCategories.contains(categoryName);

                      return GestureDetector(
                        onTap: () => _toggleCategory(categoryName),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Text(
                            _getCategoryDisplayName(cat),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedCategories.isEmpty || _isLoading)
                        ? null
                        : () => _submit(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continuer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.cleaning: return 'Nettoyage';
      case ServiceCategory.repair: return 'Réparation';
      case ServiceCategory.delivery: return 'Livraison';
      case ServiceCategory.cooking: return 'Cuisine';
      case ServiceCategory.health: return 'Santé & Bien-être';
      case ServiceCategory.beauty: return 'Beauté';
      case ServiceCategory.education: return 'Éducation';
      case ServiceCategory.transport: return 'Transport';
      case ServiceCategory.gardening: return 'Jardinage';
      case ServiceCategory.technology: return 'Technologie/Tech';
    }
  }
}
