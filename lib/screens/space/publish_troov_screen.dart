import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../models/post_model.dart';

class PublishTroovScreen extends StatefulWidget {
  const PublishTroovScreen({Key? key}) : super(key: key);

  @override
  State<PublishTroovScreen> createState() => _PublishTroovScreenState();
}

class _PublishTroovScreenState extends State<PublishTroovScreen> {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final posts = await _postService.getUserPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int get _totalLikes => _posts.fold(0, (sum, post) => sum + post.likeCount);
  int get _totalViews => _posts.fold(0, (sum, post) => sum + post.viewCount);

  void _addNewPost(Post post) {
    setState(() {
      _posts.insert(0, post);
    });
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
        title: const Text(
          'Mes Publications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Erreur: $_error'))
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await _showCreatePostModal(context);
          if (result is Post) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Publication créée avec succès !'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Update list instantly
            _addNewPost(result);
          } else if (result == true) {
            _fetchUserPosts();
          }
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Publier'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    // Separate into columns for staggered effect
    final leftPosts = <Post>[];
    final rightPosts = <Post>[];
    for (int i = 0; i < _posts.length; i++) {
      if (i % 2 == 0) {
        leftPosts.add(_posts[i]);
      } else {
        rightPosts.add(_posts[i]);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Header Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(_posts.length.toString(), 'Posts'),
              _buildStat('$_totalViews', 'Vues'),
              _buildStat('$_totalLikes', 'Likes'),
            ],
          ),
          const SizedBox(height: 20),

          if (_posts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: const [
                  Icon(Icons.image_not_supported_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune publication encore.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            // Staggered Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children:
                        leftPosts.map((post) => _buildGridItem(post)).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Right Column
                Expanded(
                  child: Column(
                    children:
                        rightPosts.map((post) => _buildGridItem(post)).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 80), // Fab space
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(Post post) {
    final imageUrl = post.mediaUrls.isNotEmpty
        ? post.mediaUrls.first
        : 'https://via.placeholder.com/300?text=No+Image';

    return GestureDetector(
      onTap: () => _openImageDetail(context, imageUrl, post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              // Subtle gradient overlay for stats visibility
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(post.likeCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openImageDetail(BuildContext context, String imageUrl, Post post) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false, // Transparent background
      pageBuilder: (BuildContext context, _, __) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.95),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: post.id,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: Image.network(imageUrl, fit: BoxFit.contain)),
                  ),
                  const SizedBox(height: 30),
                  // Detailed Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailStat(Icons.favorite,
                          post.likeCount.toString(), Colors.redAccent),
                      const SizedBox(width: 40),
                      _buildDetailStat(Icons.chat_bubble,
                          post.commentCount.toString(), Colors.white),
                      const SizedBox(width: 40),
                      _buildDetailStat(Icons.remove_red_eye,
                          '${post.viewCount}', Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      post.description,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _buildDetailStat(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<dynamic> _showCreatePostModal(BuildContext context) {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostModal(),
    );
  }
}

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({Key? key}) : super(key: key);

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageController =
      TextEditingController(); // For URL input
  final PostService _postService = PostService();
  bool _isLoading = false;

  Future<void> _publish() async {
    if (_descController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newPost = await _postService.createPost(
        description: _descController.text,
        mediaUrls: _imageController.text.isNotEmpty
            ? [_imageController.text]
            : [
                'https://picsum.photos/400/500?random=${DateTime.now().millisecondsSinceEpoch}'
              ], // Random fallback
        category: 'General',
      );
      print('PublishTroovScreen: Post created successfully: ${newPost.id}');
      if (mounted) {
        Navigator.of(context).pop(newPost); // Just return, let parent handle UI
      }
    } catch (e) {
      print('Error publishing logic: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nouvelle publication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _publish,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publier',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement image picker. For now showing URL field.
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text('URL de l\'image (Temporaire)',
                              style: TextStyle(color: Colors.grey)),
                          TextField(
                            controller: _imageController,
                            decoration: const InputDecoration(
                              hintText: 'https://example.com/image.jpg',
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Quoi de neuf ?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.tag, size: 16),
                        label: const Text('Hashtag'),
                        onPressed: () {
                          _descController.text = "${_descController.text} #";
                          _descController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _descController.text.length));
                        },
                      ),
                      const SizedBox(width: 10),
                      ActionChip(
                        avatar: const Icon(Icons.alternate_email, size: 16),
                        label: const Text('Mentionner'),
                        onPressed: () {
                          _descController.text = "${_descController.text} @";
                          _descController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: _descController.text.length));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
