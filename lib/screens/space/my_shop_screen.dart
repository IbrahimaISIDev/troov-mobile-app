import 'package:flutter/material.dart';
import 'my_services_form_screen.dart';
import '../../services/provider_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/product_service.dart';
import '../../models/provider_model.dart';
import '../../models/portfolio_model.dart';
import '../../models/product.dart';
import '../../services/activity_service.dart';
import '../../services/feedback_service.dart';
import '../../services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/activity_model.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({Key? key}) : super(key: key);

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProviderService _providerService = ProviderService();
  final PortfolioService _portfolioService = PortfolioService();
  final ProductService _productService = ProductService();
  final ActivityService _activityService = ActivityService();
  final FeedbackService _feedbackService = FeedbackService();
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  ProviderProfile? _provider;
  List<Portfolio> _portfolioItems = [];
  List<Product> _products = [];
  List<FeedbackModel> _feedbacks = [];
  List<Activity> _clientActivities = [];
  
  bool _isLoading = true;
  bool _isPublishing = false;
  String? _errorMessage;
  File? _realisationImage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _providerService.getCurrentProvider();
      if (profile != null) {
        final portfolio = await _portfolioService.getPortfolio(profile.id!);
        final products = await _productService.getProductsByProvider(profile.id!);
        final feedbacks = await _feedbackService.getProviderFeedbacks(profile.id!);
        final activities = await _activityService.getActivitiesByProvider(profile.id!);
        
        setState(() {
          _provider = profile;
          _portfolioItems = portfolio;
          _products = products;
          _feedbacks = feedbacks;
          _clientActivities = activities.where((a) => a.type == ActivityType.SALE).toList();
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
        _errorMessage = "Erreur lors du chargement des données: $e";
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 400,
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.black87),
                            onPressed: () {},
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz, color: Colors.black87),
                            onSelected: (value) {
                              if (value == 'add_service') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyServicesFormScreen(),
                                    fullscreenDialog: true,
                                  ),
                                );
                              }
                              if (value == 'add_realisation') {
                                _showAddRealisationModal(context);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'add_service', child: Text('Ajouter un service')),
                              const PopupMenuItem(value: 'add_realisation', child: Text('Ajouter réalisation')),
                            ],
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blueAccent, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey.shade100,
                                  backgroundImage: _provider?.logoUrl != null
                                      ? NetworkImage(_provider!.logoUrl!)
                                      : (_provider?.user?.profileImage != null
                                          ? NetworkImage(_provider!.user!.profileImage!)
                                          : null),
                                  child: (_provider?.logoUrl == null && _provider?.user?.profileImage == null)
                                      ? const Icon(Icons.storefront, size: 40, color: Colors.blueAccent)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _provider?.agencyName ?? _provider?.user?.pseudo ?? 'Mon Shop',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _provider?.profession ?? 'Prestataire Troov',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildHeaderStat(_provider?.totalMissions.toString() ?? '0', 'Missions'),
                                  _buildDivider(),
                                  _buildHeaderStat(_provider?.rating.toStringAsFixed(1) ?? '0.0', 'Note'),
                                  _buildDivider(),
                                  _buildHeaderStat(_provider?.reviewCount.toString() ?? '0', 'Avis'),
                                ],
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: 160,
                                height: 40,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showClientsModal(context),
                                  icon: const Icon(Icons.people_outline, size: 18),
                                  label: const Text('Mes clients'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        bottom: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.black87,
                          tabs: const [
                            Tab(text: 'Ma Bio'),
                            Tab(text: 'Mes réals'),
                            Tab(text: 'Avis'),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBioTab(),
                      _buildRealsTab(),
                      _buildAvisTab(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('À propos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(_provider?.bio ?? 'Aucune bio renseignée.', style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
          const SizedBox(height: 24),
          const Text('Spécialités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_provider?.specialties ?? []).map((s) => _buildChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRealsTab() {
    if (_portfolioItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey.shade200),
            const Text('Aucune réalisation'),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _portfolioItems.length,
      itemBuilder: (context, index) {
        final item = _portfolioItems[index];
        return GestureDetector(
          onTap: () => _openRealisationDetail(context, index),
          child: Hero(
            tag: 'real_${item.id}',
            child: Image.network(
              item.images.isNotEmpty ? item.images.first : 'https://picsum.photos/300',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvisTab() {
    if (_feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey.shade200),
            const Text('Aucun avis'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _feedbacks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildAvisSummary();
        final feedback = _feedbacks[index - 1];
        return _buildFeedbackCard(feedback);
      },
    );
  }

  Widget _buildAvisSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_provider?.rating.toStringAsFixed(1) ?? '0.0',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_provider != null && _provider!.rating >= 4 ? 'Excellent' : 'Bien',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                  Text('Basé sur ${_provider?.reviewCount ?? 0} avis', style: const TextStyle(color: Colors.black54)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('Derniers avis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: feedback.userProfileImage != null ? NetworkImage(feedback.userProfileImage!) : null,
                    child: feedback.userProfileImage == null ? const Icon(Icons.person, size: 15) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(feedback.userName ?? 'Utilisateur', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < (feedback.rating ?? 0) ? Colors.amber : Colors.grey.shade300)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback.comment ?? feedback.message ?? '', style: TextStyle(color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 20, color: Colors.grey.shade300);

  Widget _buildChip(String label) => Chip(label: Text(label), backgroundColor: Colors.white, shape: const StadiumBorder(side: BorderSide(color: Color(0xFFEEEEEE))));

  void _showAddRealisationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nouvelle Réalisation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _isPublishing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton(onPressed: () => _handlePublishRealisation(context), child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setModalState(() => _realisationImage = File(image.path));
                            setState(() {}); // Update main UI if needed
                          }
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            image: _realisationImage != null ? DecorationImage(image: FileImage(_realisationImage!), fit: BoxFit.cover) : null,
                          ),
                          child: _realisationImage == null ? const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey) : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Titre', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Ex: Tresses collées')),
                      const SizedBox(height: 20),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(hintText: 'Décrivez votre travail...')),
                      const SizedBox(height: 20),
                      const Text('Lier à un service', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<String>(
                        value: _selectedProductId,
                        items: _products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title))).toList(),
                        onChanged: (v) => setModalState(() => _selectedProductId = v),
                        decoration: const InputDecoration(hintText: 'Sélectionner un service'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePublishRealisation(BuildContext context) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }
    setState(() => _isPublishing = true);
    try {
      String? imageUrl;
      if (_realisationImage != null) {
        imageUrl = await _postService.uploadImage(_realisationImage!);
      }
      final newItem = await _portfolioService.createPortfolioItem(
        _provider!.id!,
        title: _titleController.text,
        description: _descriptionController.text,
        productId: _selectedProductId,
        images: imageUrl != null ? [imageUrl] : [],
      );
      if (newItem != null) {
        setState(() {
          _portfolioItems.insert(0, newItem);
          _isPublishing = false;
          _titleController.clear();
          _descriptionController.clear();
          _realisationImage = null;
          _selectedProductId = null;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réalisation publiée !')));
      }
    } catch (e) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _showClientsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(padding: EdgeInsets.all(20), child: Text('Mes Clients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(
              child: _clientActivities.isEmpty
                  ? const Center(child: Text('Aucun client pour le moment.'))
                  : ListView.builder(
                      itemCount: _clientActivities.length,
                      itemBuilder: (context, index) {
                        final activity = _clientActivities[index];
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: activity.user?.profileImage != null ? NetworkImage(activity.user!.profileImage!) : null, child: activity.user?.profileImage == null ? const Icon(Icons.person) : null),
                          title: Text(activity.user?.pseudo ?? 'Client'),
                          subtitle: Text('Le ${activity.createdAt.day}/${activity.createdAt.month}/${activity.createdAt.year}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRealisationDetail(BuildContext context, int index) {
    final item = _portfolioItems[index];
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Hero(
            tag: 'real_${item.id}',
            child: Image.network(item.images.isNotEmpty ? item.images.first : 'https://picsum.photos/600'),
          ),
        ),
      ),
    ));
  }
}
