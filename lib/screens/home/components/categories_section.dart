import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class CategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onSeeMoreTap;
  final Function(Category) onCategoryTap;

  const CategoriesSection({
    Key? key,
    required this.categories,
    required this.onSeeMoreTap,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final itemWidth = (sw - 48) / 2; // 2 colonnes avec padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre et Voir plus
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Troov. ',
                        style: TextStyle(
                          fontSize: sw < 600 ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Plus facilement ce que tu cherches.',
                        style: TextStyle(
                          fontSize: sw < 600 ? 13 : 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextSpan(
                        text: '\nau delà du Sénégal',
                        style: TextStyle(
                          fontSize: sw < 600 ? 11 : 13,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeMoreTap,
                child: const Text(
                  'Voir plus',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grille de catégories
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, i) => _buildCategoryCard(
              categories[i],
              itemWidth,
              sw,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryCard(Category category, double cardWidth, double sw) {
    // Couleurs par défaut pour les catégories
    final Map<String, Color> categoryColors = {
      'furniture': Colors.orange.shade100,
      'mobilier': Colors.orange.shade100,
      'artisans': Colors.amber.shade100,
      'services': Colors.blue.shade100,
      'delivery': Colors.green.shade100,
      'hair': Colors.purple.shade100,
      'transfer': Colors.indigo.shade100,
      'food': Colors.red.shade100,
      'housing': Colors.teal.shade100,
    };

    Color bgColor = Colors.grey.shade100;
    IconData icon = Icons.grid_view;
    String label = category.title;

    // Déterminer la couleur et l'icône en fonction du titre
    final titleLower = category.title.toLowerCase();
    if (titleLower.contains('mobilier') || titleLower.contains('furniture')) {
      bgColor = categoryColors['mobilier']!;
      icon = Icons.chair;
      label = 'Mobilier';
    } else if (titleLower.contains('artisan') || titleLower.contains('maison')) {
      bgColor = categoryColors['artisans']!;
      icon = Icons.build;
      label = 'Artisans';
    } else if (titleLower.contains('coif') || titleLower.contains('hair')) {
      bgColor = categoryColors['hair']!;
      icon = Icons.content_cut;
      label = 'Coiffeuses';
    } else if (titleLower.contains('livr') || titleLower.contains('delivery')) {
      bgColor = categoryColors['delivery']!;
      icon = Icons.two_wheeler;
      label = 'Livreurs';
    } else if (titleLower.contains('logement') || titleLower.contains('housing')) {
      bgColor = categoryColors['housing']!;
      icon = Icons.home;
      label = 'Logements';
    } else if (titleLower.contains('transfer') || titleLower.contains('argent')) {
      bgColor = categoryColors['transfer']!;
      icon = Icons.compare_arrows;
      label = 'Transferts';
    } else if (titleLower.contains('food') ||
        titleLower.contains('aliment') ||
        titleLower.contains('cuisine')) {
      bgColor = categoryColors['food']!;
      icon = Icons.restaurant;
      label = 'Cuisine';
    } else if (titleLower.contains('network') ||
        titleLower.contains('collaboration') ||
        titleLower.contains('réseau')) {
      bgColor = Colors.indigo.shade100;
      icon = Icons.groups;
      label = 'Réseau';
    }

    return GestureDetector(
      onTap: () => onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: sw < 600 ? 32 : 40,
              color: Colors.black54,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: sw < 600 ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (category.totalProducts > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${category.totalProducts} produits',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sw < 600 ? 10 : 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
