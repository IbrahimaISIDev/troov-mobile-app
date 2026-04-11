import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'publish_troov_screen.dart';
import 'stats_screen.dart';
import 'my_shop_screen.dart';
import 'my_sales_screen.dart';
import 'my_purchases_screen.dart';
import 'my_services_screen.dart';
import '../chat/chat_screen.dart';
import '../../services/post_service.dart';
import '../../services/provider_service.dart';
import '../../services/activity_service.dart';
import '../../services/portfolio_service.dart';
import '../../models/post_model.dart';
import '../../models/activity_model.dart';
import '../../models/provider_model.dart';
import '../../models/portfolio_model.dart';
import 'provider_registration_screen.dart';

class MySpaceScreen extends StatefulWidget {
  const MySpaceScreen({Key? key}) : super(key: key);

  @override
  State<MySpaceScreen> createState() => _MySpaceScreenState();
}

class _MySpaceScreenState extends State<MySpaceScreen> {
  bool _isSalesExpanded = false;
  bool _isPurchasesExpanded = false;
  bool _isProvider = false;
  bool _checkingProvider = true;
  
  final PostService _postService = PostService();
  final ProviderService _providerService = ProviderService();
  final ActivityService _activityService = ActivityService();
  final PortfolioService _portfolioService = PortfolioService();
  
  late Future<List<Post>> _userPostsFuture;
  List<Activity> _recentSales = [];
  List<Activity> _recentPurchases = [];
  ProviderProfile? _currentProvider;
  List<Portfolio> _recentPortfolios = [];

