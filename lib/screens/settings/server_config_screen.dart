import 'package:flutter/material.dart';
import '../../services/config_service.dart';
import '../../utils/theme.dart';

class ServerConfigScreen extends StatefulWidget {
  @override
  _ServerConfigScreenState createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  late TextEditingController _urlController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ConfigService.getBaseUrl(),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer une URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final isValid = ConfigService.isValidUrl(url);
    if (!isValid) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Format d\'URL invalide';
      });
      return;
    }

    final success = await ConfigService.testConnection(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (success) {
        _successMessage = 'Connexion réussie!';
        _errorMessage = null;
      } else {
        _errorMessage = 'Impossible de se connecter au serveur';
        _successMessage = null;
      }
    });
  }

  void _saveConfiguration() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Veuillez entrer une URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final success = await ConfigService.saveBaseUrl(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (success) {
        _successMessage = 'Configuration sauvegardée avec succès!';
        _errorMessage = null;
        // Fermer l'écran après 2 secondes
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _errorMessage = 'Erreur lors de la sauvegarde';
        _successMessage = null;
      }
    });
  }

  void _resetToDefault() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Réinitialiser'),
          content: Text(
            'Êtes-vous sûr de vouloir réinitialiser à la configuration par défaut?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await ConfigService.resetToDefault();
                if (!mounted) return;
                
                if (success) {
                  _urlController.text = ConfigService.getBaseUrl();
                  setState(() {
                    _successMessage = 'Réinitialisé à la valeur par défaut';
                    _errorMessage = null;
                  });
                }
              },
              child: Text('Réinitialiser'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration du serveur'),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adresse du serveur',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.69:8081/api',
                prefixIcon: Icon(Icons.storage),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !_isLoading,
              ),
              keyboardType: TextInputType.url,
              enabled: !_isLoading,
            ),
            SizedBox(height: 12),
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_successMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.check_circle_outline),
                label: Text(_isLoading ? 'Test en cours...' : 'Tester la connexion'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveConfiguration,
                icon: Icon(Icons.save),
                label: Text('Sauvegarder'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isLoading ? null : _resetToDefault,
                icon: Icon(Icons.refresh),
                label: Text('Réinitialiser par défaut'),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Text(
                        'Besoin d\'aide?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'L\'adresse du serveur doit être au format:\n'
                    '• En développement: http://192.168.1.69:8081/api\n'
                    '• Production: https://troov-backend.onrender.com/api\n\n'
                    'Cliquez sur "Tester la connexion" pour vérifier que l\'adresse est correcte avant de sauvegarder.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
