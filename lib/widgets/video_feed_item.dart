import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/global_video_cache.dart';
import 'comments_modal.dart';
import 'package:share_plus/share_plus.dart';

import '../services/post_service.dart';
import '../screens/services/service_provider_detail.dart';
import '../models/service_model.dart';

class VideoFeedItem extends StatefulWidget {
  final Product product;
  final bool isFocused;

  const VideoFeedItem({
    super.key,
    required this.product,
    required this.isFocused,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> {
  // Product state
  bool _isDescriptionExpanded = false; // Expand description

  // Social state
  late int _likeCount;
  late int _viewCount;
  late int _commentCount;
  late bool _isLiked;

  // Video controller
  VideoPlayerController? _controller;
  bool _isMuted = false; // Audio active by default
  bool _showControls = false; // Show pause/play overlay
  bool _showHeart = false; // Show heart animation
  Timer? _tapTimer; // Timer for single/double tap distinction

  bool get _isVideo =>
      widget.product.videoUrl.toLowerCase().contains('.mp4') ||
      widget.product.videoUrl.toLowerCase().contains('.mov') ||
      widget.product.videoUrl.toLowerCase().contains('.m4v');

  @override
  void initState() {
    super.initState();
    _likeCount = widget.product.likeCount;
    _viewCount = widget.product.viewCount;
    _commentCount = widget.product.commentCount;
    _isLiked = widget.product.isLiked;

    if (_isVideo) {
      _loadVideo();
    }

    if (widget.isFocused) {
      _incrementView();
    }
  }

  void _incrementView() {
    PostService().viewPost(widget.product.id);
    setState(() {
      _viewCount++;
    });
  }

  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFocused && !oldWidget.isFocused) {
      _incrementView();
      if (_isVideo) {
        GlobalVideoCache.play(widget.product.videoUrl, ownerId: toString());
      }
    } else if (!widget.isFocused && oldWidget.isFocused) {
      if (_isVideo) {
        GlobalVideoCache.pause(widget.product.videoUrl, ownerId: toString());
      }
    }
  }

  Future<void> _loadVideo() async {
    try {
      final controller = await GlobalVideoCache.getController(
        widget.product.videoUrl,
      );
      if (mounted) {
        setState(() {
          _controller = controller;
        });

        // Play video if focused AFTER loading
        if (widget.isFocused) {
          _controller!.setVolume(_isMuted ? 0.0 : 1.0);
          GlobalVideoCache.play(widget.product.videoUrl, ownerId: toString());
        }
      }
    } catch (e) {
      print('Error loading video: $e');
    }
  }

  void _toggleMute() {
    if (_controller != null) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {});
    }
  }

  void _handleTap() {
    if (_tapTimer != null && _tapTimer!.isActive) {
      // Double tap detected
      _tapTimer!.cancel();
      _handleDoubleTap();
    } else {
      // Start timer for single tap
      _tapTimer = Timer(const Duration(milliseconds: 300), () {
        // Single tap action confirmed
        if (_isVideo) {
          _togglePlayPause();
          setState(() {
            _showControls = true;
          });
          // Hide controls after 1 second
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      });
    }
  }

  final PostService _postService = PostService();

  void _handleDoubleTap() {
    if (!_isLiked) {
      _postService.toggleLike(widget.product.id);
      setState(() {
        _isLiked = true;
        _likeCount++;
        _showHeart = true;
      });
    } else {
      _postService.toggleLike(widget.product.id);
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    }

    // Hide heart animation after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsModal(
        productId: widget.product.id,
        productTitle: widget.product.title,
      ),
    );
  }

  void _handleShare() {
    _postService.sharePost(widget.product.id);
    Share.share(
      'Découvrez ${widget.product.title} sur Troov !\n\n${widget.product.description}',
      subject: widget.product.title,
    );
  }

  void _navigateToProfile() {
    if (widget.product.provider == null) {
      // Mock fallback if absolutely needed, but better to show a snackbar or do nothing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil non disponible')),
      );
      return;
    }

    // Convert ProviderProfile to ServiceProvider (as expected by ServiceProviderDetail)
    // NOTE: This conversion assumes ServiceProvider is the model used in ServiceProviderDetail
    final provider = ServiceProvider(
      id: widget.product.provider!.id ?? 'p_${widget.product.id}',
      name: widget.product.provider!.agencyName ??
          widget.product.provider!.user?.fullName ??
          'Utilisateur Troov',
      rating: widget.product.provider!.rating,
      distance: widget.product.provider!.distance,
      reviewCount: widget.product.provider!.reviewCount,
      profileImage: widget.product.provider!.logoUrl ??
          widget.product.provider!.user?.profileImage ??
          '',
      specialties: widget.product.provider!.specialties,
      description: widget.product.provider!.bio ??
          'Spécialiste en ${widget.product.category}.',
      phone: widget.product.provider!.user?.phone ?? '',
      address: widget.product.provider!.address ?? 'Sénégal',
      isVerified: widget.product.provider!.isVerified,
      responseTime: widget.product.provider!.responseTime ?? '30 min',
      completedJobs: widget.product.provider!.totalMissions,
      hourlyRate: 0,
      availability: true,
      portfolio: const [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceProviderDetail(
          provider: provider,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pause current video
    // Pause with reference counting (safe now)
    if (_isVideo) {
      GlobalVideoCache.pause(widget.product.videoUrl, ownerId: toString());
    }
    // Don't dispose controllers - they're managed by GlobalVideoCache
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video/Image Display with tap controls
          GestureDetector(
            onTap: _handleTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Media Background
                if (_isVideo)
                  if (_controller != null && _controller!.value.isInitialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.product.getThumbnailUrl(),
                          fit: BoxFit.cover,
                        ),
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ],
                    )
                else
                  // It's an image
                  CachedNetworkImage(
                    imageUrl: widget.product.videoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image,
                          color: Colors.white, size: 50),
                    ),
                  ),

                // Play/Pause icon overlay (center)
                if (_showControls && _controller != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),

                // Heart animation for double-tap like
                if (_showHeart)
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.5),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: 1.5 - value,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 100,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Gradient overlay for readability
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Mute/Unmute button (only if it's a video)
                    if (_isVideo)
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),

          // Product Info Overlay (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white10,
                              backgroundImage: (widget.product.provider?.logoUrl != null || widget.product.provider?.user?.profileImage != null)
                                ? CachedNetworkImageProvider(widget.product.provider?.logoUrl ?? widget.product.provider?.user?.profileImage ?? '')
                                : null,
                              child: (widget.product.provider?.logoUrl == null && widget.product.provider?.user?.profileImage == null)
                                ? const Icon(Icons.person, color: Colors.white54, size: 20)
                                : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.provider?.agencyName ??
                                  widget.product.provider?.user?.fullName ??
                                  'Utilisateur Troov',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.product.category.isNotEmpty)
                                  Text(
                                    widget.product.category,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description (expandable with scroll)
                      if (widget.product.description.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isDescriptionExpanded
                                    ? Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 150,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            widget.product.description,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        widget.product.description,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Social Buttons (Right side - TikTok style)
          Positioned(
            right: 8,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSocialButton(
                  icon: Icons.remove_red_eye,
                  label: _viewCount > 999
                      ? '${(_viewCount / 1000).toStringAsFixed(1)}k'
                      : '$_viewCount',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '$_likeCount',
                  color: _isLiked ? Colors.red : null,
                  onTap: _handleDoubleTap,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: Icons.comment_outlined,
                  label: '$_commentCount',
                  onTap: _showComments,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: Icons.share_outlined,
                  label: 'Partager',
                  onTap: _handleShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
