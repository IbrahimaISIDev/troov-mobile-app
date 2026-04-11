import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/activity_service.dart';
import '../../services/provider_service.dart';
import '../../models/activity_model.dart';

class MySalesScreen extends StatefulWidget {
  const MySalesScreen({Key? key}) : super(key: key);

  @override
  State<MySalesScreen> createState() => _MySalesScreenState();
}

class _MySalesScreenState extends State<MySalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActivityService _activityService = ActivityService();
  final ProviderService _providerService = ProviderService();
  
  List<Activity> _allSales = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = await _providerService.getCurrentProvider();
      if (provider != null) {
        final sales = await _activityService.getActivitiesByProvider(provider.id!);
        setState(() {
          _allSales = sales.where((a) => a.type == ActivityType.SALE).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Profil prestataire non trouvé.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors du chargement des ventes: $e";
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Activity> _getFilteredSales(String statusGroup) {
    switch (statusGroup) {
      case 'pending':
        return _allSales.where((a) => a.status == ActivityStatus.NEW || a.status == ActivityStatus.PENDING).toList();
      case 'completed':
        return _allSales.where((a) => a.status == ActivityStatus.SOLD || a.status == ActivityStatus.DELIVERED).toList();
      case 'cancelled':
        return _allSales.where((a) => a.status == ActivityStatus.CANCELLED).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes Ventes',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSalesList(statusGroup: 'pending'),
                    _buildSalesList(statusGroup: 'completed'),
                    _buildSalesList(statusGroup: 'cancelled'),
                  ],
                ),
    );
  }

  Widget _buildSalesList({required String statusGroup}) {
    final filteredSales = _getFilteredSales(statusGroup);
    
    if (filteredSales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('Aucune vente dans cette catégorie', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSales,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: filteredSales.length,
        itemBuilder: (context, index) {
          return _buildSaleCard(context, filteredSales[index]);
        },
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Activity activity) {
    Color statusColor;
    String statusText;

    switch (activity.status) {
      case ActivityStatus.SOLD:
      case ActivityStatus.DELIVERED:
        statusColor = Colors.green;
        statusText = 'Vendu';
        break;
      case ActivityStatus.CANCELLED:
        statusColor = Colors.red;
        statusText = 'Annulé';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'En cours';
    }

    final String title = activity.product?.title ?? 'Produit inconnu';
    final String price = activity.product?.price != null 
        ? '${NumberFormat("#,###", "fr_FR").format(activity.product!.price)} FCFA' 
        : 'Prix variable';
    final String date = DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt);
    final String imageUrl = (activity.product?.images != null && activity.product!.images.isNotEmpty)
        ? activity.product!.images.first
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () => _showSaleDetail(context, activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis)),
                      Text(price,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(date,
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text('ID: ${activity.id.substring(0, 8)}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const Text('Tous les détails',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaleDetail(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Détails de la vente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: activity.user?.profileImage != null 
                      ? NetworkImage(activity.user!.profileImage!) 
                      : null,
                  child: activity.user?.profileImage == null ? const Icon(Icons.person) : null),
              title: Text('Client: ${activity.user?.pseudo ?? 'Utilisateur'}'),
              subtitle: Text(activity.user?.phone ?? 'Pas de numéro'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.message, color: Colors.blue),
                      onPressed: () {}),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Récapitulatif',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Produit: ${activity.product?.title ?? 'N/A'}'),
                  Text('Prix: ${activity.product?.price != null ? NumberFormat("#,###", "fr_FR").format(activity.product!.price) : '0'} FCFA'),
                  Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt)}'),
                  const SizedBox(height: 20),
                  const Text('Statut actuel',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(activity.status.toString().split('.').last),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
