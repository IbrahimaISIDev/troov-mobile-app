import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../chat/chat_detail_screen.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const PurchaseDetailScreen({Key? key, required this.purchase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails Achat',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            const Text('Article',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildItemCard(),
            const SizedBox(height: 24),
            const Text('Vendeur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSellerCard(context),
            const SizedBox(height: 24),
            const Text('Résumé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Re-commander or signal problem
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Signaler un problème'),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: (purchase['statusColor'] as Color).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 40, color: purchase['statusColor'] as Color),
          const SizedBox(height: 12),
          Text(
            purchase['status'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: purchase['statusColor'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(purchase['date'] as String,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildItemCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase['item'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Quantité: 1',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            '-${purchase['amount']} F',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Text((purchase['seller'] as String)[0],
                style: TextStyle(color: AppTheme.primaryBlue)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase['seller'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text('Vendeur certifié',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    contactName: purchase['seller'] as String,
                    contactId: 'seller_123', // Mock ID
                    isOnline: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Sous-total', '${purchase['amount']} F'),
          const SizedBox(height: 8),
          _buildSummaryRow('Livraison', '2,000 F'),
          const Divider(height: 24),
          _buildSummaryRow('Total', '47,000 F', isBold: true), // Example logic
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Colors.black : Colors.grey.shade700)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
