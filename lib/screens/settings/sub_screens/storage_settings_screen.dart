import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  // Simulé pour l'exemple, à remplacer par getTemporaryDirectory().stat() si besoin réel
  String _cacheSize = "128.5 MB";
  bool _isCleaning = false;

  Future<void> _clearCache() async {
    setState(() => _isCleaning = true);
    // Simulation du nettoyage
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _cacheSize = "0 MB";
        _isCleaning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache nettoyé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
          'Stockage et cache',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.sd_storage_rounded,
                    size: 60,
                    color: AppTheme.primaryBlue,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Espace utilisé',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _cacheSize,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Le cache inclut les images, les fichiers temporaires et les préférences locales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCleaning ? null : _clearCache,
                icon: _isCleaning
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.delete_outline),
                label: Text(
                    _isCleaning ? 'Nettoyage en cours...' : 'Vider le cache'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
