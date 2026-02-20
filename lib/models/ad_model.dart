enum AdType { feed_post, story, banner, interstitial }

class Ad {
  final String id;
  final String partnerName;
  final String partnerLogo;
  final String title;
  final String description;
  final String mediaUrl;
  final String ctaText; // "Learn More", "Shop Now"
  final String ctaLink;
  final AdType type;
  final bool isInternal; // True for Troov internal ads

  Ad({
    required this.id,
    required this.partnerName,
    required this.partnerLogo,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.ctaText,
    required this.ctaLink,
    required this.type,
    this.isInternal = false,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      partnerName: json['partnerName'],
      partnerLogo: json['partnerLogo'],
      title: json['title'],
      description: json['description'],
      mediaUrl: json['mediaUrl'],
      ctaText: json['ctaText'],
      ctaLink: json['ctaLink'],
      type: AdType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => AdType.feed_post),
      isInternal: json['isInternal'] ?? false,
    );
  }
}
