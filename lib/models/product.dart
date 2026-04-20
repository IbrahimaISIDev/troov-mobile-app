import 'provider_model.dart';
import 'category_model.dart';

class Product {
  final String id;
  final ProviderProfile? provider;
  final Category? categoryData;
  final String title;
  final String description;
  final String price;
  final double numericPrice;
  final String? originalPrice;
  final String category;
  final String videoUrl;
  final List<String> images;
  final double deliveryFee;
  final String? promoLabel;
  final bool hasInstallationOption;
  final double installationFee;

  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isLiked;
  final String? duration;

  final String? productCode;
  final String? status;

  const Product({
    required this.id,
    this.provider,
    this.categoryData,
    required this.title,
    required this.description,
    required this.price,
    required this.numericPrice,
    this.originalPrice,
    required this.category,
    required this.videoUrl,
    this.images = const [],
    required this.deliveryFee,
    this.promoLabel,
    this.hasInstallationOption = false,
    this.installationFee = 0.0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isLiked = false,
    this.productCode,
    this.status,
    this.duration,
  });

  String getThumbnailUrl() {
    if (videoUrl.isEmpty) return '';
    final url = videoUrl.toLowerCase();
    if (url.contains('.mp4') || url.contains('.mov') || url.contains('.m4v')) {
      // Cloudinary specific transformation: replace extension with .jpg and add thumbnail transformation if possible
      // Simple approach: replace Extension
      String thumbUrl = videoUrl;
      if (videoUrl.contains('.mp4')) thumbUrl = videoUrl.replaceAll('.mp4', '.jpg');
      else if (videoUrl.contains('.mov')) thumbUrl = videoUrl.replaceAll('.mov', '.jpg');
      else if (videoUrl.contains('.m4v')) thumbUrl = videoUrl.replaceAll('.m4v', '.jpg');
      
      // If it's a Cloudinary URL, we can also add 'so_0' (start offset 0) to get the first frame
      if (thumbUrl.contains('/video/upload/')) {
        thumbUrl = thumbUrl.replaceFirst('/video/upload/', '/video/upload/so_0/');
      }
      return thumbUrl;
    }
    return videoUrl;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Mapping from ServiceItemDto (images) or PostResponse (mediaUrl)
    final images = (json['images'] as List<dynamic>?) ??
        (json['mediaUrl'] != null ? [json['mediaUrl']] : null) ??
        [];
    final videoUrl = images.isNotEmpty ? images.first.toString() : '';

    final description = json['description'] ?? '';
    final title = json['title'] ??
        (description.isNotEmpty
            ? (description.length > 40
                ? "${description.substring(0, 37)}..."
                : description)
            : 'Sans titre');

    // Map provider or author
    ProviderProfile? provider;
    if (json['provider'] != null) {
      provider = ProviderProfile.fromJson(json['provider']);
    } else {
      // Reconstruct from author object or flat keys
      final authorData = json['author'];
      final String? authorId = authorData?['id']?.toString() ?? 
                              json['authorId']?.toString() ?? 
                              json['author_id']?.toString();
      
      if (authorId != null) {
        String? displayName;
        if (authorData != null) {
          final first = authorData['firstName'] ?? authorData['prenom'];
          final last = authorData['lastName'] ?? authorData['nom'];
          final pseudo = authorData['pseudo'];
          
          if (first != null || last != null) {
            displayName = '${first ?? ''} ${last ?? ''}'.trim();
          } else if (pseudo != null) {
            displayName = pseudo.toString();
          }
        }
        
        provider = ProviderProfile(
          id: authorId,
          agencyName: displayName ?? 'Utilisateur Troov',
          logoUrl: authorData?['profileImage'] ?? authorData?['photoUrl'],
        );
      }
    }

    final categoryRaw = json['categoryName'] ??
        (json['category'] is Map
            ? (json['category']['name'] ?? json['category']['title'])
            : json['category']?.toString());

    if (categoryRaw == null || categoryRaw.toString().isEmpty) {
      print(
          'DEBUG: Product ${json['id']} has no category information! Mapping to "Service"');
    }

    return Product(
      id: json['id']?.toString() ?? '',
      provider: provider,
      categoryData: json['categoryData'] != null
          ? Category.fromJson(json['categoryData'])
          : null,
      title: title,
      description: description,
      price: json['price'] != null ? '${json['price']} FCFA' : '',
      numericPrice: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: json['images'] != null ? List<String>.from(json['images']) : (json['mediaUrl'] != null ? [json['mediaUrl'].toString()] : []),
      category: categoryRaw?.toString() ?? 'Service',
      videoUrl: videoUrl,
      deliveryFee: 0.0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isLiked: json['liked'] ?? false,
      productCode: json['productCode'],
      status: json['status'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': numericPrice,
      'categoryName': category,
      'images': images,
      'duration': duration,
    };
  }
}
