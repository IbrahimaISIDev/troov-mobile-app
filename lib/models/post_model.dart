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
  final List<String> mediaUrls;
  final String? category;
  final DateTime createdAt;
  int likeCount;
  int commentCount;
  int viewCount;
  bool isLiked;
  final Author author;

  Post({
    required this.id,
    required this.description,
    required this.mediaUrls,
    this.category,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    this.viewCount = 0,
    required this.isLiked,
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      category: json['category'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isLiked: json['liked'] ?? json['isLiked'] ?? false,
      author: Author.fromJson(json['author'] ?? {}),
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

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['liked'] ?? false,
      author: Author.fromJson(json['author'] ?? {}),
    );
  }
}
