import '../models/product.dart';

class MockDatabase {
  static final List<Product> products = [
    Product(
      id: '1',
      title: 'iPhone 15 Pro Max',
      description:
          'Titanium design, A17 Pro chip, 48MP Main camera. The most powerful iPhone ever.',
      price: '850.000 FCFA',
      numericPrice: 850000,
      originalPrice: '900.000 FCFA',
      category: 'Téléphonie',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      deliveryFee: 0,
      promoLabel: '-5%',
      hasInstallationOption: false,
    ),
    Product(
      id: '2',
      title: 'Smart TV Samsung 55"',
      description:
          'Crystal UHD 4K, Smart TV Tizen, HDR10+. Experience crystal clear colors.',
      price: '350.000 FCFA',
      numericPrice: 350000,
      category: 'Électronique',
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      deliveryFee: 5000,
      hasInstallationOption: true,
      installationFee: 15000,
    ),
    Product(
      id: '3',
      title: 'AirPods Pro 2',
      description:
          'Active Noise Cancellation, Transparency mode, Spatial Audio.',
      price: '150.000 FCFA',
      numericPrice: 150000,
      category: 'Audio',
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
      deliveryFee: 2000,
      promoLabel: 'Promo',
      hasInstallationOption: false,
    ),
  ];
}
