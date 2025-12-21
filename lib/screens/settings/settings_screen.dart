import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'sub_screens/notification_settings_screen.dart';
import 'sub_screens/storage_settings_screen.dart';
import 'sub_screens/privacy_settings_screen.dart';
import 'sub_screens/help_center_screen.dart';
import 'sub_screens/about_screen.dart';
import 'sub_screens/profile_edit_screen.dart';
import 'sub_screens/security_settings_screen.dart';
import 'dialogs/feedback_dialog.dart';

class SettingsScreen extends StatefulWidget {
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

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _currentUser;
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

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
            const SizedBox(height: 32),

            // Card du profil utilisateur
            _buildProfileCard(),

            const SizedBox(height: 30),

            // Section Paramètres généraux
            _buildSettingsSection(
              'Paramètres généraux',
              [
                _buildSettingItem(
                  icon: widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  title: 'Mode d\'affichage',
                  subtitle: widget.isDarkMode
                      ? 'Mode sombre activé'
                      : 'Mode clair activé',
                  trailing: Switch(
                    value: widget.isDarkMode,
                    onChanged: (value) => widget.onThemeToggle(),
                    activeColor: AppTheme.primaryBlue,
                  ),
                  onTap: widget.onThemeToggle,
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'Langue',
                  subtitle: _getLanguageName(widget.currentLocale.languageCode),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Gérer vos notifications',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showNotificationSettings(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section Compte
            _buildSettingsSection(
              'Compte',
              [
                _buildSettingItem(
                  icon: Icons.person,
                  title: 'Informations personnelles',
                  subtitle: 'Modifier votre profil',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showProfileEdit(context),
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  title: 'Sécurité',
                  subtitle: 'Mot de passe et sécurité',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showSecuritySettings(context),
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: 'Confidentialité',
                  subtitle: 'Paramètres de confidentialité',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showPrivacySettings(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section Application
            _buildSettingsSection(
              'Application',
              [
                _buildSettingItem(
                  icon: Icons.storage,
                  title: 'Stockage et cache',
                  subtitle: 'Gérer les données locales',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showStorageSettings(context),
                ),
                _buildSettingItem(
                  icon: Icons.update,
                  title: 'Mises à jour',
                  subtitle: 'Version 1.0.0',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _checkForUpdates(context),
                ),
                _buildSettingItem(
                  icon: Icons.info,
                  title: 'À propos',
                  subtitle: 'Informations sur l\'application',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Section Support
            _buildSettingsSection(
              'Support',
              [
                _buildSettingItem(
                  icon: Icons.help,
                  title: 'Centre d\'aide',
                  subtitle: 'FAQ et guides d\'utilisation',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showHelpCenter(context),
                ),
                _buildSettingItem(
                  icon: Icons.feedback,
                  title: 'Avis et retours',
                  subtitle: 'Donnez-nous votre avis ou signalez un problème',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _showFeedbackDialog(context),
                ),
                _buildSettingItem(
                  icon: Icons.contact_support,
                  title: 'Contacter le support',
                  subtitle: 'Besoin d\'aide ?',
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () => _contactSupport(context),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Bouton de déconnexion
            _buildLogoutButton(context),

            const SizedBox(height: 100), // Espace pour la navigation
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String displayName = _currentUser?.fullName ?? 'Utilisateur';
    final String displayEmail = _currentUser?.email ?? 'Non connecté';
    final String initials = displayName.isNotEmpty
        ? displayName
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0] : '')
            .join()
            .toUpperCase()
        : '?';

    // Afficher le badge premium seulement si l'utilisateur est premium ou PRO
    final bool showPremium = _currentUser?.role == UserRole.provider ||
        (_currentUser?.isVerified ?? false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              color: AppTheme.primaryBlue,
              image: (_currentUser?.profileImage != null &&
                      _currentUser!.profileImage!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(_currentUser!.profileImage!),
                      fit: BoxFit.cover,
                      onError: (_, __) {}, // Fallback handled by child
                    )
                  : null,
              gradient: (_currentUser?.profileImage == null ||
                      _currentUser!.profileImage!.isEmpty)
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.7),
                      ],
                    )
                  : null,
            ),
            child: (_currentUser?.profileImage == null ||
                    _currentUser!.profileImage!.isEmpty)
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 15),
          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                if (showPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Bouton d'édition
          IconButton(
            onPressed: () async {
              await _showProfileEdit(context);
              _loadUser(); // Reload after edit
            },
            icon: const Icon(
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
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

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
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
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              onTap: () {
                widget.onLanguageChange('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                widget.onLanguageChange('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Espagnol'),
              onTap: () {
                widget.onLanguageChange('es');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _authService.logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
            child:
                const Text('Déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext? context) {
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen()),
      );
    }
  }

  Future<void> _showProfileEdit(BuildContext? context) async {
    if (context != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
      );
    }
  }

  void _showSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _showStorageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StorageSettingsScreen()),
    );
  }

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Votre application est à jour')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _showHelpCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support à implémenter')),
    );
  }
}
