import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _promoEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('notifications_push') ?? true;
      _emailEnabled = prefs.getBool('notifications_email') ?? true;
      _smsEnabled = prefs.getBool('notifications_sms') ?? false;
      _promoEnabled = prefs.getBool('notifications_promo') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Canaux de communication'),
          _buildSwitchTile(
            title: 'Notifications Push',
            subtitle: 'Recevoir des alertes sur votre appareil',
            value: _pushEnabled,
            onChanged: (value) {
              setState(() => _pushEnabled = value);
              _savePreference('notifications_push', value);
            },
          ),
          _buildSwitchTile(
            title: 'E-mails',
            subtitle: 'Recevoir des mises à jour par e-mail',
            value: _emailEnabled,
            onChanged: (value) {
              setState(() => _emailEnabled = value);
              _savePreference('notifications_email', value);
            },
          ),
          _buildSwitchTile(
            title: 'SMS',
            subtitle: 'Recevoir des SMS pour les alertes urgentes',
            value: _smsEnabled,
            onChanged: (value) {
              setState(() => _smsEnabled = value);
              _savePreference('notifications_sms', value);
            },
          ),
          SizedBox(height: 30),
          _buildSectionHeader('Types de notifications'),
          _buildSwitchTile(
            title: 'Offres et promotions',
            subtitle: 'Recevoir des offres spéciales et promotions',
            value: _promoEnabled,
            onChanged: (value) {
              setState(() => _promoEnabled = value);
              _savePreference('notifications_promo', value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}
