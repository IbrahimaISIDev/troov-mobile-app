import 'provider_model.dart';

class Author {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Post {
  final String id;
  final String description;
  final String? mediaUrl;
  final String? category;
  final DateTime createdAt;
  int likeCount;
  int commentCount;
  int viewCount;
  bool isLiked;
  final Author author;
  final ProviderProfile? provider;

  Post({
    required this.id,
    required this.description,
    this.mediaUrl,
    this.category,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.viewCount = 0,
    required this.isLiked,
    required this.author,
    this.provider,
  });

  String getThumbnailUrl() {
    if (mediaUrl == null || mediaUrl!.isEmpty) return '';
    final url = mediaUrl!.toLowerCase();
    if (url.contains('.mp4') || url.contains('.mov') || url.contains('.m4v')) {
      String thumbUrl = mediaUrl!;
      if (url.contains('.mp4')) thumbUrl = mediaUrl!.replaceAll('.mp4', '.jpg');
      else if (url.contains('.mov')) thumbUrl = mediaUrl!.replaceAll('.mov', '.jpg');
      else if (url.contains('.m4v')) thumbUrl = mediaUrl!.replaceAll('.m4v', '.jpg');
      
      if (thumbUrl.contains('/video/upload/')) {
        thumbUrl = thumbUrl.replaceFirst('/video/upload/', '/video/upload/so_0/');
      }
      return thumbUrl;
    }
    return mediaUrl!;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      mediaUrl: json['mediaUrl'],
      category: json['category'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isLiked: json['liked'] ?? json['isLiked'] ?? false,
      author: Author.fromJson(json['author'] ?? {}),
      provider: json['providerDto'] != null || json['provider'] != null
          ? ProviderProfile.fromJson(json['providerDto'] ?? json['provider'])
          : null,
    );
  }
}

class Comment {
  final String id;
  final String content;
  final DateTime createdAt;
  int likeCount;
  bool isLiked;
  final Author author;
  final ProviderProfile? provider;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
    required this.author,
    this.provider,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['liked'] ?? false,
      author: Author.fromJson(json['author'] ?? {}),
      provider: json['providerDto'] != null || json['provider'] != null
          ? ProviderProfile.fromJson(json['providerDto'] ?? json['provider'])
          : null,
    );
  }
}
