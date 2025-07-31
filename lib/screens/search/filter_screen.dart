import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/enums.dart';
import '../../models/search_filters.dart';

class FilterScreen extends StatefulWidget {
  final SearchFilters initialFilters;

  const FilterScreen({
    Key? key,
    required this.initialFilters,
  }) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late SearchFilters _filters;
  
  @override
  void initState() {
    super.initState();
    _filters = SearchFilters(
      category: widget.initialFilters.category,
      maxDistance: widget.initialFilters.maxDistance,
      minPrice: widget.initialFilters.minPrice,
      maxPrice: widget.initialFilters.maxPrice,
      minRating: widget.initialFilters.minRating,
      availableNow: widget.initialFilters.availableNow,
      tags: widget.initialFilters.tags,
      priceType: widget.initialFilters.priceType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtres'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text('Réinitialiser'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilter(),
            SizedBox(height: 24),
            _buildDistanceFilter(),
            SizedBox(height: 24),
            _buildPriceFilter(),
            SizedBox(height: 24),
            _buildRatingFilter(),
            SizedBox(height: 24),
            _buildAvailabilityFilter(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _filters),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Appliquer les filtres',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ServiceCategory.values.map((category) {
                final isSelected = _filters.category == category;
                return FilterChip(
                  label: Text(_getCategoryName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _filters = SearchFilters(
                        category: selected ? category : null,
                        maxDistance: _filters.maxDistance,
                        minPrice: _filters.minPrice,
                        maxPrice: _filters.maxPrice,
                        minRating: _filters.minRating,
                        availableNow: _filters.availableNow,
                        tags: _filters.tags,
                        priceType: _filters.priceType,
                      );
                    });
                  },
                  selectedColor: AppTheme.primaryBlue.withOpacity(0.3),
                  checkmarkColor: AppTheme.primaryBlue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distance maximale',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Slider(
              value: _filters.maxDistance ?? 50.0,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              activeColor: AppTheme.primaryBlue,
              label: '${(_filters.maxDistance ?? 50.0).round()} km',
              onChanged: (value) {
                setState(() {
                  _filters = SearchFilters(
                    category: _filters.category,
                    maxDistance: value,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    minRating: _filters.minRating,
                    availableNow: _filters.availableNow,
                    tags: _filters.tags,
                    priceType: _filters.priceType,
                  );
                });
              },
            ),
            Text(
              'Jusqu\'à ${(_filters.maxDistance ?? 50.0).round()} km',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fourchette de prix (FCFA)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            RangeSlider(
              values: RangeValues(
                _filters.minPrice ?? 0.0,
                _filters.maxPrice ?? 100000.0,
              ),
              min: 0.0,
              max: 100000.0,
              divisions: 100,
              activeColor: AppTheme.primaryBlue,
              labels: RangeLabels(
                '${(_filters.minPrice ?? 0.0).round()}',
                '${(_filters.maxPrice ?? 100000.0).round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _filters = SearchFilters(
                    category: _filters.category,
                    maxDistance: _filters.maxDistance,
                    minPrice: values.start,
                    maxPrice: values.end,
                    minRating: _filters.minRating,
                    availableNow: _filters.availableNow,
                    tags: _filters.tags,
                    priceType: _filters.priceType,
                  );
                });
              },
            ),
            Text(
              'De ${(_filters.minPrice ?? 0.0).round()} à ${(_filters.maxPrice ?? 100000.0).round()} FCFA',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note minimum',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [1, 2, 3, 4, 5].map((rating) {
                final isSelected = (_filters.minRating ?? 0) >= rating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _filters = SearchFilters(
                        category: _filters.category,
                        maxDistance: _filters.maxDistance,
                        minPrice: _filters.minPrice,
                        maxPrice: _filters.maxPrice,
                        minRating: rating.toDouble(),
                        availableNow: _filters.availableNow,
                        tags: _filters.tags,
                        priceType: _filters.priceType,
                      );
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      size: 32,
                      color: isSelected ? Colors.amber : Colors.grey[300],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            Text(
              '${(_filters.minRating ?? 0).round()} étoile${(_filters.minRating ?? 0) > 1 ? 's' : ''} et plus',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponibilité',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Disponible maintenant'),
              subtitle: Text('Afficher uniquement les services disponibles immédiatement'),
              value: _filters.availableNow ?? false,
              activeColor: AppTheme.primaryBlue,
              onChanged: (value) {
                setState(() {
                  _filters = SearchFilters(
                    category: _filters.category,
                    maxDistance: _filters.maxDistance,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    minRating: _filters.minRating,
                    availableNow: value,
                    tags: _filters.tags,
                    priceType: _filters.priceType,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = SearchFilters();
    });
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
      default:
        return category.toString().split('.').last; // Fallback pour les nouvelles catégories
    }
  }
}

