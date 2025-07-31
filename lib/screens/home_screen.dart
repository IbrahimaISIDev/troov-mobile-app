import 'package:flutter/material.dart';
import '../utils/localization.dart';
import '../utils/theme.dart';
import 'search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;
  final bool isDarkMode;
  final Locale currentLocale;

  const HomeScreen({
    Key? key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.isDarkMode,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Troov'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(localizations),
          _buildServicesTab(localizations),
          _buildMessagesTab(localizations),
          _buildProfileTab(localizations),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: localizations.services,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: localizations.messages,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(AppLocalizations localizations) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: localizations.searchServices,
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppTheme.primaryBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
              readOnly: true,
            ),
          ),
          
          SizedBox(height: 24),
          
          // Services populaires
          Text(
            localizations.popularServices,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getServiceIcon(index),
                        size: 40,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getServiceName(index),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 24),
          
          // Prestataires à proximité
          Text(
            localizations.nearbyProviders,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text(
                          'P${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prestataire ${index + 1}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Service de qualité',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' 4.${5 + index}'),
                                SizedBox(width: 16),
                                Icon(Icons.location_on, color: Colors.grey, size: 16),
                                Text(' ${1 + index}.${2 * index}km'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(localizations.bookNow),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            localizations.services,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Cette section sera développée prochainement',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 80,
            color: AppTheme.primaryBlue,
          ),
          SizedBox(height: 16),
          Text(
            localizations.messages,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Messagerie instantanée à venir',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryBlue,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Utilisateur Troov',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Profil utilisateur en développement',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.settings),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode sombre
              SwitchListTile(
                title: Text(localizations.darkMode),
                value: widget.isDarkMode,
                onChanged: (value) {
                  widget.onThemeToggle();
                  Navigator.pop(context);
                },
                activeColor: AppTheme.primaryBlue,
              ),
              
              // Sélection de langue
              ListTile(
                title: Text(localizations.language),
                subtitle: Text(_getLanguageName(widget.currentLocale.languageCode)),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations.french),
                leading: Radio<String>(
                  value: 'fr',
                  groupValue: widget.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onLanguageChange(value);
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
              ListTile(
                title: Text(localizations.english),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: widget.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onLanguageChange(value);
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
              ListTile(
                title: Text(localizations.spanish),
                leading: Radio<String>(
                  value: 'es',
                  groupValue: widget.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      widget.onLanguageChange(value);
                      Navigator.pop(context);
                    }
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }

  IconData _getServiceIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_repair_service;
      case 1:
        return Icons.cleaning_services;
      case 2:
        return Icons.local_shipping;
      case 3:
        return Icons.restaurant;
      case 4:
        return Icons.health_and_safety;
      default:
        return Icons.star;
    }
  }

  String _getServiceName(int index) {
    switch (index) {
      case 0:
        return 'Réparations';
      case 1:
        return 'Ménage';
      case 2:
        return 'Livraison';
      case 3:
        return 'Restauration';
      case 4:
        return 'Santé';
      default:
        return 'Service';
    }
  }
}

