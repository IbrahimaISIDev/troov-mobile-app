import 'package:flutter/material.dart';
import '../models/service_provider.dart';
import '../utils/theme.dart';

class ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback onTap;

  const ProviderCard({
    Key? key,
    required this.provider,
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // En-tête avec photo et infos de base
              Row(
                children: [
                  // Photo de profil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        backgroundImage: provider.user.profileImage != null
                            ? NetworkImage(provider.user.profileImage!)
                            : null,
                        child: provider.user.profileImage == null
                            ? Text(
                                provider.user.firstName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              )
                            : null,
                      ),
                      
                      // Indicateur en ligne
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: provider.isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Informations du prestataire
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom et vérification
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.user.fullName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (provider.user.isVerified)
                              Icon(
                                Icons.verified,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                          ],
                        ),
                        
                        SizedBox(height: 4),
                        
                        // Évaluation et avis
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '${provider.rating.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '(${provider.reviewCount} avis)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 4),
                        
                        // Distance et disponibilité
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 2),
                            Text(
                              '${provider.distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: provider.isAvailable 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                provider.isAvailable ? 'Disponible' : 'Occupé',
                                style: TextStyle(
                                  color: provider.isAvailable 
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Description
              if (provider.description.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    provider.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 12),
              ],
              
              // Compétences
              if (provider.skills.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: provider.skills.take(4).map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 12),
              ],
              
              // Services et tarif
              Row(
                children: [
                  // Nombre de services
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${provider.services.length} service${provider.services.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Tarif horaire
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'À partir de ${provider.hourlyRate.toStringAsFixed(0)} FCFA/h',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Ouvrir le chat
                      },
                      icon: Icon(Icons.message, size: 16),
                      label: Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Voir le profil complet
                      },
                      icon: Icon(Icons.person, size: 16),
                      label: Text('Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Dernière connexion
              if (!provider.isOnline && provider.lastSeen != null) ...[
                SizedBox(height: 8),
                Text(
                  'Vu ${_formatLastSeen(provider.lastSeen!)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return 'il y a plus d\'une semaine';
    }
  }
}

