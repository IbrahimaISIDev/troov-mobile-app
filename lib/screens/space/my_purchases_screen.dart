import 'package:flutter/material.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({Key? key}) : super(key: key);

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes Achats',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPurchasesList(isHistory: false),
          _buildPurchasesList(isHistory: true),
        ],
      ),
    );
  }

  Widget _buildPurchasesList({required bool isHistory}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildPurchaseCard(context, index, isHistory);
      },
    );
  }

  Widget _buildPurchaseCard(BuildContext context, int index, bool isHistory) {
    Color statusColor = isHistory ? Colors.green : Colors.orange;
    String statusText = isHistory ? 'Livré' : 'En route';

    return GestureDetector(
      onTap: () => _showPurchaseDetail(context, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://picsum.photos/150?random=${index + 10}',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Right: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                          child: Text('iPhone 15 Pro',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis)),
                      Text('650 000 FCFA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date & Ref
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('18/12/2025 14:05',
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text('ORD-7823',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status & Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const Text('Tous les détails',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDetail(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Détails de la commande',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Seller Info
            ListTile(
              leading: const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://picsum.photos/100?user=seller')),
              title: const Text('Boutique: Electronix DK'),
              subtitle: const Text('+221 77 000 00 00'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.message, color: Colors.blue),
                      onPressed: () {}),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  Text('Récapitulatif',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Produit: iPhone 15 Pro'),
                  Text('Prix: 650 000 FCFA'),
                  Text('Date: 18/12/2025'),
                  SizedBox(height: 20),
                  Text('Statut de livraison',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('En cours d\'acheminement vers Liberté 6'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
