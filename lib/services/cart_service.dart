import '../models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  void addProduct(Product product,
      {int quantity = 1, bool includeInstallation = false}) {
    _items.add({
      'product': product,
      'quantity': quantity,
      'includeInstallation': includeInstallation,
    });
    print(
        'Added to cart: ${product.title} x$quantity (Installation: $includeInstallation)');
  }

  List<Map<String, dynamic>> get items => _items;
}
