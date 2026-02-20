import 'package:flutter/material.dart';
import '../../services/story_service.dart';

class CreateMediaStatusScreen extends StatefulWidget {
  final String mediaPath; // Path from picker (or mock)
  final bool isVideo;

  const CreateMediaStatusScreen({
    Key? key,
    required this.mediaPath,
    this.isVideo = false, // TODO: Handle video player if true
  }) : super(key: key);

  @override
  _CreateMediaStatusScreenState createState() =>
      _CreateMediaStatusScreenState();
}

class _CreateMediaStatusScreenState extends State<CreateMediaStatusScreen> {
  final TextEditingController _captionController = TextEditingController();
  final StoryService _storyService = StoryService();
  bool _isPosting = false;

  Future<void> _postStatus() async {
    setState(() => _isPosting = true);

    try {
      // Create status atomically with media + caption
      await _storyService.postStatus(
        widget.isVideo ? "VIDEO" : "IMAGE",
        widget.mediaPath,
        caption: _captionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de la publication")));
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.crop, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.title, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Media Preview
          Center(
            child: widget.mediaPath.startsWith('http')
                ? Image.network(widget.mediaPath, fit: BoxFit.contain)
                : Image.asset(widget.mediaPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) =>
                        Icon(Icons.broken_image, color: Colors.grey, size: 50)),
          ),

          // Caption Input & Send
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _captionController,
                        style: TextStyle(color: Colors.white),
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Ajouter une légende...",
                          hintStyle: TextStyle(color: Colors.white70),
                          icon: Icon(Icons.add_photo_alternate,
                              color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Color(0xFF00A884),
                    child: _isPosting
                        ? Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isPosting ? null : _postStatus,
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
