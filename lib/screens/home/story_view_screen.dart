import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/story_model.dart';
import '../../services/story_service.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  StoryViewScreen({required this.stories, required this.initialIndex});

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  final StoryService _storyService = StoryService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController = AnimationController(vsync: this);

    _loadStory(widget.stories[_currentIndex]);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onStoryComplete();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _loadStory(Story story) {
    _animController.stop();
    _animController.reset();

    // Mark as viewed in backend
    _storyService.viewStory(story.id);

    if (story.type == StoryType.video) {
      // In a real app, initialize video player
      // For now, we mock wait
      _animController.duration = Duration(seconds: 10);
      _animController.forward();
    } else {
      _animController.duration = Duration(seconds: 5);
      _animController.forward();
    }
  }

  void _onStoryComplete() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context); // Close if last story
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _pageController.previousPage(
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          } else {
            _onStoryComplete();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              physics:
                  NeverScrollableScrollPhysics(), // Disable swipe to control via tap
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _loadStory(widget.stories[index]);
              },
              itemBuilder: (context, index) {
                return _buildStoryContent(widget.stories[index]);
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: List.generate(
                      widget.stories.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.0),
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              double value = 0.0;
                              if (index < _currentIndex) {
                                value = 1.0;
                              } else if (index == _currentIndex) {
                                value = _animController.value;
                              }
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey[600],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: _getImageProvider(
                            widget.stories[_currentIndex].authorImage),
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.stories[_currentIndex].authorName,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    if (url.isEmpty) {
      return AssetImage('assets/images/ouz.png');
    }
    return AssetImage(url);
  }

  Widget _buildStoryContent(Story story) {
    if (story.type == StoryType.image) {
      if (story.mediaUrl.startsWith('http')) {
        return Image.network(story.mediaUrl, fit: BoxFit.cover);
      }
      return Image.asset(story.mediaUrl, fit: BoxFit.cover);
    } else if (story.type == StoryType.text) {
      Color bgColor = Colors.blue;
      // Parse mock color from story
      // In backend we store hex or color name.
      if (story.mediaUrl.startsWith('#')) {
        // parse hex
        // naive parsing
        try {
          // Remove #
          String hex = story.mediaUrl.substring(1);
          bgColor = Color(int.parse("0xFF$hex"));
        } catch (e) {}
      } else if (story.mediaUrl.startsWith('0x')) {
        try {
          bgColor = Color(int.parse(story.mediaUrl));
        } catch (e) {}
      }

      return Container(
        color: bgColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              story.textContent ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    } else if (story.type == StoryType.video) {
      return Center(
          child: Text("Video Player Placeholder",
              style: TextStyle(color: Colors.white)));
    }
    return SizedBox();
  }
}
