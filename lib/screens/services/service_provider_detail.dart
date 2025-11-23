import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../utils/theme.dart';
import '../chat/chat_detail_screen.dart';

class ServiceProviderDetail extends StatefulWidget {
  final ServiceProvider provider;
  final VoidCallback onBack;

  const ServiceProviderDetail({
    super.key,
    required this.provider,
    required this.onBack,
  });

  @override
  State<ServiceProviderDetail> createState() => _ServiceProviderDetailState();
}

class _ServiceProviderDetailState extends State<ServiceProviderDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(screenWidth, screenHeight),
          SliverToBoxAdapter(child: _buildMainInfo(screenWidth)),
          SliverToBoxAdapter(child: _buildTabBar(screenWidth)),
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(screenWidth),
                _buildPortfolioTab(screenWidth),
                _buildReviewsTab(screenWidth),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(screenWidth),
    );
  }

  Widget _buildSliverAppBar(double screenWidth, double screenHeight) {
    return SliverAppBar(
      expandedHeight: screenWidth < 600 ? screenHeight * 0.25 : screenHeight * 0.3,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: screenWidth < 600 ? 20 : 24),
        onPressed: widget.onBack,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.3),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: screenWidth < 600 ? 20 : 24,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.3),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue,
                (AppTheme.primaryBlue).withOpacity(0.8),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: availableHeight * 0.1),
                  CircleAvatar(
                    radius: screenWidth < 600 ? 40 : 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: screenWidth < 600 ? 36 : 46,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: Image.asset(
                          widget.provider.profileImage ?? 'assets/images/burger.png',
                          fit: BoxFit.cover,
                          width: screenWidth < 600 ? 72 : 92,
                          height: screenWidth < 600 ? 72 : 92,
                          errorBuilder: (context, error, stackTrace) {
                            print("Erreur de chargement de l'image de profil: $error");
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: screenWidth < 600 ? 40 : 50,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Flexible(
                    child: Text(
                      widget.provider.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 600 ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.provider.isVerified) ...[
                    SizedBox(height: screenWidth * 0.015),
                    Container(
                      margin: EdgeInsets.only(top: screenWidth * 0.01),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: screenWidth < 600 ? 12 : 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            'Prestataire vérifié',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth < 600 ? 10 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: availableHeight * 0.05),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(double screenWidth) {
    final fontSize = screenWidth < 600 ? 14 : 16;
    final smallFontSize = screenWidth < 600 ? 10 : 12;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: screenWidth * 0.05,
            runSpacing: screenWidth * 0.02,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildStatItem(
                Icons.star_rounded,
                widget.provider.rating.toStringAsFixed(1),
                '${widget.provider.reviewCount} avis',
                Colors.amber,
                screenWidth,
              ),
              _buildStatItem(
                Icons.location_on_rounded,
                '${widget.provider.distance.toStringAsFixed(1)} km',
                'Distance',
                AppTheme.primaryBlue,
                screenWidth,
              ),
              _buildStatItem(
                Icons.work_rounded,
                '${widget.provider.completedJobs}',
                'Missions',
                Colors.green,
                screenWidth,
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.05),
          Text(
            'Spécialités',
            style: TextStyle(
              fontSize: fontSize + 0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.provider.specialties.map((specialty) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (AppTheme.primaryBlue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: smallFontSize - 0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: AppTheme.primaryBlue,
        labelStyle: TextStyle(fontSize: screenWidth < 600 ? 12 : 14),
        tabs: const [
          Tab(text: 'À propos'),
          Tab(text: 'Portfolio'),
          Tab(text: 'Avis'),
        ],
      ),
    );
  }

  Widget _buildAboutTab(double screenWidth) {
    final fontSize = screenWidth < 600 ? 12 : 14;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'À propos',
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Flexible(
            child: Text(
              widget.provider.description,
              style: TextStyle(
                fontSize: fontSize - 0,
                color: Colors.grey.shade600,
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildInfoRow(Icons.phone, widget.provider.phone, screenWidth: screenWidth),
          _buildInfoRow(Icons.location_city, widget.provider.address, screenWidth: screenWidth),
          _buildInfoRow(Icons.access_time, 'Temps de réponse: ${widget.provider.responseTime}', screenWidth: screenWidth),
          _buildInfoRow(Icons.monetization_on, 'Tarif: ${widget.provider.hourlyRate} FCFA/h', screenWidth: screenWidth),
          _buildInfoRow(
            Icons.check_circle,
            widget.provider.availability ? 'Disponible' : 'Non disponible',
            color: widget.provider.availability ? Colors.green : Colors.red,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(double screenWidth) {
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: widget.provider.portfolio.length,
        itemBuilder: (context, index) {
          final imagePath = widget.provider.portfolio[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Erreur de chargement de l'image portfolio: $error");
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab(double screenWidth) {
    final fontSize = screenWidth < 600 ? 12 : 14;
    final smallFontSize = screenWidth < 600 ? 10 : 12;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: screenWidth * 0.03),
            padding: EdgeInsets.all(screenWidth * 0.04),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: smallFontSize + 0,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: smallFontSize + 0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: Text(
                        'Utilisateur ${index + 1}',
                        style: TextStyle(
                          fontSize: fontSize - 0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: smallFontSize + 2,
                          color: Colors.amber.shade600,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${(4.0 + (index % 2)).toStringAsFixed(1)}',
                          style: TextStyle(fontSize: smallFontSize + 0),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Flexible(
                  child: Text(
                    'Service de qualité, très professionnel. Je recommande vivement !',
                    style: TextStyle(
                      fontSize: smallFontSize - 0,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomActions(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      contactName: widget.provider.name,
                      contactId: widget.provider.id,
                      isOnline: widget.provider.availability,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              ),
              child: Text(
                'Contacter',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showBookingForm();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              ),
              child: Text(
                'Réserver',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color, double screenWidth) {
    final double fontSize = screenWidth < 600 ? 12.0 : 14.0;
    final double smallFontSize = screenWidth < 600 ? 10.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: screenWidth < 600 ? 18 : 20,
          ),
        ),
        SizedBox(height: screenWidth * 0.015),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: screenWidth * 0.005),
        Text(
          label,
          style: TextStyle(
            fontSize: smallFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showBookingForm() {
    final nameController = TextEditingController(text: widget.provider.name);
    final dateController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final bottomInset = mediaQuery.viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Demande de réservation',
                    style: TextStyle(
                      fontSize: mediaQuery.size.width < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Prestataire',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date et heure souhaitées',
                      hintText: 'Ex: 25/12/2025 à 15h',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Détails de la demande',
                      hintText: 'Décrivez votre besoin, l’adresse, etc.',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Demande de réservation envoyée'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Envoyer la demande'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildInfoRow(IconData icon, String text, {Color? color, required double screenWidth}) {
  final double fontSize = screenWidth < 600 ? 12.0 : 14.0;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
    child: Row(
      children: [
        Icon(
          icon,
          size: fontSize + 2,
          color: color ?? Colors.grey.shade600,
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}