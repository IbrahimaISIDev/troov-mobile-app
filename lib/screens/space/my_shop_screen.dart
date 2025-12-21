import 'package:flutter/material.dart';
import 'my_services_form_screen.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({Key? key}) : super(key: key);

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'add_service') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyServicesFormScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    }
                    if (value == 'add_realisation') {
                      _showAddRealisationModal(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'add_service',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: Colors.blue, size: 20),
                            SizedBox(width: 10),
                            Text('Ajouter un service'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'add_realisation',
                        child: Row(
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Colors.purple, size: 20),
                            SizedBox(width: 10),
                            Text('Ajouter réalisation'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'customize',
                        child: Text('Personnaliser services'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'prefs',
                        child: Text('Mes préférences'),
                      ),
                    ];
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Avatar with Ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blueAccent, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/200?user=shop'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'ChocoHair',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        'Coiffeuse Professionnelle',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 15),

                      // Profile Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderStat('45', 'Prestations'),
                          _buildDivider(),
                          _buildHeaderStat('4.8', 'Note'),
                          _buildDivider(),
                          _buildHeaderStat('1.2k', 'Avis'),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Action Button (Mes Clients)
                      SizedBox(
                        width: 180,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => _showClientsModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.people_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Mes clients'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black87,
                tabs: const [
                  Tab(text: 'Ma Bio'),
                  Tab(text: 'Mes réals'),
                  Tab(text: 'Avis'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Bio Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('À propos',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Expert en coiffure afro et européenne. Je propose des services à domicile ou en salon. Passionnée par la beauté et le bien-être de mes clientes.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Text('Mes Services',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('Tresses'),
                      _buildChip('Lissage Brésilien'),
                      _buildChip('Coloration'),
                      _buildChip('Coupe'),
                      _buildChip('Maquillage'),
                    ],
                  )
                ],
              ),
            ),

            // Reals Grid Tab
            GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openRealisationDetail(context, index),
                  child: Hero(
                    tag: 'real_$index',
                    child: Image.network(
                      'https://picsum.photos/300/300?random=$index',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),

            // Avis / Stats Tab
            // Avis / Stats Tab
            ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 6, // 1 Header + 5 Reviews
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('4.8',
                                style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade600)),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Excellent',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade600)),
                                const SizedBox(height: 4),
                                const Text('Basé sur 45 avis',
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text('Derniers avis',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                    ],
                  );
                }

                // Review Card
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('User ${index}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(Icons.star,
                                    size: 16,
                                    color: i < 4
                                        ? Colors.amber
                                        : Colors.grey.shade300)),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Super prestation, très professionnelle ! Je recommande vivement pour tous vos besoins.',
                        style:
                            TextStyle(color: Colors.grey.shade600, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 20, color: Colors.grey.shade300);
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
    );
  }

  void _showAddRealisationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nouvelle Réalisation',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Publier',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Upload
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey, size: 40),
                          SizedBox(height: 10),
                          Text('Photo ou Vidéo',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text('Titre',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Ex: Tresses collées',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Service Select
                    const Text('Lier à un service',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 's1', child: Text('Tresses Africaines')),
                        DropdownMenuItem(value: 's2', child: Text('Lissage')),
                        DropdownMenuItem(
                            value: 's3', child: Text('Maquillage')),
                      ],
                      onChanged: (v) {},
                      hint: const Text('Sélectionner un service'),
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

  void _openRealisationDetail(BuildContext context, int index) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'real_$index',
                  child: Image.network(
                    'https://picsum.photos/600/800?random=$index',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Close Button
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Overlay Info
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titre Réalisation $index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 10)
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildOverlayTag('#Tresses'),
                        _buildOverlayTag('#Coiffure'),
                        _buildOverlayTag('Service: Tresses Africaines'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildOverlayTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _showClientsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mes Clients',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text('${index + 1}',
                          style: TextStyle(color: Colors.blue.shade800)),
                    ),
                    title: Text('Client ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Dernière commande: 12/12/2025'),
                    trailing:
                        const Icon(Icons.phone_outlined, color: Colors.green),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
