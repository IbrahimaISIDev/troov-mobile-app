import 'package:flutter/material.dart';

class ServiceOptionSelector extends StatelessWidget {
  final bool includeInstallation;
  final ValueChanged<bool> onChanged;

  const ServiceOptionSelector({
    super.key,
    required this.includeInstallation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: includeInstallation ? Colors.orange : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Installation & Montage',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Par un expert certifié',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: includeInstallation,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
