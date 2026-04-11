import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/provider_service.dart';
import '../../services/activity_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/product_service.dart';
import '../../services/post_service.dart';
import '../../models/provider_model.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ProviderService _providerService = ProviderService();
  final ActivityService _activityService = ActivityService();
  final PortfolioService _portfolioService = PortfolioService();
  final ProductService _productService = ProductService();
  final PostService _postService = PostService();

  bool _isLoading = true;
  ProviderProfile? _provider;
  int _salesCount = 0;
  int _purchasesCount = 0;
  int _portfolioCount = 0;
  int _productsCount = 0;
  int _postsCount = 0;
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  int _clientCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _providerService.getCurrentProvider();
      if (profile != null) {
        final sales = await _activityService.getActivitiesByProvider(profile.id!);
        final user = await _postService.authService.getCurrentUser();
        List<Activity> purchases = [];
        if (user != null) {
          purchases = await _activityService.getActivitiesByUser(user.id);
          final userPosts = await _postService.getUserPosts();
          _postsCount = userPosts.length;
        }

        final portfolios = await _portfolioService.getPortfolio(profile.id!);
        final products = await _productService.getProductsByProvider(profile.id!);
        
        // Calculate revenue & expenses
        double revenue = 0;
        for (var sale in sales) {
          if (sale.type == ActivityType.SALE && (sale.status == ActivityStatus.SOLD || sale.status == ActivityStatus.DELIVERED)) {
            revenue += sale.product?.numericPrice ?? 0.0;
          }
        }

        double expenses = 0;
        for (var purchase in purchases) {
          if (purchase.type == ActivityType.PURCHASE && (purchase.status == ActivityStatus.SOLD || purchase.status == ActivityStatus.DELIVERED)) {
            expenses += purchase.product?.numericPrice ?? 0.0;
          }
        }

        if (mounted) {
          setState(() {
            _provider = profile;
            _salesCount = sales.length;
            _purchasesCount = purchases.length;
            _portfolioCount = portfolios.length;
            _productsCount = products.length;
            _totalRevenue = revenue;
            _totalExpenses = expenses;
            _clientCount = sales.map((s) => s.user?.id).whereType<String>().toSet().length;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final currencyFormat = NumberFormat("#,###", "fr_FR");
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ranking Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.blue.shade500]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8.w(),
                            backgroundColor: Colors.white,
                            child: Icon(Icons.emoji_events,
                                color: Colors.orange, size: 8.w()),
                          ),
                          SizedBox(width: 5.w()),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_provider != null && _provider!.rating >= 4.5 
                                    ? 'Classement: Super Vendeur' 
                                    : 'Classement: Vendeur Troov',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp())),
                                const SizedBox(height: 5),
                                Text('Basé sur ${_provider?.totalMissions ?? 0} missions',
                                    style:
                                        const TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                    value: (_provider?.rating ?? 0) / 5.0,
                                    backgroundColor: Colors.white24,
                                    color: Colors.amber),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildSectionTitle('Finances'),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            child: _buildSummaryCard('Revenus', '${currencyFormat.format(_totalRevenue)} FCFA',
                                Icons.arrow_upward, Colors.green)),
                        SizedBox(width: 4.w()),
                        Expanded(
                            child: _buildSummaryCard('Dépenses', '${currencyFormat.format(_totalExpenses)} FCFA',
                                Icons.arrow_downward, Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Engagement Grid
                    _buildSectionTitle('Engagement & Activité'),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 4.w(),
                      mainAxisSpacing: 4.w(),
                      children: [
                        _buildStatTile(
                            'Publications', _postsCount.toString(), Icons.grid_view, Colors.purple),
                        _buildStatTile('Note Avis', '${_provider?.rating.toStringAsFixed(1) ?? "0.0"}/5', Icons.star, Colors.amber),
                        _buildStatTile(
                            'Services', _productsCount.toString(), Icons.store_mall_directory_outlined, Colors.blue),
                        _buildStatTile('Avis reçus', _provider?.reviewCount.toString() ?? "0", Icons.chat, Colors.pink),
                      ],
                    ),

                    const SizedBox(height: 25),
                    // Business Stats
                    _buildSectionTitle('Mon Business'),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _buildRowStat(
                              'Mes Ventes', _salesCount.toString(), Icons.shopping_bag_outlined),
                          const Divider(),
                          _buildRowStat(
                              'Mes Achats', _purchasesCount.toString(), Icons.shopping_cart_outlined),
                          const Divider(),
                          _buildRowStat('Mes Clients', _clientCount.toString(), Icons.people_outline),
                          const Divider(),
                          _buildRowStat(
                              'Réalisations', _portfolioCount.toString(), Icons.camera_alt_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 6.w()),
          SizedBox(height: 1.h()),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 18.sp(), fontWeight: FontWeight.bold, color: color)),
          ),
          Text(title, style: TextStyle(fontSize: 12.sp(), color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 7.w()),
          SizedBox(height: 1.h()),
          Text(value,
              style:
                  TextStyle(fontSize: 20.sp(), fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12.sp(), color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRowStat(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 5.w()),
              SizedBox(width: 3.w()),
              Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp())),
            ],
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp())),
        ],
      ),
    );
  }
}
