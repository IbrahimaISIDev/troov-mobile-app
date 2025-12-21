import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ranking Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.emoji_events,
                        color: Colors.orange, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Classement: Super Vendeur',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(height: 5),
                        Text('Top 5% de la communauté',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 10),
                        LinearProgressIndicator(
                            value: 0.8,
                            backgroundColor: Colors.white24,
                            color: Colors.amber),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Financials
            _buildSectionTitle('Finances'),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    child: _buildSummaryCard('Revenus', '1.2M FCFA',
                        Icons.arrow_upward, Colors.green)),
                const SizedBox(width: 15),
                Expanded(
                    child: _buildSummaryCard('Dépenses', '450k FCFA',
                        Icons.arrow_downward, Colors.red)),
              ],
            ),
            const SizedBox(height: 25),

            // Engagement Grid
            _buildSectionTitle('Engagement & Activité'),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildStatTile(
                    'Publications', '45', Icons.grid_view, Colors.purple),
                _buildStatTile('Avis', '4.8/5', Icons.star, Colors.amber),
                _buildStatTile(
                    'Vues profile', '1.2k', Icons.remove_red_eye, Colors.blue),
                _buildStatTile('Messages', '12', Icons.chat, Colors.pink),
              ],
            ),

            const SizedBox(height: 25),
            // Business Stats
            _buildSectionTitle('Mon Business'),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildRowStat(
                      'Mes Ventes', '128', Icons.shopping_bag_outlined),
                  const Divider(),
                  _buildRowStat(
                      'Mes Achats', '34', Icons.shopping_cart_outlined),
                  const Divider(),
                  _buildRowStat('Mes Clients', '56', Icons.people_outline),
                  const Divider(),
                  _buildRowStat(
                      'Réalisations', '12', Icons.camera_alt_outlined),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRowStat(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
