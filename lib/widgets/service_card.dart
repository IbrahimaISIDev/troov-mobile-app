import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/enums.dart';
import '../utils/theme.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du service
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: service.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        service.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      ),
                    )
                  : _buildPlaceholder(),
            ),
            
            // Contenu de la carte
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et catégorie
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(service.category),
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Description
                  Text(
                    service.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Prix et évaluation
                  Row(
                    children: [
                      // Prix
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatPrice(service.price, service.priceType),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      Spacer(),
                      
                      // Évaluation
                      if (service.reviewCount > 0) ...[
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ] else
                        Text(
                          'Nouveau',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Durée estimée et tags
                  Row(
                    children: [
                      if (service.estimatedDuration != null) ...[
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          _formatDuration(service.estimatedDuration!),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                      
                      // Statut disponibilité
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: service.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          service.isActive ? 'Disponible' : 'Indisponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags
                  if (service.tags.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: service.tags.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.3),
            AppTheme.primaryBlue.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(service.category),
              size: 60,
              color: AppTheme.primaryBlue.withOpacity(0.7),
            ),
            SizedBox(height: 8),
            Text(
              _getCategoryName(service.category),
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price, PriceType priceType) {
    String formattedPrice = '${price.toStringAsFixed(0)} FCFA';
    
    switch (priceType) {
      case PriceType.hourly:
        return '$formattedPrice/h';
      case PriceType.fixed:
        return formattedPrice;
      case PriceType.perKm:
        return '$formattedPrice/km';
      case PriceType.perItem:
        return '$formattedPrice/article';
      case PriceType.perUnit:
        return '$formattedPrice/unité';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h${duration.inMinutes % 60 > 0 ? '${duration.inMinutes % 60}min' : ''}';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  String _getCategoryName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return 'Ménage';
      case ServiceCategory.repair:
        return 'Réparation';
      case ServiceCategory.delivery:
        return 'Livraison';
      case ServiceCategory.cooking:
        return 'Cuisine';
      case ServiceCategory.health:
        return 'Santé';
      case ServiceCategory.beauty:
        return 'Beauté';
      case ServiceCategory.education:
        return 'Éducation';
      case ServiceCategory.transport:
        return 'Transport';
      case ServiceCategory.gardening:
        return 'Jardinage';
      case ServiceCategory.technology:
        return 'Technologie';
    }
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return Icons.cleaning_services;
      case ServiceCategory.repair:
        return Icons.home_repair_service;
      case ServiceCategory.delivery:
        return Icons.local_shipping;
      case ServiceCategory.cooking:
        return Icons.restaurant;
      case ServiceCategory.health:
        return Icons.health_and_safety;
      case ServiceCategory.beauty:
        return Icons.face;
      case ServiceCategory.education:
        return Icons.school;
      case ServiceCategory.transport:
        return Icons.directions_car;
      case ServiceCategory.gardening:
        return Icons.grass;
      case ServiceCategory.technology:
        return Icons.computer;
    }
  }
}

