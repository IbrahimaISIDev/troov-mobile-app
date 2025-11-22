import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class ServiceHeader extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;

  const ServiceHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
  });

  @override
  State<ServiceHeader> createState() => _ServiceHeaderState();
}

class _ServiceHeaderState extends State<ServiceHeader>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation et localisation
            _buildGreetingSection(),
            
            const SizedBox(height: 20),
            
            // Barre de recherche améliorée
            _buildSearchBar(),
            
            const SizedBox(height: 16),
            
            // Filtres rapides
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pikine, Dakar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryBlue,
            ),
            onPressed: () {
              // Gérer les notifications
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.searchQuery.isNotEmpty 
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        decoration: InputDecoration(
          hintText: 'Quel service recherchez-vous ?',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryBlue,
            size: 22,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : Icon(
                  Icons.tune_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    final filters = [
      {'label': 'Près de moi', 'icon': Icons.location_on_rounded},
      {'label': 'Disponible', 'icon': Icons.access_time_rounded},
      {'label': 'Meilleur prix', 'icon': Icons.local_offer_rounded},
      {'label': 'Top rated', 'icon': Icons.star_rounded},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              onSelected: (selected) {
                // Gérer la sélection des filtres
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filtre "${filter['label']}" appliqué'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryBlue,
              side: BorderSide(
                color: AppTheme.primaryBlue.withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour !';
    } else if (hour < 17) {
      return 'Bon après-midi !';
    } else {
      return 'Bonsoir !';
    }
  }
}