  @override
  void initState() {
    super.initState();
    _userPostsFuture = _postService.getUserPosts();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _checkingProvider = true);
    try {
      final provider = await _providerService.getCurrentProvider();
      if (mounted) {
        setState(() {
          _isProvider = provider != null;
          _currentProvider = provider;
          _checkingProvider = false;
        });
        
        if (provider != null) {
          _loadProviderData(provider.id!);
        }
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProvider = false;
          _checkingProvider = false;
        });
      }
    }
  }

  Future<void> _loadProviderData(String providerId) async {
    try {
      final sales = await _activityService.getActivitiesByProvider(providerId);
      final portfolios = await _portfolioService.getPortfolio(providerId);
      if (mounted) {
        setState(() {
          _recentSales = sales.where((a) => a.type == ActivityType.SALE).toList();
          _recentPortfolios = portfolios;
        });
      }
    } catch (e) {
      debugPrint('Error loading provider data: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _postService.authService.getCurrentUser();
      if (user != null) {
        final purchases = await _activityService.getActivitiesByUser(user.id);
        if (mounted) {
          setState(() {
            _recentPurchases = purchases.where((a) => a.type == ActivityType.PURCHASE).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mon espace',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined,
                  color: Colors.black87, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatScreen(showBack: true)),
                );
              },
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _checkingProvider
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gérez vos services et vos publications Troov.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isProvider
                          ? 'Ajoutez vos prestations, mettez-les en avant et publiez-les dans le fil Troov pour être visible comme les autres prestataires.'
                          : 'Publiez des annonces dans le fil Troov et suivez vos achats ou devenez prestataire pour vendre vos services.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_isProvider) ...[
                      _buildShopPreviewCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyShopScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildPublishSection(context),
                    const SizedBox(height: 15),

                    if (!_isProvider) ...[
                      _buildMenuCard(
                        icon: Icons.person_add_rounded,
                        title: 'Devenir prestataire',
                        subtitle: 'Crée ton profil et commence à vendre.',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ProviderRegistrationScreen()),
                          ).then((_) => _loadAllData());
                        },
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 15),
                    ],

                    if (_isProvider) ...[
                      _buildMenuCard(
                        icon: Icons.style_rounded,
                        title: 'Mes services',
                        subtitle: 'Gérez et créez vos prestations.',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyServicesScreen()),
                          ).then((_) => _loadAllData());
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildExpandableCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'Mes ventes',
                        subtitle: 'Troov des clients pour ton produit maintenant',
                        isExpanded: _isSalesExpanded,
                        onTap: () {
                          setState(() {
                            _isSalesExpanded = !_isSalesExpanded;
                            if (_isSalesExpanded) _isPurchasesExpanded = false;
                          });
                        },
                        activities: _recentSales,
                        onSeeMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MySalesScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                    ],

                    _buildExpandableCard(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Mes achats',
                      subtitle: 'Suivez vos commandes et achats.',
                      isExpanded: _isPurchasesExpanded,
                      onTap: () {
                        setState(() {
                          _isPurchasesExpanded = !_isPurchasesExpanded;
                          if (_isPurchasesExpanded) _isSalesExpanded = false;
                        });
                      },
                      activities: _recentPurchases,
                      onSeeMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyPurchasesScreen()),
                        );
                      },
                    ),

                    if (_isProvider) ...[
                      const SizedBox(height: 15),
                      _buildMenuCard(
                        icon: Icons.analytics_rounded,
                        title: 'Statistiques',
                        subtitle: 'Voir les vues et les contacts générés.',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StatsScreen()),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPublishSection(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PublishTroovScreen()),
            ).then((_) {
              setState(() {
                _userPostsFuture = _postService.getUserPosts();
              });
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.video_collection_rounded,
                      color: Colors.black54),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Publier dans Troov',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Préparer une annonce à afficher dans le feed Troov.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Post>>(
            future: _userPostsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final posts = snapshot.data!;
              final displayPosts = posts.take(3).toList();
              List<Widget> children = [];
              for (int i = 0; i < displayPosts.length; i++) {
                final post = displayPosts[i];
                double height = 120;
                double width = 100;
                bool isCenter = false;
                if (displayPosts.length == 3 && i == 1) {
                  height = 140;
                  width = 110;
                  isCenter = true;
                }
                final mediaUrl = post.mediaUrl ?? '';
                final bool isVideo = mediaUrl.toLowerCase().contains('.mp4') || 
                                     mediaUrl.toLowerCase().contains('.mov') || 
                                     mediaUrl.toLowerCase().contains('.m4v');
                children.add(_buildTopImageCard(post.getThumbnailUrl(),
                    rank: i + 1,
                    height: height,
                    width: width,
                    isCenter: isCenter,
                    likes: post.likeCount.toString(),
                    comments: post.commentCount.toString(),
                    isVideo: isVideo));
                if (i < displayPosts.length - 1) {
                  children.add(const SizedBox(width: 8));
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                ),
              );
            }),
      ],
    );
  }

  Widget _buildTopImageCard(String url,
      {required int rank,
      required double height,
      required double width,
      bool isCenter = false,
      String likes = '0',
      String comments = '0',
      bool isVideo = false}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isVideo)
            const Center(child: Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 30)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 10),
                  const SizedBox(width: 1),
                  Text(likes,
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chat_bubble_outline, size: 10),
                  const SizedBox(width: 1),
                  Text(comments,
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopPreviewCard({required VoidCallback onTap}) {
    final String agencyName = _currentProvider?.agencyName ?? _currentProvider?.user?.pseudo ?? 'Mon Shop';
    final String profession = _currentProvider?.profession ?? 'Prestataire';
    final String logoUrl = _currentProvider?.logoUrl ?? _currentProvider?.user?.profileImage ?? 'https://via.placeholder.com/150';
    final double rating = _currentProvider?.rating ?? 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.black54),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ma boutique',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Améliore d\'avantage ton profil',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Ma Bio',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(logoUrl),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agencyName,
                      style:
                          const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      profession,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Mes réals',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _recentPortfolios.isEmpty 
                        ? [const Text('Aucune', style: TextStyle(fontSize: 10, color: Colors.grey))]
                        : _recentPortfolios.take(3).map((p) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _buildTinyImg(p.images.isNotEmpty ? p.images.first : 'https://via.placeholder.com/150'),
                          )).toList(),
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Mes stats',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) => Icon(
                        Icons.star, 
                        size: 12, 
                        color: index < rating.floor() ? Colors.amber : Colors.grey.shade300
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Text(_currentProvider?.totalMissions.toString() ?? '0',
                          style: const TextStyle(fontSize: 10, color: Colors.white)),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTinyImg(String url, {double height = 50}) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color ?? Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Activity> activities,
    required VoidCallback onSeeMore,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 10),
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Aucune activité récente', style: TextStyle(color: Colors.grey)),
              )
            else
              ...activities
                  .take(3)
                  .map((activity) => _buildTransactionItemFromActivity(activity, onTap: () {
                        bool isSale = title.toLowerCase().contains('ventes');
                        _showActivityDetail(context, activity, isSale: isSale);
                      })),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSeeMore,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade50,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voir plus',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTransactionItemFromActivity(Activity activity, {VoidCallback? onTap}) {
    final String title = activity.product?.title ?? 'Produit inconnu';
    final String price = activity.product?.price != null ? '${NumberFormat("#,###", "fr_FR").format(activity.product!.price)} FCFA' : 'Prix variable';
    final String date = DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt);
    final String imageUrl = (activity.product?.images != null && activity.product!.images.isNotEmpty)
        ? activity.product!.images.first
        : 'https://via.placeholder.com/150';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, width: 45, height: 45, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(BuildContext context, Activity activity, {required bool isSale}) {
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
            Text(isSale ? 'Détails de la vente' : 'Détails de l\'achat',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: isSale 
                    ? (activity.user?.profileImage != null ? NetworkImage(activity.user!.profileImage!) : null)
                    : (activity.provider?.logoUrl != null ? NetworkImage(activity.provider!.logoUrl!) : (activity.provider?.user?.profileImage != null ? NetworkImage(activity.provider!.user!.profileImage!) : null))),
              title: Text(isSale ? 'Client: ${activity.user?.pseudo ?? 'Utilisateur'}' : 'Boutique: ${activity.provider?.agencyName ?? activity.provider?.user?.pseudo ?? 'Prestataire'}'),
              subtitle: Text(isSale ? (activity.user?.phoneNumber ?? 'N/A') : (activity.provider?.user?.phoneNumber ?? 'N/A')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.message, color: Colors.blue), onPressed: () {}),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('Récapitulatif',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Produit: ${activity.product?.title ?? 'N/A'}'),
                  Text('Prix: ${activity.product?.price != null ? NumberFormat("#,###", "fr_FR").format(activity.product!.price) : '0'} FCFA'),
                  Text('Date: ${DateFormat('dd/MM/yyyy HH:mm').format(activity.createdAt)}'),
                  Text('Statut: ${activity.status.toString().split('.').last}'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
