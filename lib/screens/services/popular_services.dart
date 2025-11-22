import 'package:flutter/material.dart';
import '../../models/service_model.dart';

class PopularServices extends StatelessWidget {
  final Function(PopularService) onServiceTap;

  const PopularServices({
    super.key,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final popularServices = ServiceData.getPopularServices();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services populaires',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Voir tous les services populaires
                  },
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth < 600 ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate card height based on available space
              final cardHeight = constraints.maxHeight * 0.25 < 140
                  ? 140.0
                  : constraints.maxHeight * 0.25 > 180
                      ? 180.0
                      : constraints.maxHeight * 0.25;
              return SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
                  itemCount: popularServices.length,
                  itemBuilder: (context, index) {
                    final service = popularServices[index];
                    return _buildPopularServiceCard(service, context, cardHeight);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServiceCard(
      PopularService service, BuildContext context, double cardHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600 ? 120 : 130;
    final fontSize = screenWidth < 600 ? 12 : 14;
    final smallFontSize = screenWidth < 600 ? 10 : 12;

    return Container(
      width: cardWidth + 20,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: InkWell(
        onTap: () => onServiceTap(service),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service.icon,
                  size: screenWidth < 600 ? 24 : 28,
                  color: service.color,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Flexible(
                child: Text(
                  service.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize - 0  ,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Flexible(
                child: Text(
                  service.subtitle,
                  style: TextStyle(
                    fontSize: smallFontSize - 0 ,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Populaire',
                  style: TextStyle(
                    fontSize: smallFontSize - 2,
                    fontWeight: FontWeight.w600,
                    color: service.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}