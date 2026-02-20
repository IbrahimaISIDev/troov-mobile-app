import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import '../models/product.dart';
import '../services/global_video_cache.dart';
import '../services/cart_service.dart';
import 'comments_modal.dart';
import 'package:share_plus/share_plus.dart';

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
  int _quantity = 1;
  bool _includeInstallation = false;
  bool _isDescriptionExpanded = false; // Expand description

  // Video controller
  VideoPlayerController? _controller;
  bool _isMuted = true; // Default muted like TikTok
  bool _showControls = false; // Show pause/play overlay
  bool _isLiked = false; // Like state
  bool _showHeart = false; // Show heart animation
  Timer? _tapTimer; // Timer for single/double tap distinction

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFocused && !oldWidget.isFocused) {
      GlobalVideoCache.play(widget.product.videoUrl, ownerId: toString());
    } else if (!widget.isFocused && oldWidget.isFocused) {
      GlobalVideoCache.pause(widget.product.videoUrl, ownerId: toString());
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
      });
    }
  }

  void _handleDoubleTap() {
    setState(() {
      _isLiked = !_isLiked;
      _showHeart = true;
    });

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
        productId: _currentProduct.id,
        productTitle: _currentProduct.title,
      ),
    );
  }

  void _handleShare() {
    Share.share(
      'Découvrez ${_currentProduct.title} à ${_currentProduct.price} !\n\nLivraison ${_currentProduct.deliveryFee == 0 ? "GRATUITE" : "disponible"}',
      subject: _currentProduct.title,
    );
  }

  Product get _currentProduct => widget.product;

  void _handleAddToCart() {
    CartService().addProduct(
      _currentProduct,
      quantity: _quantity,
      includeInstallation: _includeInstallation,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_currentProduct.title} ajouté au panier (x$_quantity)',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset and hide options
    setState(() {
      _quantity = 1;
      _includeInstallation = false;
    });
  }

  void _navigateToProfile() {
    // Navigate to ServiceProviderDetail
    // We create a mock provider since Product doesn't have one yet,
    // assuming the product seller is the provider.
    final provider = ServiceProvider(
      id: 'provider_${_currentProduct.id}',
      name: 'Vendeur ${_currentProduct.title}',
      rating: 4.8,
      distance: 2.5,
      reviewCount: 120,
      profileImage: 'https://i.pravatar.cc/150?img=3', // Same as avatar
      specialties: [_currentProduct.category, 'Vente', 'Accessoires'],
      description:
          'Spécialiste en ${_currentProduct.category}. Nous proposons les meilleurs produits de la région avec un service client exceptionnel.',
      phone: '+221 77 000 00 00',
      address: 'Dakar, Sénégal',
      isVerified: true,
      responseTime: '30 min',
      completedJobs: 50,
      hourlyRate: 0,
      availability: true,
      portfolio: [
        'https://picsum.photos/400/400',
        'https://picsum.photos/401/400',
        'https://picsum.photos/402/400',
      ],
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
    GlobalVideoCache.pause(_currentProduct.videoUrl, ownerId: toString());
    // Don't dispose controllers - they're managed by GlobalVideoCache
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Display with tap controls
          GestureDetector(
            onTap: _handleTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video Background
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
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
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

          // Top Header - EXACTLY like ProductPopup (but without close button to avoid overflow)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Mute/Unmute button (TikTok style)
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

          // Product Info Overlay (Bottom) - EXACTLY like ProductPopup
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product info with fixed width (left-aligned)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.7, // 70% width
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _currentProduct.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              // Description (expandable with scroll)
                              if (_currentProduct.description.isNotEmpty) ...[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _isDescriptionExpanded
                                                  ? Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxHeight: 150,
                                                      ),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Text(
                                                          _currentProduct
                                                              .description,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[300],
                                                            fontSize: 14,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      _currentProduct
                                                          .description,
                                                      style: TextStyle(
                                                        color: Colors.grey[300],
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              _isDescriptionExpanded
                                                  ? Icons.remove_circle_outline
                                                  : Icons.add_circle_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons Row
                      Row(
                        children: [
                          // Commander Button
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleAddToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Commander',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Profile Avatar
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/images/user_placeholder.png'), // Need a placeholder or use Icon
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=3'), // Mock profile
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Social Buttons (Right side - TikTok style)
          Positioned(
            right: 8,
            bottom: 120, // Moved up slightly
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSocialButton(
                  icon: Icons.remove_red_eye,
                  label: '1.2k',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _isLiked ? '106' : '105',
                  color: _isLiked ? Colors.red : null,
                  onTap: _handleDoubleTap,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: Icons.comment_outlined,
                  label: '12',
                  onTap: _showComments,
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: Icons.share_outlined,
                  label: '34',
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
