import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../services/auth_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  // Existing toggles
  bool _profileVisible = true;
  bool _statusVisible = true;
  bool _readReceipts = true;

  // New Preferences
  List<String> _selectedServices = [];
  List<String> _selectedPayments = [];

  final List<String> _availableServices = [
    'Coiffure',
    'Couture',
    'Location',
    'Vente',
    'Transport',
  ];

  final List<String> _availablePayments = [
    'Orange Money',
    'Wave',
    'Free Money',
    'Carte Bancaire',
    'Cash',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _selectedServices = List<String>.from(user.preferences ?? []);
          _selectedPayments = List<String>.from(user.paymentMethods ?? []);
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePreferences() async {
    setState(() => _isLoading = true);
    try {
      await _authService.updateProfile({
        'preferences': _selectedServices,
        'paymentMethods': _selectedPayments,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préférences mises à jour')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleService(String service, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedServices.contains(service)) {
          _selectedServices.add(service);
        }
      } else {
        _selectedServices.remove(service);
      }
    });
    _updatePreferences();
  }

  void _togglePayment(String payment, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedPayments.contains(payment)) {
          _selectedPayments.add(payment);
        }
      } else {
        _selectedPayments.remove(payment);
      }
    });
    _updatePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confidentialité & Préférences',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading && _selectedServices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildInfoMessage(),
                const SizedBox(height: 30),
                _buildSectionHeader('Visibilité'),
                _buildSwitchTile(
                  title: 'Profil public',
                  subtitle: 'Tout le monde peut voir votre profil',
                  value: _profileVisible,
                  onChanged: (val) => setState(() => _profileVisible = val),
                ),
                _buildSwitchTile(
                  title: 'Statut en ligne',
                  subtitle: 'Afficher quand vous êtes actif',
                  value: _statusVisible,
                  onChanged: (val) => setState(() => _statusVisible = val),
                ),
                const SizedBox(height: 30),
                _buildSectionHeader('Services Clés'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableServices.map((service) {
                    final isSelected = _selectedServices.contains(service);
                    return FilterChip(
                      label: Text(service),
                      selected: isSelected,
                      onSelected: (val) => _toggleService(service, val),
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryBlue,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                _buildSectionHeader('Moyens de Paiement Préférés'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availablePayments.map((payment) {
                    final isSelected = _selectedPayments.contains(payment);
                    return FilterChip(
                      label: Text(payment),
                      selected: isSelected,
                      onSelected: (val) => _togglePayment(payment, val),
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryBlue,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                _buildActionTile(
                  icon: Icons.block,
                  title: 'Utilisateurs bloqués',
                  subtitle: '0 contacts bloqués',
                  onTap: () {},
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.privacy_tip, color: AppTheme.primaryBlue),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              'Gérez vos préférences et votre visibilité pour une expérience sur mesure.',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
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
}
