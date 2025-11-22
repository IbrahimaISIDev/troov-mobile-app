import 'package:flutter/material.dart';
import '../../models/service_model.dart';

class ServiceCategories extends StatelessWidget {
  final Function(ServiceCategory) onCategoryTap;

  const ServiceCategories({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ServiceData.getCategories();
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically adjust crossAxisCount and childAspectRatio based on screen width
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);
    final childAspectRatio = screenWidth < 600 ? 1.3 : 1.5;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Text(
              'Toutes les catégories',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14 : 16;
    final smallFontSize = screenWidth < 600 ? 10 : 12;

    return InkWell(
      onTap: () => onCategoryTap(category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: category.color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.icon,
                    size: screenWidth < 600 ? 20 : 24,
                    color: category.color,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.providerCount}+',
                    style: TextStyle(
                      fontSize: smallFontSize - 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              category.name,
              style: TextStyle(
                fontSize: fontSize - 0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (category.description != null) ...[
              SizedBox(height: screenWidth * 0.01),
              Flexible(
                child: Text(
                  category.description!,
                  style: TextStyle(
                    fontSize: smallFontSize - 0,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Text(
                  'Explorer',
                  style: TextStyle(
                    fontSize: smallFontSize - 0,
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: smallFontSize + 2,
                  color: category.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}