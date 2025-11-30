// fitur/kasir/models.dart

/// Model untuk Item di dalam Keranjang Belanja.
class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}