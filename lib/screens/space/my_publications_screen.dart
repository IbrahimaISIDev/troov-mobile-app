import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class MyPublicationsScreen extends StatelessWidget {
  const MyPublicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'title': 'Appartement F4 à Mermoz',
        'image': 'assets/images/image.png',
        'views': 1245,
        'comments': 34,
        'time': '2 jours',
      },
      {
        'title': 'Robe de soirée chic',
        'image': 'assets/images/image1.png',
        'views': 856,
        'comments': 12,
        'time': '5 jours',
      },
      {
        'title': 'Service de Plomberie Pro',
        'image': 'assets/images/image2.png',
        'views': 230,
        'comments': 5,
        'time': '1 semaine',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Publications',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.grey.shade50,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Image.asset(
                      post['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Center(
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publié il y a ${post['time']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.visibility_rounded,
                              '${post['views']}', 'Vues'),
                          _buildStatItem(Icons.chat_bubble_rounded,
                              '${post['comments']}', 'Commentaires'),
                          _buildStatItem(Icons.share, 'Partager', ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
