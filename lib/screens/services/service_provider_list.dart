import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../utils/theme.dart';

class ServiceProviderList extends StatefulWidget {
  final ServiceCategory category;
  final List<ServiceProvider> providers;
  final VoidCallback onBack;
  final Function(ServiceProvider) onProviderTap;
  final String searchQuery;
  final Function(String) onSearchChanged;

  const ServiceProviderList({
    super.key,
    required this.category,
    required this.providers,
    required this.onBack,
    required this.onProviderTap,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<ServiceProviderList> createState() => _ServiceProviderListState();
}

class _ServiceProviderListState extends State<ServiceProviderList> {
  late TextEditingController _searchController;
  String _sortBy = 'distance';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedProviders = _getSortedProviders();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth),
            _buildSearchAndSort(screenWidth),
            Expanded(
              child: sortedProviders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: sortedProviders.length,
                      itemBuilder: (context, index) {
                        return _buildProviderCard(sortedProviders[index], screenWidth);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: widget.onBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.black87,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.providers.length} prestataires disponibles',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: widget.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.category.icon,
              color: widget.category.color,
              size: screenWidth < 600 ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                decoration: InputDecoration(
                  hintText: 'Rechercher un prestataire...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryBlue,
                    size: screenWidth < 600 ? 20 : 24,
                  ),
                  suffixIcon: widget.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(screenWidth * 0.04),
                ),
                style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              initialValue: _sortBy,
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              icon: Icon(
                Icons.sort_rounded,
                color: AppTheme.primaryBlue,
                size: screenWidth < 600 ? 20 : 24,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'distance',
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: screenWidth < 600 ? 16 : 18),
                      SizedBox(width: 8),
                      Text(
                        'Distance',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'rating',
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: screenWidth < 600 ? 16 : 18),
                      SizedBox(width: 8),
                      Text(
                        'Note',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'price',
                  child: Row(
                    children: [
                      Icon(Icons.attach_money_rounded, size: screenWidth < 600 ? 16 : 18),
                      SizedBox(width: 8),
                      Text(
                        'Prix',
                        style: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider, double screenWidth) {
    final fontSize = screenWidth < 600 ? 14 : 16;
    final smallFontSize = screenWidth < 600 ? 10 : 12;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
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
      ),
      child: InkWell(
        onTap: () => widget.onProviderTap(provider),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenWidth < 600 ? 25 : 30,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: Image.asset(
                        provider.profileImage ?? 'assets/images/burger.png',
                        fit: BoxFit.cover,
                        width: screenWidth < 600 ? 50 : 60,
                        height: screenWidth < 600 ? 50 : 60,
                        errorBuilder: (context, error, stackTrace) {
                          print("Erreur de chargement de l'image de profil: $error");
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade400,
                              size: screenWidth < 600 ? 25 : 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: TextStyle(
                                  fontSize: fontSize - 0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (provider.isVerified)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      size: smallFontSize - 2,
                                      color: Colors.green.shade600,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        fontSize: smallFontSize - 2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: provider.specialties.take(2).map((specialty) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.category.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                specialty,
                                style: TextStyle(
                                  fontSize: smallFontSize - 1,
                                  fontWeight: FontWeight.w500,
                                  color: widget.category.color,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.015),
                    decoration: BoxDecoration(
                      color: provider.availability
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      provider.availability
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: smallFontSize + 2,
                      color: provider.availability
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: smallFontSize + 2,
                      ),
                      SizedBox(width: 4),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: smallFontSize + 2,
                        ),
                      ),
                      Text(
                        ' (${provider.reviewCount})',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: smallFontSize + 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.grey.shade500,
                        size: smallFontSize + 2,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${provider.distance.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: smallFontSize + 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${provider.hourlyRate.toStringAsFixed(0)} FCFA/h',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.category.color,
                      fontSize: smallFontSize + 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.02),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: smallFontSize - 0,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Répond en ${provider.responseTime}',
                    style: TextStyle(
                      fontSize: smallFontSize - 0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Icon(
                    Icons.work_rounded,
                    size: smallFontSize - 0,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${provider.completedJobs} missions',
                    style: TextStyle(
                      fontSize: smallFontSize - 0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: screenWidth < 600 ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            'Aucun prestataire trouvé',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: screenWidth < 600 ? 12 : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  List<ServiceProvider> _getSortedProviders() {
    List<ServiceProvider> filtered = List.from(widget.providers);

    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((provider) {
        return provider.name.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
               provider.specialties.any((specialty) =>
                   specialty.toLowerCase().contains(widget.searchQuery.toLowerCase()));
      }).toList();
    }

    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price':
        filtered.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'distance':
      default:
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    return filtered;
  }
}