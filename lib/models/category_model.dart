class Category {
  final int? id;
  final String title;
  final String? description;
  final String? color;
  final double commissionPercentage;
  final int totalProducts;
  final String? status;

  Category({
    this.id,
    required this.title,
    this.description,
    this.color,
    this.commissionPercentage = 0.0,
    this.totalProducts = 0,
    this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      color: json['color'],
      commissionPercentage: (json['commissionPercentage'] ?? 0.0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'commissionPercentage': commissionPercentage,
      'totalProducts': totalProducts,
      'status': status,
    };
  }
}
