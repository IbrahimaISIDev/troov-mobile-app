class FeedItem {
  final String id;
  final String description;
  final String? mediaUrl;
  final String category;
  final FeedAuthor author;
  final FeedStats stats;
  final bool isLiked;
  final DateTime createdAt;

  FeedItem({
    required this.id,
    required this.description,
    this.mediaUrl,
    required this.category,
    required this.author,
    required this.stats,
    required this.isLiked,
    required this.createdAt,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'],
      description: json['description'] ?? '',
      mediaUrl: json['mediaUrl'],
      category: json['category'] ?? 'Général',
      author: FeedAuthor.fromJson(json['author']),
      stats: FeedStats(
        likes: json['likeCount'] ?? 0,
        comments: json['commentCount'] ?? 0,
        views: json['viewCount'] ?? 0,
      ),
      isLiked: json['liked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper to determine if the first media is a video
  bool get isVideo {
    if (mediaUrl == null || mediaUrl!.isEmpty) return false;
    final url = mediaUrl!.toLowerCase();
    return url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi') ||
        url.endsWith('.wmv');
  }
}

class FeedAuthor {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  FeedAuthor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName';

  factory FeedAuthor.fromJson(Map<String, dynamic> json) {
    return FeedAuthor(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}

class FeedStats {
  final int likes;
  final int comments;
  final int views;

  FeedStats({
    required this.likes,
    required this.comments,
    required this.views,
  });
}
