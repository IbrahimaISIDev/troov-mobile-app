import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  List<dynamic> _categories = [];
  final Set<String> _selectedCategories = {};
  String? _acquisitionSource;
  bool _isLoading = true;

  final List<String> _acquisitionSources = [
    'Réseaux sociaux (Facebook, Instagram...)',
    'Amis / Famille',
    'Publicité en ligne',
    'Recherche Google',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/services/categories/active'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur chargement catégories');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback or empty state
      }
    }
  }

  void _submitPreferences() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.updateProfile({
        'preferences': _selectedCategories.toList(),
        'acquisitionSource': _acquisitionSource,
      });

      if (mounted) {
        // Navigate to Home eventually
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Préférences'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false),
            child: const Text('Passer'),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quels services vous intéressent ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((category) {
                        final isSelected =
                            _selectedCategories.contains(category['id']);
                        return FilterChip(
                          label: Text(category['name']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category['id']);
                              } else {
                                _selectedCategories.remove(category['id']);
                              }
                            });
                          },
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryBlue,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Où nous avez-vous connus ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _acquisitionSource,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      items: _acquisitionSources.map((source) {
                        return DropdownMenuItem(
                          value: source,
                          child: Text(source),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _acquisitionSource = value;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _submitPreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Terminer'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
