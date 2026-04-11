import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import '../../models/activity_model.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({Key? key}) : super(key: key);

  @override
  State<MyPurchasesScreen> createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActivityService _activityService = ActivityService();
  final AuthService _authService = AuthService();
  
  List<Activity> _allPurchases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final purchases = await _activityService.getActivitiesByUser(user.id);
        setState(() {
          _allPurchases = purchases.where((a) => a.type == ActivityType.PURCHASE).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Utilisateur non authentifié.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors du chargement des achats: $e";
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Activity> _getFilteredPurchases(bool isHistory) {
    if (isHistory) {
      return _allPurchases.where((a) => a.status == ActivityStatus.SOLD || a.status == ActivityStatus.DELIVERED || a.status == ActivityStatus.CANCELLED).toList();
    } else {
      return _allPurchases.where((a) => a.status == ActivityStatus.NEW || a.status == ActivityStatus.PENDING).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes Achats',
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
            Tab(text: 'Historique'),
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
                    _buildPurchasesList(isHistory: false),
                    _buildPurchasesList(isHistory: true),
                  ],
                ),
    );
  }

  Widget _buildPurchasesList({required bool isHistory}) {
    final filtered = _getFilteredPurchases(isHistory);
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('Aucun achat dans cette catégorie', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPurchases,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return _buildPurchaseCard(context, filtered[index]);
        },
      ),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, Activity activity) {
    bool isComplete = activity.status == ActivityStatus.SOLD || activity.status == ActivityStatus.DELIVERED;
    Color statusColor = isComplete ? Colors.green : (activity.status == ActivityStatus.CANCELLED ? Colors.red : Colors.orange);
    String statusText = isComplete ? 'Livré' : (activity.status == ActivityStatus.CANCELLED ? 'Annulé' : 'En route');

    final String title = activity.product?.title ?? 'Produit inconnu';
    final String price = activity.product?.price != null 
        ? '${NumberFormat("#,###", "fr_FR").format(activity.product!.price)} FCFA' 
        : 'Prix variable';
    final String date = DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt);
    final String imageUrl = (activity.product?.images != null && activity.product!.images.isNotEmpty)
        ? activity.product!.images.first
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () => _showPurchaseDetail(context, activity),
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
                      Text('REF: ${activity.id.substring(0, 5).toUpperCase()}',
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

  void _showPurchaseDetail(BuildContext context, Activity activity) {
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
            const Text('Détails de la commande',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: activity.provider?.logoUrl != null 
                      ? NetworkImage(activity.provider!.logoUrl!) 
                      : (activity.provider?.user?.profileImage != null ? NetworkImage(activity.provider!.user!.profileImage!) : null),
                  child: (activity.provider?.logoUrl == null && activity.provider?.user?.profileImage == null) ? const Icon(Icons.store) : null),
              title: Text('Boutique: ${activity.provider?.agencyName ?? activity.provider?.user?.pseudo ?? 'Prestataire'}'),
              subtitle: Text(activity.provider?.user?.phoneNumber ?? 'N/A'),
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
                  const Text('Statut de livraison',
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
