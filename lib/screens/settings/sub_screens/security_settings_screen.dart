import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../utils/theme.dart';
import 'package:intl/intl.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  _SecuritySettingsScreenState createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _authService = AuthService();
  bool _isAppLockEnabled = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final hasLock = await _authService.hasAppLock();
      final sessions = await _authService.getSessions();
      setState(() {
        _isAppLockEnabled = hasLock;
        _sessions = sessions;
      });
    } catch (e) {
      print('Error loading security settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      // Activer: Demander un code
      final code = await _showPinDialog('Créer un code secret');
      if (code != null && code.length == 4) {
        await _authService.setAppLockCode(code);
        setState(() => _isAppLockEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verrouillage activé')),
        );
      }
    } else {
      // Désactiver: Demander le code actuel
      final currentCode = await _authService.getAppLockCode();
      if (currentCode == null) return; // Should not happen

      final code = await _showPinDialog('Entrez votre code actuel');
      if (code == currentCode) {
        await _authService.setAppLockCode(''); // Clear code
        setState(() => _isAppLockEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verrouillage désactivé')),
        );
      } else if (code != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Code incorrect'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<String?> _showPinDialog(String title) async {
    String pin = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          onChanged: (value) => pin = value,
          decoration: const InputDecoration(
            hintText: 'Code à 4 chiffres',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, pin),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion de tous les appareils'),
        content: const Text(
            'Voulez-vous vraiment déconnecter tous vos appareils ? Vous devrez vous reconnecter ici.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _authService.logoutAll();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/welcome', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Verrouillage de l\'application'),
                  SwitchListTile(
                    title: const Text('Verrouiller avec un code'),
                    subtitle:
                        const Text('Demander un code secret à l\'ouverture'),
                    value: _isAppLockEnabled,
                    onChanged: _toggleAppLock,
                    activeColor: AppTheme.primaryBlue,
                    secondary: Icon(
                      _isAppLockEnabled ? Icons.lock : Icons.lock_open,
                      color: _isAppLockEnabled
                          ? AppTheme.primaryBlue
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader('Sécurité du compte'),
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: 'Modifier le mot de passe',
                    subtitle: 'Changer votre mot de passe de connexion',
                    onTap: _showUpdatePasswordDialog,
                  ),
                  _buildActionTile(
                    icon: Icons.security,
                    title: 'Modifier le code secret',
                    subtitle: 'Code utilisé pour les transactions sensibles',
                    onTap: _showUpdateSecretCodeDialog,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionHeader('Sessions actives'),
                  const SizedBox(height: 10),
                  if (_sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucune session trouvée (bizarre...)'),
                    )
                  else
                    ..._sessions.map((session) => _buildSessionItem(session)),
                  const SizedBox(height: 30),
                  _buildSectionHeader('Zone de danger'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logoutAll,
                      icon:
                          const Icon(Icons.logout_outlined, color: Colors.red),
                      label: const Text('Se déconnecter de tous les appareils',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showUpdatePasswordDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              decoration:
                  const InputDecoration(labelText: 'Ancien mot de passe'),
              obscureText: true,
            ),
            TextField(
              controller: newController,
              decoration:
                  const InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              try {
                await _authService.updatePassword(
                    oldController.text, newController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mot de passe modifié')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateSecretCodeDialog() async {
    final passController = TextEditingController();
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le code secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passController,
              decoration: const InputDecoration(
                  labelText: 'Votre mot de passe (sécurité)'),
              obscureText: true,
            ),
            TextField(
              controller: codeController,
              decoration:
                  const InputDecoration(labelText: 'Nouveau code (4 chiffres)'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (codeController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Le code doit faire 4 chiffres')));
                return;
              }
              try {
                await _authService.updateSecretCode(
                    passController.text, codeController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code secret modifié')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session) {
    final isCurrent = session['isCurrentSession'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.smartphone,
          color: isCurrent ? Colors.green : Colors.grey,
        ),
        title: Text(session['device'] ?? 'Inconnu'),
        subtitle: Text(
            '${session['location'] ?? 'Inconnu'} • ${session['lastActive']}'),
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Actuel',
                    style: TextStyle(fontSize: 12, color: Colors.green)),
              )
            : null,
      ),
    );
  }
}
