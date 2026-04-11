import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import 'onboarding_categories_screen.dart';

class OnboardingSourceScreen extends StatefulWidget {
  const OnboardingSourceScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingSourceScreen> createState() => _OnboardingSourceScreenState();
}

class _OnboardingSourceScreenState extends State<OnboardingSourceScreen> {
  String? _selectedSource;

  final List<Map<String, dynamic>> _sources = [
    {
      'id': 'instagram',
      'title': 'Instagram',
      'icon': 'assets/images/instagram_icon.png', // Fallback to network or icon if needed
      'color': Colors.purple
    },
    {
      'id': 'facebook',
      'title': 'Facebook',
      'icon': 'assets/images/facebook_icon.png',
      'color': Colors.blue
    },
    {
      'id': 'tiktok',
      'title': 'Tiktok',
      'icon': 'assets/images/tiktok_icon.png',
      'color': Colors.black
    },
    {
      'id': 'google',
      'title': 'Google',
      'icon': 'assets/images/google_icon.png',
      'color': Colors.red
    },
    {
      'id': 'friend',
      'title': 'Recommandation',
      'icon': 'assets/images/friend_icon.png',
      'color': Colors.indigo
    },
    {
      'id': 'other',
      'title': 'Autre',
      'icon': 'assets/images/other_icon.png',
      'color': Colors.grey
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comment nous avez-vous connus ?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cela nous aide à nous améliorer.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _sources.length,
                  itemBuilder: (context, index) {
                    final source = _sources[index];
                    final isSelected = _selectedSource == source['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSource = source['id'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Utilisateur de placeholder simple si l'image manque
                            Icon(
                              _getIconData(source['id']),
                              color: source['color'],
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              source['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedSource == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingCategoriesScreen(
                                  acquisitionSource: _selectedSource!,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
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

  IconData _getIconData(String id) {
    switch (id) {
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_note;
      case 'google':
        return Icons.search;
      case 'friend':
        return Icons.group;
      case 'other':
      default:
        return Icons.more_horiz;
    }
  }
}
