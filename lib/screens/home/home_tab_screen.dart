import 'package:flutter/material.dart';
import 'components/home_tab_header.dart';
import 'components/main_image_section.dart';
import 'components/product_section.dart';
import 'components/ads_section.dart';
import 'components/discover_section.dart';
import '../notifications/notifications_screen.dart';
import '../space/my_space_screen.dart';

import '../../services/story_service.dart';
import '../../services/product_service.dart';
import '../../services/provider_service.dart';
import '../../services/category_service.dart';
import '../../models/story_model.dart';
import '../../models/product.dart';
import '../../models/category_model.dart' as cm;
import 'story_view_screen.dart';
import '../../widgets/story_status_avatar.dart';
import 'create_text_status_screen.dart';
import 'create_media_status_screen.dart';
import 'package:image_picker/image_picker.dart';

class HomeTabScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToTransfer;
  final bool isDarkMode;

  const HomeTabScreen({
    Key? key,
    required this.onThemeToggle,
    required this.onLogout,
    required this.onProfile,
    required this.onNavigateToServices,
    required this.onNavigateToTransfer,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _HomeTabScreenState createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final StoryService _storyService = StoryService();
  final ProductService _productService = ProductService();
  final ProviderService _providerService = ProviderService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _picker = ImagePicker();

  List<Story> _myStories = [];
  List<Story> _otherStories = [];
  List<Product> _popularProducts = [];
  List<cm.Category> _categories = [];
  bool _isLoadingStories = true;
  bool _isLoadingData = true;
  bool _isProvider = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadStories(),
      _loadDynamicSections(),
    ]);
  }

  Future<void> _loadStories() async {
    setState(() => _isLoadingStories = true);
    try {
      final provider = await _providerService.getCurrentProvider();
      final myStories = await _storyService.getMyStatuses();
      final otherStories = await _storyService.getOtherStatuses();
      if (mounted) {
        setState(() {
          _isProvider = provider != null;
          _myStories = myStories;
          _otherStories = otherStories;
          _isLoadingStories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStories = false);
    }
  }

  Future<void> _loadDynamicSections() async {
    setState(() => _isLoadingData = true);
    try {
      final futures = await Future.wait([
        _productService.getAllProducts(),
        _providerService.getAllProviders(),
        _categoryService.getAllCategories(),
      ]);

      if (mounted) {
        setState(() {
          _popularProducts = (futures[0] as List<Product>)
            ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
          _categories = futures[2] as List<cm.Category>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  void _openStory(List<Story> stories, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewScreen(
          stories: stories,
          initialIndex: index,
        ),
      ),
    ).then((_) {
      _loadStories();
    });
  }

  void _createStory() {
    _showCreateStoryDialog();
  }

  void _showCreateStoryDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ajouter un statut",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Icons.edit,
                  color: Colors.grey[200]!,
                  iconColor: Colors.black,
                  label: "Texte",
                  onTap: () {
                    Navigator.pop(ctx);
                    _openTextCreation();
                  },
                ),
                _buildOption(
                  icon: Icons.image,
                  color: Colors.deepPurple[100]!,
                  iconColor: Colors.deepPurple,
                  label: "Galerie",
                  onTap: () {
                    Navigator.pop(ctx);
                    _showMediaOptions();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choisir une Image'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMedia(ImageSource.gallery, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Choisir une Vidéo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickMedia(ImageSource.gallery, isVideo: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    final XFile? file = isVideo 
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);
    
    if (file != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateMediaStatusScreen(mediaPath: file.path)),
      );

      if (result == true) {
        _loadStories();
      }
    }
  }

  Widget _buildOption(
      {required IconData icon,
      required Color color,
      required Color iconColor,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _openTextCreation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTextStatusScreen()),
    );
    if (result == true) {
      _loadStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
              minWidth: 320,
            ),
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeTabHeader(
                      onNotificationsTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      onProfileTap: widget.onProfile,
                      onMySpaceTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MySpaceScreen(),
                          ),
                        );
                      },
                      onLogoutTap: widget.onLogout,
                      onThemeToggle: widget.onThemeToggle,
                      isDarkMode: widget.isDarkMode,
                    ),
                    _buildStoriesBar(),
                    MainImageSection(
                      onDiscoverTap: () {},
                    ),
                    _buildHomeTaglineAndStats(context),
                    DiscoverSection(
                      onTap: widget.onNavigateToServices,
                    ),

                    ..._buildDynamicProductSections(),

                    AdsSection(onTap: widget.onNavigateToServices),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicProductSections() {
    if (_isLoadingData) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        )
      ];
    }

    List<Widget> sections = [];

    for (var cat in _categories) {
      final catProducts = _popularProducts
          .where((p) => p.category.toLowerCase() == cat.title.toLowerCase())
          .toList();

      if (catProducts.isEmpty) continue;

      String subtitle;
      List<Product> displayProducts = List.from(catProducts);

      if (cat.title.toLowerCase().contains('mobilier')) {
        subtitle = "le mobilier d'occasion à bon prix";
        displayProducts.sort((a, b) => a.numericPrice.compareTo(b.numericPrice));
      } else if (cat.title.toLowerCase().contains('transfert')) {
        subtitle = "transferts d'argent au meilleur prix";
      } else {
        subtitle = "${cat.title} de qualité";
      }

      final isFoodCategory = cat.title.toLowerCase().contains('cook') ||
          cat.title.toLowerCase().contains('food') ||
          cat.title.toLowerCase().contains('aliment') ||
          cat.title.toLowerCase().contains('cuisine') ||
          cat.title.toLowerCase().contains('repas');

      final prefix = isFoodCategory ? 'reTroov.' : 'Troov.';

      sections.add(
        ProductSection(
          title: "$prefix $subtitle",
          products: displayProducts,
          onProductTap: (_) => widget.onNavigateToServices(),
          onSeeMoreTap: widget.onNavigateToServices,
        ),
      );
    }

    return sections;
  }



  Widget _buildStoriesBar() {
    if (_isLoadingStories) {
      return Container(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final bool showMyStatus = _isProvider || _myStories.isNotEmpty;

    if (!showMyStatus && _otherStories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (showMyStatus ? 1 : 0) + _otherStories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (showMyStatus && index == 0) {
            return _buildMyStatusItem();
          }
          final storyIndex = showMyStatus ? index - 1 : index;
          final story = _otherStories[storyIndex];
          return _buildStoryItem(story, storyIndex);
        },
      ),
    );
  }

  Widget _buildMyStatusItem() {
    bool hasActiveStatus = _myStories.isNotEmpty;
    // Requirement: Even if status exists, user can add more.
    // If has status, onTap should offer choice: View or Add.

    if (!hasActiveStatus) {
      // If we are here, it means _isProvider is true (verified in _buildStoriesBar)
      return GestureDetector(
        onTap: _createStory,
        child: _buildAddStoryButton(),
      );
    }

    final first = _myStories.first;
    return GestureDetector(
      onTap: () {
        if (!_isProvider) {
          _openStory(_myStories, 0);
          return;
        }
        
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("Voir mon statut"),
                onTap: () {
                  Navigator.pop(context);
                  _openStory(_myStories, 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_a_photo),
                title: const Text("Ajouter au statut"),
                onTap: () {
                  Navigator.pop(context);
                  _createStory();
                },
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                StoryStatusAvatar(
                  imageUrl: first.authorImage,
                  radius: 30,
                  hasStory: true,
                  isRead: true,
                  isSponsored: false,
                  onTap: null,
                ),
                if (_isProvider)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Mon statut",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "Votre story",
            style: TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(Story story, int index) {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          StoryStatusAvatar(
            imageUrl: story.authorImage,
            radius: 30, // 60px diameter
            hasStory: true,
            isRead: story.isRead,
            isSponsored: story.isSponsored,
            onTap: () => _openStory(_otherStories, index),
          ),
          SizedBox(height: 6),
          Text(
            story.authorName,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTaglineAndStats(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    final isVerySmall = h < 600;

    final titleStyle = TextStyle(
      fontSize: isVerySmall ? 14 : (isSmall ? 16 : 18),
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "On est dans le même monde\nmais pas dans le même réseau",
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildStatsGrid(isVerySmall, isSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Divider(
            color: Colors.grey[500],
            thickness: 0.5,
            height: 30,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "On est fait pour être ensemble",
            style: TextStyle(
              fontSize: isVerySmall ? 11 : (isSmall ? 12 : 14),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(bool isVerySmall, bool isSmall) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem("+ 350 artisans", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem("+33 partenaires", isVerySmall, isSmall),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem("+ 8500 membres", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem(
                      "+ de 400 collaborateurs", isVerySmall, isSmall),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatItem(
                      "+ 769 produits en ligne", isVerySmall, isSmall),
                  const SizedBox(height: 2),
                  _buildStatItem("+ 4 pays", isVerySmall, isSmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String text, bool isVerySmall, bool isSmall) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isVerySmall ? 9 : (isSmall ? 10 : 11),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}
