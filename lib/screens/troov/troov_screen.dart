import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../services/service_provider_detail.dart';
import '../../models/service_model.dart';

class TroovScreen extends StatelessWidget {
  const TroovScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = _mockPosts;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _TroovPostItem(post: post);
        },
      ),
    );
  }
}

ServiceProvider _buildProviderFromPost(Map<String, dynamic> post) {
  return ServiceProvider(
    id: post['id'] as String,
    name: post['ownerName'] as String,
    rating: 4.5,
    distance: 1.2,
    reviewCount: 42,
    profileImage: post['ownerImage'] as String?,
    specialties: const ['Service Troov'],
    description: post['description'] as String,
    phone: '+221 77 000 00 00',
    address: 'Dakar, Sénégal',
    isVerified: true,
    responseTime: '2h',
    completedJobs: 120,
    hourlyRate: 10000,
    availability: true,
    portfolio: [post['media'] as String],
  );
}

class _TroovPostItem extends StatefulWidget {
  final Map<String, dynamic> post;

  const _TroovPostItem({required this.post});

  @override
  State<_TroovPostItem> createState() => _TroovPostItemState();
}

class _TroovPostItemState extends State<_TroovPostItem> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Media plein écran
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: (widget.post['media'] as String).startsWith('http')
                  ? Image.network(
                      widget.post['media'] as String,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white54, size: 40),
                        ),
                      ),
                    )
                  : Image.asset(
                      widget.post['media'] as String,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white54, size: 40),
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Side Action Bar (Right)
        Positioned(
          right: 16,
          bottom: 100, // Adjusted position
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  final provider = _buildProviderFromPost(widget.post);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderDetail(
                        provider: provider,
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryBlue,
                    backgroundImage: (widget.post['ownerImage'] != null &&
                            (widget.post['ownerImage'] as String).isNotEmpty)
                        ? (widget.post['ownerImage']
                                .toString()
                                .startsWith('http')
                            ? NetworkImage(widget.post['ownerImage'])
                            : AssetImage(widget.post['ownerImage'])
                                as ImageProvider)
                        : null,
                    child: (widget.post['ownerImage'] == null ||
                            (widget.post['ownerImage'] as String).isEmpty)
                        ? Text(
                            (widget.post['ownerName'] as String)
                                .replaceAll('@', '')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              _buildSideAction(
                icon: _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                count: _formatCount(
                    ((widget.post['likes'] as int?) ?? 0) + (_isLiked ? 1 : 0)),
                color: _isLiked ? Colors.red : Colors.white,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildSideAction(
                icon: Icons.chat_bubble_outline_rounded,
                count: _formatCount((widget.post['comments'] as int?) ?? 0),
                color: Colors.white,
                onTap: () {
                  _showCommentsModal(context);
                },
              ),
            ],
          ),
        ),

        // Dégradé bas et Info (Simplified)
        Positioned(
          left: 0,
          right: 80, // Leave space for side bar
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post['ownerName'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.post['description'] as String,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: size.height * 0.05), // Bottom safe margin
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const Text(
                    'Commentaires (124)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      itemCount: 10, // Mock comments
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(Icons.person,
                                    color: Colors.grey, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Utilisateur ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      index % 2 == 0
                                          ? 'Super produit ! Je suis intéressé.'
                                          : 'Est-ce que c\'est toujours disponible ?',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Il y a ${index + 2} min',
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.favorite_border,
                                  size: 16, color: Colors.grey),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Input area
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 12, 16,
                        MediaQuery.of(context).viewInsets.bottom + 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Ajouter un commentaire...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue,
                          radius: 22,
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            onPressed: () {
                              // TODO: Implement send comment
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildSideAction({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _mockPosts = [
  {
    'id': 'post1',
    'ownerName': '@atelier_design_dk',
    'ownerImage': 'https://i.pravatar.cc/150?u=atelier', // Realistic Avatar
    'title': 'Salon moderne à petit prix',
    'description':
        'Canapé 3 places + fauteuil, légèrement utilisé, parfait pour un salon cosy. #mobilier #dakar #troov',
    'media': 'https://picsum.photos/800/800?furniture=1', // Furniture image
    'likes': 1200,
    'comments': 45,
  },
  {
    'id': 'post2',
    'ownerName': '@immo_prestige',
    // ownerImage is null to test fallback
    'title': 'Studio meublé Fann Résidence',
    'description':
        'Studio lumineux, proche de la mer, idéal pour étudiants et jeunes actifs. Disponible de suite !',
    'media': 'https://picsum.photos/800/800?apartment=1', // Apartment/Interior
    'likes': 850,
    'comments': 124,
  },
  {
    'id': 'post3',
    'ownerName': '@transfert_exp',
    'ownerImage': null, // Explicit null
    'title': 'Promo transferts Europe → Sénégal',
    'description':
        'Frais réduits sur vos envois ce mois-ci. Profitez-en maintenant ! 💸',
    'media': 'https://picsum.photos/800/800?service=1', // Service/Business
    'likes': 10500,
    'comments': 2300,
  },
  {
    'id': 'post4',
    'ownerName': '@mode_dakar',
    'ownerImage': 'https://i.pravatar.cc/150?u=mode',
    'title': 'Nouvelle collection Robes',
    'description':
        'Arrivage de robes d\'été, tissus légers et colorés. Venez vite essayer ! 👗☀️ #mode #dakar',
    'media': 'https://picsum.photos/800/800?fashion=1', // Fashion
    'likes': 340,
    'comments': 28,
  },
];
