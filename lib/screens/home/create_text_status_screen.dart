import 'package:flutter/material.dart';
import '../../services/story_service.dart';

class CreateTextStatusScreen extends StatefulWidget {
  const CreateTextStatusScreen({Key? key}) : super(key: key);

  @override
  _CreateTextStatusScreenState createState() => _CreateTextStatusScreenState();
}

class _CreateTextStatusScreenState extends State<CreateTextStatusScreen> {
  final TextEditingController _textController = TextEditingController();
  final StoryService _storyService = StoryService();

  // WhatsApp-like background colors
  final List<Color> _colors = [
    Color(0xFF8B008B), // Purple
    Color(0xFF5F9EA0), // Teal
    Color(0xFFFF7F50), // Coral
    Color(0xFF00008B), // DarkBlue
    Color(0xFFC71585), // MediumVioletRed
  ];
  int _colorIndex = 0;
  bool _isPosting = false;

  void _changeColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _colors.length;
    });
  }

  Future<void> _postStatus() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      // Create status ONLY on validation
      // Simulate Hex color string
      String colorHex =
          '#${_colors[_colorIndex].value.toRadixString(16).padLeft(8, '0').substring(2)}';

      await _storyService.postStatus(
        "TEXT",
        text,
        color: colorHex,
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
      // full screen color
      backgroundColor: _colors[_colorIndex],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.palette, color: Colors.white),
            onPressed: _changeColor,
          ),
          IconButton(
            icon: Icon(Icons.text_fields, color: Colors.white),
            onPressed: () {
              // TODO: Change font
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                controller: _textController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Écrire un statut...",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          if (_isPosting)
            Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00A884), // WhatsApp Greenish
        child: Icon(Icons.send, color: Colors.white),
        onPressed: _isPosting ? null : _postStatus,
      ),
    );
  }
}
