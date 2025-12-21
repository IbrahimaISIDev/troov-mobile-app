import 'package:flutter/material.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({Key? key}) : super(key: key);

  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes Ventes',
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
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildSalesList(status: 'pending'),
              _buildSalesList(status: 'completed'),
              _buildSalesList(status: 'cancelled'),
            ],
          ),
          // Floating "Publish Sale" Button (similar to Publish Troov)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () => _showCreateSaleModal(context),
                backgroundColor: Colors.black,
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text('Nouvelle Vente',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList({required String status}) {
    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(16, 16, 16, 100), // Bottom padding for FAB
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildSaleCard(context, index, status);
      },
    );
  }

  Widget _buildSaleCard(BuildContext context, int index, String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Vendu';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Annulé';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'En cours';
    }

    return GestureDetector(
      onTap: () => _showSaleDetail(context, index),
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
            // Left: Square Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://picsum.photos/150?random=$index',
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
                          child: Text('Meuble de rangement',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis)),
                      Text('25 000 FCFA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date & Ref
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('26/11/2025 09:23',
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text('G923C2L',
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

  void _showCreateSaleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Créer une vente',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Mock Form
                    _buildFormInput('Titre du produit', Icons.tag),
                    const SizedBox(height: 15),
                    _buildFormInput('Prix (FCFA)', Icons.money),
                    const SizedBox(height: 15),
                    _buildFormInput('Description', Icons.description,
                        maxLines: 3),
                    const SizedBox(height: 20),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey)),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        child: const Text('Mettre en vente'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInput(String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSaleDetail(BuildContext context, int index) {
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
            const Text('Détails de la vente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Client Info similar to My Space
            ListTile(
              leading: const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://picsum.photos/100?user=client')),
              title: const Text('Client: Modou Ndiaye'),
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
                  Text('Produit: Meuble de rangement'),
                  Text('Prix: 25 000 FCFA'),
                  Text('Date: 26/11/2025'),
                  SizedBox(height: 20),
                  Text('Adresse de livraison',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Dakar, Liberté 6, Villa 123'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
