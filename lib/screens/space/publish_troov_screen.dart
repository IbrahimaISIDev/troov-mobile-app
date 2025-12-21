import 'package:flutter/material.dart';

class PublishTroovScreen extends StatefulWidget {
  const PublishTroovScreen({Key? key}) : super(key: key);

  @override
  State<PublishTroovScreen> createState() => _PublishTroovScreenState();
}

class _PublishTroovScreenState extends State<PublishTroovScreen> {
  // Mock Data for Staggered Grid
  final List<String> _leftColumnImages = [
    'https://picsum.photos/400/600?1', // Tall
    'https://picsum.photos/400/400?2', // Square
    'https://picsum.photos/400/500?3',
    'https://picsum.photos/400/450?4',
  ];

  final List<String> _rightColumnImages = [
    'https://picsum.photos/400/400?5', // Square
    'https://picsum.photos/400/650?6', // Very Tall
    'https://picsum.photos/400/500?7',
    'https://picsum.photos/400/400?8',
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Stats (Simplified)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('12', 'Posts'),
                _buildStat('1.5k', 'Vues'),
                _buildStat('340', 'Likes'),
              ],
            ),
            const SizedBox(height: 20),

            // Staggered Grid Manual Implementation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: _leftColumnImages
                        .map((url) => _buildGridItem(url))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                // Right Column
                Expanded(
                  child: Column(
                    children: _rightColumnImages
                        .map((url) => _buildGridItem(url))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Fab space
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostModal(context),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Publier'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  // UPDATED: Grid Item now has GestureDetector
  Widget _buildGridItem(String imageUrl) {
    return GestureDetector(
      onTap: () => _openImageDetail(context, imageUrl),
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
                  children: const [
                    Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('102',
                        style: TextStyle(
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

  // NEW: Image Detail View with Stats
  void _openImageDetail(BuildContext context, String imageUrl) {
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
                    tag: imageUrl, // Ideally unique tag per image
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
                      _buildDetailStat(Icons.favorite, '340', Colors.redAccent),
                      const SizedBox(width: 40),
                      _buildDetailStat(Icons.chat_bubble, '12', Colors.white),
                      const SizedBox(width: 40),
                      _buildDetailStat(
                          Icons.remove_red_eye, '1.5k', Colors.white),
                    ],
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

  void _showCreatePostModal(BuildContext context) {
    showModalBottomSheet(
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Publier',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    onTap: () {},
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Ajouter une photo ou vidéo',
                              style: TextStyle(color: Colors.grey)),
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
