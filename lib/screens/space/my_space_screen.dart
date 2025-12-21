import 'package:flutter/material.dart';

import 'publish_troov_screen.dart';
import 'stats_screen.dart';
import 'my_shop_screen.dart';
import 'my_sales_screen.dart';
import 'my_purchases_screen.dart';
import '../chat/chat_screen.dart';

class MySpaceScreen extends StatefulWidget {
  const MySpaceScreen({Key? key}) : super(key: key);

  @override
  State<MySpaceScreen> createState() => _MySpaceScreenState();
}

class _MySpaceScreenState extends State<MySpaceScreen> {
  bool _isSalesExpanded = false;
  bool _isPurchasesExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mon espace',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined,
                  color: Colors.black87, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatScreen(showBack: true)),
                );
              },
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gérez vos services et vos publications Troov.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ajoutez vos prestations, mettez-les en avant et publiez-les dans le fil Troov pour être visible comme les autres prestataires.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // "Ma boutique" Rich Card
            _buildShopPreviewCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyShopScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildPublishSection(context),
            const SizedBox(height: 15),

            // Mes Ventes (Expandable)
            _buildExpandableCard(
              icon: Icons.bar_chart_rounded, // or sell_rounded
              title: 'Mes ventes',
              subtitle: 'Troov des clients pour ton produit maintenant',
              isExpanded: _isSalesExpanded,
              onTap: () {
                setState(() {
                  _isSalesExpanded = !_isSalesExpanded;
                  if (_isSalesExpanded) _isPurchasesExpanded = false;
                });
              },
              items: _getMockSales(),
              onSeeMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MySalesScreen()),
                );
              },
            ),

            const SizedBox(height: 15),

            // Mes Achats (Expandable)
            _buildExpandableCard(
              icon: Icons.shopping_bag_rounded,
              title: 'Mes achats',
              subtitle: 'Suivez vos commandes et achats.',
              isExpanded: _isPurchasesExpanded,
              onTap: () {
                setState(() {
                  _isPurchasesExpanded = !_isPurchasesExpanded;
                  if (_isPurchasesExpanded) _isSalesExpanded = false;
                });
              },
              items: _getMockPurchases(),
              onSeeMore: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyPurchasesScreen()),
                );
              },
            ),

            const SizedBox(height: 15),
            _buildMenuCard(
              icon: Icons.analytics_rounded,
              title: 'Statistiques',
              subtitle: 'Voir les vues et les contacts générés.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
            ),
            // "Mes services" button removed as requested
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildPublishSection(BuildContext context) {
    return Column(
      children: [
        // Main Card
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PublishTroovScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.video_collection_rounded,
                      color: Colors.black54),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Publier dans Troov',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Préparer une annonce à afficher dans le feed Troov.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Top 3 Views Row (Static, No Scroll)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left (Rank 2)
              _buildTopImageCard(
                  'https://picsum.photos/200/300?random=101', // Lifestyle/Fashion
                  rank: 2,
                  height: 120,
                  width: 100),
              const SizedBox(width: 8),
              // Center (Rank 1 - Largest)
              _buildTopImageCard(
                  'https://picsum.photos/200/300?random=202', // Tech/Product
                  rank: 1,
                  height: 160,
                  width: 110,
                  isCenter: true),
              const SizedBox(width: 8),
              // Right (Rank 3)
              _buildTopImageCard(
                  'https://picsum.photos/200/300?random=303', // Art/Decor
                  rank: 3,
                  height: 120,
                  width: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopImageCard(String url,
      {required int rank,
      required double height,
      required double width,
      bool isCenter = false}) {
    // Mock stats based on rank
    String views = rank == 1 ? '1.2k' : (rank == 2 ? '850' : '640');
    String likes = rank == 1 ? '340' : (rank == 2 ? '203' : '95');
    String comments = rank == 1 ? '45' : (rank == 2 ? '25' : '8');

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 10),
              const SizedBox(width: 1),
              Text(views,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              const Icon(Icons.favorite_border, size: 10),
              const SizedBox(width: 1),
              Text(likes,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              const Icon(Icons.chat_bubble_outline, size: 10),
              const SizedBox(width: 1),
              Text(comments,
                  style: const TextStyle(
                      fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopPreviewCard({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.black54),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ma boutique',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Améliore d\'avantage ton profil',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            // Preview Content (Grid-like)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Col 1: Bio / Profile
                Column(
                  children: [
                    Text(
                      'Ma Bio',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                  'https://picsum.photos/100/100?user=1'),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ChocoHair',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Coiffeuse',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
                // Col 2: Realisations (3 images)
                Column(
                  children: [
                    Text(
                      'Mes réals',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTinyImg('https://picsum.photos/100/150?1'),
                        const SizedBox(width: 4),
                        _buildTinyImg('https://picsum.photos/100/150?2',
                            height: 60), // Center one slightly taller?
                        const SizedBox(width: 4),
                        _buildTinyImg('https://picsum.photos/100/150?3'),
                      ],
                    )
                  ],
                ),
                // Col 3: Stats
                Column(
                  children: [
                    const Text(
                      'Mes stats',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '8%',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Text('G',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTinyImg(String url, {double height = 50}) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  // Generic Static Card
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Expandable Card (Accordion style)
  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Map<String, dynamic>> items,
    required VoidCallback onSeeMore,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header (Clickable)
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Expanded Content
          if (isExpanded) ...[
            const SizedBox(height: 20),
            // Divider?
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),

            // Items List (Limit to 3)
            ...items
                .take(3)
                .map((item) => _buildTransactionItem(item, onTap: () {
                      // Determine if it's a sale or purchase based on title context or item properties
                      // For simplicity, we'll check if the parent card title contains "ventes"
                      bool isSale = title.toLowerCase().contains('ventes');
                      _showTransactionDetail(context, item, isSale: isSale);
                    })),

            const SizedBox(height: 10),
            // Voir plus Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSeeMore,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade50,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voir plus',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details Middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['date'],
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['status'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount & ID Right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['price'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['id'],
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tous les détails',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> item,
      {required bool isSale}) {
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
            Text(isSale ? 'Détails de la vente' : 'Détails de l\'achat',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Client/Seller Info (Mock)
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://picsum.photos/100?user=${isSale ? 'client' : 'seller'}')),
              title:
                  Text(isSale ? 'Acheteur: Sophie K.' : 'Vendeur: Boutique X'),
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
                children: [
                  const Text('Récapitulatif',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Produit: ${item['name']}'),
                  Text('Prix: ${item['price']}'),
                  Text('Date: ${item['date']}'),
                  const SizedBox(height: 20),
                  const Text('Statut',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${item['status']} - En cours de traitement'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock Data Generators
  List<Map<String, dynamic>> _getMockSales() {
    return [
      {
        'image': 'https://picsum.photos/200/200?furniture=1',
        'name': 'Meuble de rangement',
        'date': '26/11/2025 09:23',
        'status': 'Vendu',
        'price': '25 000 FCFA',
        'id': 'G923C2L',
      },
      {
        'image': 'https://picsum.photos/200/200?electronics=1',
        'name': 'Console de jeux',
        'date': '26/11/2025 09:23',
        'status': 'Vendu',
        'price': '25 000 FCFA',
        'id': 'G923C2L',
      },
      {
        'image': 'https://picsum.photos/200/200?clothing=1',
        'name': 'Veste en cuir',
        'date': '24/11/2025 14:10',
        'status': 'Vendu',
        'price': '45 000 FCFA',
        'id': 'H881K9P',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockPurchases() {
    return [
      {
        'image': 'https://picsum.photos/200/200?shoes=1',
        'name': 'Nike Air Jordan',
        'date': '20/11/2025 18:00',
        'status': 'Livré',
        'price': '85 000 FCFA',
        'id': 'B112X5Q',
      },
      {
        'image': 'https://picsum.photos/200/200?book=1',
        'name': 'Livre Flutter',
        'date': '15/11/2025 10:30',
        'status': 'Livré',
        'price': '15 000 FCFA',
        'id': 'A443Y7M',
      },
    ];
  }
}
