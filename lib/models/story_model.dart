enum StoryType { image, video, text, audio }

class Story {
  final String id;
  final String authorId;
  final String authorName; // Normalized for UI
  final String authorImage;
  final String mediaUrl; // Can be a color code for text stories
  final String? textContent; // For text stories or captions
  final StoryType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int views;
  final List<String> viewers; // User IDs
  final List<StoryInteraction> interactions;
  final bool isSponsored;
  final bool isRead;

  Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImage,
    required this.mediaUrl,
    this.textContent,
    required this.type,
    required this.createdAt,
    DateTime? expiresAt,
    this.views = 0,
    this.viewers = const [],
    this.interactions = const [],
    this.isSponsored = false,
    this.isRead = false,
  }) : expiresAt = expiresAt ?? createdAt.add(Duration(hours: 24));

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Story.fromJson(Map<String, dynamic> json) {
    // Check if it's the wrapper DTO or raw Status object (though DTO is flattened wrapper)
    // The backend DTO structure is:
    // { "status": {id, userId, ...}, "viewed": true, "authorName": "", "authorAvatar": "" }
    final status = json['status'];
    final isViewed = json['viewed'] ?? false;
    final authorName = json['authorName'] ?? 'Utilisateur';
    final authorAvatar = json['authorAvatar'];

    if (json['id'] != null && status == null) {
      // Handle case where we might be parsing just the Status object (if used directly somewhere)
      // But primarily we expect the DTO.
      // Existing mock might fail if we don't handle legacy structure or update service mocks.
      // Assuming we invoke this ONLY with new DTO response.
      // Fallback for flat structure?
      return Story(
        id: json['id'].toString(),
        authorId: json['userId'] ?? '',
        authorName: json['authorName'] ?? 'Utilisateur',
        authorImage: json['authorAvatar'] ?? '',
        mediaUrl: json['content'] ?? '',
        textContent: json['type'] == 'TEXT' ? json['content'] : json['caption'],
        type: _parseType(json['type']),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        expiresAt: DateTime.tryParse(json['expiresAt'] ?? ''),
        isRead: json['viewed'] ?? false,
      );
    }

    return Story(
      id: status['id'].toString(),
      authorId: status['userId'].toString(),
      authorName: authorName,
      authorImage: authorAvatar ?? '',
      mediaUrl: status['content'] ?? '',
      // For TEXT type, content is the text.
      // For IMAGE/VIDEO, content is URL, caption is textContent.
      textContent:
          status['type'] == 'TEXT' ? status['content'] : status['caption'],
      type: _parseType(status['type']),
      createdAt: DateTime.tryParse(status['createdAt']) ?? DateTime.now(),
      expiresAt: DateTime.tryParse(status['expiresAt']),
      isRead: isViewed,
    );
  }

  static StoryType _parseType(String? type) {
    if (type == 'VIDEO') return StoryType.video;
    if (type == 'TEXT') return StoryType.text;
    return StoryType.image;
  }
}

class StoryInteraction {
  final String userId;
  final String type; // 'reaction', 'poll_vote', 'reply'
  final String? value; // emoji, option_index, message text

  StoryInteraction({
    required this.userId,
    required this.type,
    this.value,
  });
}
