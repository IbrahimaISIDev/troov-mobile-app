import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../chat/chat_detail_screen.dart';
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
    profileImage: null,
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

class _TroovPostItem extends StatelessWidget {
  final Map<String, dynamic> post;

  const _TroovPostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Media plein écran (image pour l'instant) avec ajustement type TikTok
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Image.asset(
                post['media'] as String,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Dégradé bas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final provider = _buildProviderFromPost(post);
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
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white24,
                              child: Text(
                                (post['ownerName'] as String)[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['ownerName'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    post['title'] as String,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              contactName: post['ownerName'] as String,
                              contactId: post['id'] as String,
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.phone_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> _mockPosts = [
  {
    'id': 'post1',
    'ownerName': 'Atelier Design Dakar',
    'title': 'Salon moderne à petit prix',
    'description': 'Canapé 3 places + fauteuil, légèrement utilisé, parfait pour un salon cosy.',
    'media': 'assets/images/image6.png',
  },
  {
    'id': 'post2',
    'ownerName': 'Immo Prestige',
    'title': 'Studio meublé Fann Résidence',
    'description': 'Studio lumineux, proche de la mer, idéal pour étudiants et jeunes actifs.',
    'media': 'assets/images/image7.png',
  },
  {
    'id': 'post3',
    'ownerName': 'Transfert Express',
    'title': 'Promo transferts Europe → Sénégal',
    'description': 'Frais réduits sur vos envois ce mois-ci, conditions sur la page offre.',
    'media': 'assets/images/image8.png',
  },
];
