import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;
  final bool isDarkMode;
  final Locale currentLocale;

  const SettingsScreen({
    Key? key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.isDarkMode,
    required this.currentLocale,
  }) : super(key: key);
  
  get context => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),
            
            // Card du profil utilisateur
            _buildProfileCard(),
            
            SizedBox(height: 30),
            
            // Section Paramètres généraux
            _buildSettingsSection(
              'Paramètres généraux',
              [
                _buildSettingItem(
                  icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  title: 'Mode d\'affichage',
                  subtitle: isDarkMode ? 'Mode sombre activé' : 'Mode clair activé',
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => onThemeToggle(),
                    activeColor: AppTheme.primaryBlue,
                  ),
                  onTap: onThemeToggle,
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'Langue',
                  subtitle: _getLanguageName(currentLocale.languageCode),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Gérer vos notifications',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showNotificationSettings(context),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Section Compte
            _buildSettingsSection(
              'Compte',
              [
                _buildSettingItem(
                  icon: Icons.person,
                  title: 'Informations personnelles',
                  subtitle: 'Modifier votre profil',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showProfileEdit(context),
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  title: 'Sécurité',
                  subtitle: 'Mot de passe et sécurité',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showSecuritySettings(context),
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: 'Confidentialité',
                  subtitle: 'Paramètres de confidentialité',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showPrivacySettings(context),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Section Application
            _buildSettingsSection(
              'Application',
              [
                _buildSettingItem(
                  icon: Icons.storage,
                  title: 'Stockage et cache',
                  subtitle: 'Gérer les données locales',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showStorageSettings(context),
                ),
                _buildSettingItem(
                  icon: Icons.update,
                  title: 'Mises à jour',
                  subtitle: 'Version 1.0.0',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _checkForUpdates(context),
                ),
                _buildSettingItem(
                  icon: Icons.info,
                  title: 'À propos',
                  subtitle: 'Informations sur l\'application',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Section Support
            _buildSettingsSection(
              'Support',
              [
                _buildSettingItem(
                  icon: Icons.help,
                  title: 'Centre d\'aide',
                  subtitle: 'FAQ et guides d\'utilisation',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showHelpCenter(context),
                ),
                _buildSettingItem(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  subtitle: 'Donnez-nous votre avis',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _showFeedbackDialog(context),
                ),
                _buildSettingItem(
                  icon: Icons.contact_support,
                  title: 'Contacter le support',
                  subtitle: 'Besoin d\'aide ?',
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _contactSupport(context),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // Bouton de déconnexion
            _buildLogoutButton(),
            
            SizedBox(height: 100), // Espace pour la navigation
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo de profil
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.primaryBlue.withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'JD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bouton d'édition
          IconButton(
            onPressed: () => _showProfileEdit(null),
            icon: Icon(
              Icons.edit_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        icon: Icon(Icons.logout_rounded),
        label: Text(
          'Se déconnecter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'wo':
        return 'Wolof';
      default:
        return 'Français';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Français'),
              onTap: () {
                onLanguageChange('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English'),
              onTap: () {
                onLanguageChange('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Espagnol'),
              onTap: () {
                onLanguageChange('es');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // naviguer vers la page welcome
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            child: Text('Déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext? context) {
    // Navigation vers les paramètres de notification
  }

  void _showProfileEdit(BuildContext? context) {
    // Navigation vers l'édition du profil
  }

  void _showSecuritySettings(BuildContext context) {
    // Navigation vers les paramètres de sécurité
  }

  void _showPrivacySettings(BuildContext context) {
    // Navigation vers les paramètres de confidentialité
  }

  void _showStorageSettings(BuildContext context) {
    // Navigation vers les paramètres de stockage
  }

  void _checkForUpdates(BuildContext context) {
    // Vérification des mises à jour
  }

  void _showAboutDialog(BuildContext context) {
    // Affichage des informations de l'application
  }

  void _showHelpCenter(BuildContext context) {
    // Navigation vers le centre d'aide
  }

  void _showFeedbackDialog(BuildContext context) {
    // Affichage du formulaire de feedback
  }

  void _contactSupport(BuildContext context) {
    // Contact du support
  }
}