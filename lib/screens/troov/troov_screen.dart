import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../services/service_provider_detail.dart';
import '../../models/service_model.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../services/websocket_service.dart';
import '../../services/auth_service.dart';
import 'dart:async';
import 'package:visibility_detector/visibility_detector.dart';

class TroovScreen extends StatefulWidget {
  const TroovScreen({Key? key}) : super(key: key);

  @override
  State<TroovScreen> createState() => _TroovScreenState();
}

class _TroovScreenState extends State<TroovScreen> {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  List<Post> _pendingPosts = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _feedSubscription;
  static const int _newPostsThreshold = 10;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _initWebSocket();
  }

  void _loadFeed() async {
    print('TroovScreen: Loading feed...');
    try {
      final posts = await _postService.getFeed();
      print('TroovScreen: Feed loaded with ${posts.length} posts');
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('TroovScreen: Error loading feed: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _initWebSocket() {
    try {
      WebSocketService().connect();
      _feedSubscription = WebSocketService().feedStream.listen((newPost) {
        print('TroovScreen: New post received via WS');
        if (mounted) {
          setState(() {
            // Check if post is already in main list or pending list
            if (!_posts.any((p) => p.id == newPost.id) &&
                !_pendingPosts.any((p) => p.id == newPost.id)) {
              _pendingPosts.insert(0, newPost);
            }
          });
        }
      });
    } catch (e) {
      print('TroovScreen: WebSocket Error detected: $e');
    }
  }

  void _showNewPosts() {
    setState(() {
      _posts.insertAll(0, _pendingPosts);
      _pendingPosts.clear();
      // Code to scroll to top could be added here if we had a controller accessible
      // Since it's PageView, it might be tricky without controller, but inserts at 0 usually shift context.
      // Actually PageView inserts might act weird if we are not at 0.
      // Ideally we should jump to page 0.
    });
  }

  @override
  void dispose() {
    _feedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                            _loadFeed();
                          });
                        },
                        child: const Text("Réessayer"),
                      )
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? const Center(
                      child: Text('Aucune publication pour le moment.',
                          style: TextStyle(color: Colors.white)))
                  : Stack(
                      children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return _TroovPostItem(
                                key: ValueKey(_posts[index].id),
                                post: _posts[index]);
                          },
                        ),
                        if (_pendingPosts.length >= _newPostsThreshold)
                          Positioned(
                            top: 60, // Below status bar
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: _showNewPosts,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Nouvelles publications (${_pendingPosts.length})",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}

ServiceProvider _buildProviderFromPost(Post post) {
  // Map simplified Post/User data to ServiceProvider for the detail view
  return ServiceProvider(
    id: post.author.id,
    name: post.author.fullName, // Using fullName or firstName
    rating: 4.5, // Placeholder
    distance: 1.2, // Placeholder
    reviewCount: 15, // Placeholder
    profileImage: post.author.profileImage,
    specialties: ['Service Troov'],
    description: post.description,
    phone: '+221 77 000 00 00', // Placeholder
    address: 'Dakar, Sénégal', // Placeholder
    isVerified: true,
    responseTime: '2h',
    completedJobs: 10,
    hourlyRate: 0,
    availability: true,
    portfolio: post.mediaUrls,
  );
}

class _TroovPostItem extends StatefulWidget {
  final Post post;

  const _TroovPostItem({Key? key, required this.post}) : super(key: key);

  @override
  State<_TroovPostItem> createState() => _TroovPostItemState();
}

class _TroovPostItemState extends State<_TroovPostItem> {
  late int _likeCount;
  late int _commentCount;
  late bool _isLiked;
  late int _viewCount;
  final PostService _postService = PostService();
  StreamSubscription? _likeSubscription;
  StreamSubscription? _viewSubscription;
  StreamSubscription? _commentSubscription;
  StreamSubscription? _commentCountSubscription;
  Timer? _viewTimer;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
    _viewCount = widget.post.viewCount;
    _commentCount = widget.post.commentCount;
    _commentCount = widget.post.commentCount;
    _loadCurrentUser();
    _refreshPostData();
    _subscribeToLikes();
    _subscribeToViews();
    _subscribeToComments();
  }

  Future<void> _refreshPostData() async {
    try {
      final updatedPost = await _postService.getPostById(widget.post.id);
      if (mounted) {
        setState(() {
          _isLiked = updatedPost.isLiked;
          _likeCount = updatedPost.likeCount;
          _commentCount = updatedPost.commentCount;
          _viewCount = updatedPost.viewCount;
        });
      }
    } catch (e) {
      print("Error refreshing post data: $e");
    }
  }

  void _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.id;
      });
    }
  }

  void _subscribeToLikes() {
    WebSocketService().subscribeToPostLikes(widget.post.id);
    _likeSubscription = WebSocketService().postLikesStream.listen((data) {
      if (data['postId'] == widget.post.id && mounted) {
        setState(() {
          _likeCount = data['likeCount'];
          if (_currentUserId != null && data['userId'] == _currentUserId) {
            _isLiked = data['isLiked'];
          }
        });
      }
    });
  }

  void _subscribeToComments() {
    // 1. New comments (for list/append, if needed)
    WebSocketService().subscribeToPostComments(widget.post.id);
    _commentSubscription = WebSocketService().postCommentsStream.listen((data) {
      if (data['postId'] == widget.post.id && mounted) {
        // We actually handle count updates via a separate stream now for accuracy
        // But let's keep this if we want to update the Bubble implicitly
        // Actually, let's rely on the COUNT stream for the Bubble count.
      }
    });

    // 2. Comment Count (for Bubble)
    WebSocketService().subscribeToPostCommentCount(widget.post.id);
    _commentCountSubscription =
        WebSocketService().postCommentCountStream.listen((data) {
      if (data['postId'] == widget.post.id && mounted) {
        setState(() {
          _commentCount = data['commentCount'];
        });
      }
    });
  }

  void _subscribeToViews() {
    WebSocketService().subscribeToPostViews(widget.post.id);
    _viewSubscription = WebSocketService().postViewsStream.listen((data) {
      if (data['postId'] == widget.post.id && mounted) {
        setState(() {
          _viewCount = data['viewCount'];
        });
      }
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      _startViewTimer();
    } else {
      _stopViewTimer();
    }
  }

  void _startViewTimer() {
    _viewTimer?.cancel();
    _viewTimer = Timer(const Duration(seconds: 3), () {
      _postService.incrementViewCount(widget.post.id);
    });
  }

  void _stopViewTimer() {
    _viewTimer?.cancel();
  }

  @override
  void dispose() {
    _likeSubscription?.cancel();
    _viewSubscription?.cancel();
    _commentSubscription?.cancel();
    _commentCountSubscription?.cancel();
    _viewTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await _postService.toggleLikePost(widget.post.id);
    } catch (e) {
      // Revert if error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du like')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mediaUrl = widget.post.mediaUrls.isNotEmpty
        ? widget.post.mediaUrls.first
        : 'https://via.placeholder.com/800x1200.png?text=No+Image';

    return VisibilityDetector(
      key: Key('post_${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          // Media plein écran
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Image.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Side Action Bar (Right)
          Positioned(
            right: 16,
            bottom: 100, // Adjusted position
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Views
                Column(
                  children: [
                    const Icon(Icons.remove_red_eye_rounded,
                        color: Colors.white, size: 30),
                    const SizedBox(height: 4),
                    Text(
                      '${_viewCount}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Profile Picture
                GestureDetector(
                  onTap: () {
                    final provider = _buildProviderFromPost(widget.post);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProviderDetail(
                          provider: provider,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryBlue,
                      backgroundImage:
                          (widget.post.author.profileImage != null &&
                                  widget.post.author.profileImage!.isNotEmpty)
                              ? NetworkImage(widget.post.author.profileImage!)
                              : null,
                      child: (widget.post.author.profileImage == null ||
                              widget.post.author.profileImage!.isEmpty)
                          ? Text(
                              widget.post.author.firstName.isNotEmpty
                                  ? widget.post.author.firstName[0]
                                      .toUpperCase()
                                  : 'TP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                _buildSideAction(
                  icon: _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  count: _formatCount(_likeCount),
                  color: _isLiked ? Colors.red : Colors.white,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),
                _buildSideAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: _formatCount(_commentCount),
                  color: Colors.white,
                  onTap: () {
                    _showCommentsModal(context);
                  },
                ),
              ],
            ),
          ),

          // Dégradé bas et Info (Simplified)
          Positioned(
            left: 0,
            right: 80, // Leave space for side bar
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${widget.post.author.firstName}${widget.post.author.lastName}'
                        .toLowerCase()
                        .replaceAll(' ', ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  SizedBox(height: size.height * 0.05), // Bottom safe margin
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return _CommentsSheet(
                postId: widget.post.id,
                controller: controller,
                postService: _postService);
          },
        );
      },
    ).then((_) {
      // Refresh post data when modal closes to sync counts strictly
      // But we also listen to streams so it should be fine.
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildSideAction({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final String postId;
  final ScrollController controller;
  final PostService postService;

  const _CommentsSheet(
      {required this.postId,
      required this.controller,
      required this.postService});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  List<Comment> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  StreamSubscription? _commentLikeSubscription;
  StreamSubscription? _commentSubscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _subscribeToComments();
    _subscribeToCommentLikes();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.id;
      });
    }
  }

  void _fetchComments() async {
    try {
      final comments = await widget.postService.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _subscribeToComments() {
    WebSocketService().subscribeToPostComments(widget.postId);
    _commentSubscription = WebSocketService().postCommentsStream.listen((data) {
      if (data['postId'] == widget.postId && mounted) {
        final newComment = data['comment'] as Comment;
        setState(() {
          if (!_comments.any((c) => c.id == newComment.id)) {
            _comments.add(newComment);
          }
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (widget.controller.hasClients) {
            widget.controller.animateTo(
              widget.controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _subscribeToCommentLikes() {
    WebSocketService().subscribeToPostCommentLikes(widget.postId);
    _commentLikeSubscription =
        WebSocketService().postCommentLikesStream.listen((data) {
      if (data['postId'] == widget.postId && mounted) {
        final commentId = data['commentId'];
        final likeCount = data['likeCount'];
        // Find comment and update
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          setState(() {
            _comments[index].likeCount = likeCount;
            if (_currentUserId != null && data['userId'] == _currentUserId) {
              _comments[index].isLiked = data['isLiked'];
            }
          });
        }
      }
    });
  }

  Future<void> _toggleCommentLike(Comment comment) async {
    // Optimistic update
    final wasLiked = comment.isLiked;
    setState(() {
      comment.isLiked = !wasLiked;
      comment.likeCount += wasLiked ? -1 : 1;
    });

    try {
      // Assume API exists in PostService via generic path or specific
      await widget.postService.toggleLikeComment(comment.id);
    } catch (e) {
      // Revert
      if (mounted) {
        setState(() {
          comment.isLiked = wasLiked;
          comment.likeCount += wasLiked ? 1 : -1;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentSubscription?.cancel();
    _commentLikeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await widget.postService.addComment(widget.postId, content);
      _commentController.clear();
      _fetchComments(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'envoyer le commentaire')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const Text(
            'Commentaires',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text("Aucun commentaire pour le moment."))
                    : ListView.builder(
                        controller: widget.controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage:
                                      comment.author.profileImage != null
                                          ? NetworkImage(
                                              comment.author.profileImage!)
                                          : null,
                                  child: comment.author.profileImage == null
                                      ? const Icon(Icons.person,
                                          color: Colors.grey, size: 20)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.author.fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.content,
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Il y a quelques instants',
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        comment.isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 16,
                                        color: comment.isLiked
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleCommentLike(comment),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    if (comment.likeCount > 0)
                                      Text(
                                        comment.likeCount.toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Input area
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter un commentaire...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                    onPressed: _sendComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
