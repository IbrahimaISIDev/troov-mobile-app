import 'package:flutter/material.dart';
import 'components/home_tab_header.dart';
import 'components/main_image_section.dart';
import 'components/product_section.dart';
import '../notifications/notifications_screen.dart';
import '../space/my_space_screen.dart';

import '../../services/story_service.dart';
import '../../models/story_model.dart';
import 'story_view_screen.dart';
import '../../widgets/story_status_avatar.dart';
import 'create_text_status_screen.dart';
import 'create_media_status_screen.dart';

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
  List<Story> _myStories = [];
  List<Story> _otherStories = [];
  bool _isLoadingStories = true;
  // Combine for viewing? Or separate viewers?
  // Usually story viewer takes a list.
  // If we open "My Story", list is [MyStory].
  // If we open "Others", list can be all others?

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoadingStories = true);
    final myStories = await _storyService.getMyStatuses();
    final otherStories = await _storyService.getOtherStatuses();

    // Also refresh cache for helper methods if needed elsewhere
    // _storyService.refreshStories(); // If we strictly use service state.
    // But here we manage state locally in widget.

    if (mounted) {
      setState(() {
        _myStories = myStories;
        _otherStories = otherStories;
        _isLoadingStories = false;
      });
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
      // Refresh when coming back (to update viewed status)
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
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ajouter un statut",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
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
                    _simulateMediaPicker();
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
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
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _openTextCreation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTextStatusScreen()),
    );
    if (result == true) {
      _loadStories();
    }
  }

  void _simulateMediaPicker() async {
    // Logic: User picks image -> We get path -> Open Preview
    // Simulating picking an image
    await Future.delayed(Duration(milliseconds: 500));
    // Mock result
    final String mockPath =
        "https://picsum.photos/400/800"; // Random vertical image

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateMediaStatusScreen(mediaPath: mockPath)),
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
            child: SingleChildScrollView(
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
                  // ... rest of children ...
                  MainImageSection(
                    onDiscoverTap: () {},
                  ),
                  _buildHomeTaglineAndStats(context),
                  ProductSection(
                    title: "Troov. le mobilier d'occasion à bon prix",
                    images: const [
                      'assets/images/image.png',
                      'assets/images/image3.png',
                      'assets/images/image4.png',
                    ],
                    onProductTap: (index) {
                      widget.onNavigateToServices();
                    },
                    onSeeMoreTap: () {
                      // TODO: action Voir plus Mobilier
                    },
                  ),
                  ProductSection(
                    title: "Troov. transferts d'argent au meilleur prix",
                    images: const [
                      'assets/images/image1.png',
                      'assets/images/image2.png',
                      'assets/images/image5.png',
                    ],
                    onProductTap: (index) {
                      widget.onNavigateToTransfer();
                    },
                    onSeeMoreTap: () {
                      // TODO: action Voir plus Transferts
                    },
                  ),
                  const SizedBox(height: 100), // Espace pour la navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesBar() {
    if (_isLoadingStories) {
      return Container(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 110,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // Item 0 is "My Status". Subsequent items are others.
        itemCount: 1 + _otherStories.length,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildMyStatusItem();
          }
          final story = _otherStories[index - 1];
          return _buildStoryItem(story, index - 1);
        },
      ),
    );
  }

  Widget _buildMyStatusItem() {
    bool hasActiveStatus = _myStories.isNotEmpty;
    // Requirement: Even if status exists, user can add more.
    // If has status, onTap should offer choice: View or Add.

    if (!hasActiveStatus) {
      return GestureDetector(
        onTap: _createStory,
        child: _buildAddStoryButton(),
      );
    }

    // Has Status
    final first = _myStories.first;
    // Check if we have a valid image URL for the user avatar (from story or logic)
    // If no authorImage or it's empty, use fallback.
    return GestureDetector(
      onTap: () {
        // Show menu to View or Add
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text("Voir mon statut"),
                onTap: () {
                  Navigator.pop(context);
                  _openStory(_myStories, 0);
                },
              ),
              ListTile(
                leading: Icon(Icons.add_a_photo),
                title: Text("Ajouter au statut"),
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
        margin: EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                StoryStatusAvatar(
                  imageUrl: first.authorImage,
                  radius: 30, // 60px diameter
                  hasStory: true,
                  isRead: true, // Use Grey for "My Status" usually
                  isSponsored: false,
                  onTap: null, // Handled by parent GestureDetector
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
                      child: Icon(Icons.add, size: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
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
