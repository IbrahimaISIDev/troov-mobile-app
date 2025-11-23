import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class OwnerProfileScreen extends StatelessWidget {
  final String ownerName;

  const OwnerProfileScreen({Key? key, required this.ownerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ownerName),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Profil de $ownerName',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
