class Product {
  final String id;
  final String title;
  final String description;
  final String price;
  final double numericPrice;
  final String? originalPrice;
  final String category;
  final String videoUrl;
  final double deliveryFee;
  final String? promoLabel;
  final bool hasInstallationOption;
  final double installationFee;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.numericPrice,
    this.originalPrice,
    required this.category,
    required this.videoUrl,
    required this.deliveryFee,
    this.promoLabel,
    this.hasInstallationOption = false,
    this.installationFee = 0.0,
  });
}
