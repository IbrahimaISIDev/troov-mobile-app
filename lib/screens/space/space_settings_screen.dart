import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SpaceSettingsScreen extends StatefulWidget {
  const SpaceSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SpaceSettingsScreen> createState() => _SpaceSettingsScreenState();
}

class _SpaceSettingsScreenState extends State<SpaceSettingsScreen> {
  // Mock configuration state
  bool _coiffureEnabled = true;
  bool _immobilierEnabled = true;
  bool _venteEnabled = false;
  bool _transportEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Services Actifs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activez ou désactivez les services que vous souhaitez proposer dans votre boutique.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildSwitchItem(
            'Coiffure & Beauté',
            'Proposer des services de beauté',
            Icons.brush_rounded,
            _coiffureEnabled,
            (val) => setState(() => _coiffureEnabled = val),
          ),
          _buildSwitchItem(
            'Immobilier (Location/Colocation)',
            'Gérer vos biens immobiliers',
            Icons.home_rounded,
            _immobilierEnabled,
            (val) => setState(() => _immobilierEnabled = val),
          ),
          _buildSwitchItem(
            'Vente de produits',
            'Vendre des articles physiques',
            Icons.shopping_bag_rounded,
            _venteEnabled,
            (val) => setState(() => _venteEnabled = val),
          ),
          _buildSwitchItem(
            'Transport & Livraison',
            'Services de courses et livraisons',
            Icons.local_shipping_rounded,
            _transportEnabled,
            (val) => setState(() => _transportEnabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
      ),
    );
  }
}
