import 'package:intl/intl.dart'; // Diperlukan untuk DateFormat

class OrderItem {
  final String name;
  final int quantity;
  final int pricePerItem;

  OrderItem({required this.name, required this.quantity, required this.pricePerItem});

  int get subtotal => quantity * pricePerItem;

  // Factory constructor untuk konversi dari JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['product_name'] as String? ?? 'Unknown Item', 
      quantity: (json['quantity'] as int?) ?? 0,
      pricePerItem: (json['price_per_item'] as int?) ?? 0,
    );
  }
}


class CustomerHistory {
  final String id;
  final String name;
  final String transactionTime;
  final List<OrderItem> items;
  final int discount;

  CustomerHistory({
    required this.id,
    required this.name,
    required this.transactionTime,
    required this.items,
    this.discount = 4000,
  });

  int get subtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get total => subtotal - discount;

  // ✅ METODE fromJson BERADA DI SINI
  factory CustomerHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['order_items'] ?? []; 
    final List<OrderItem> items = itemsJson
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    String formattedTime = 'N/A';
    if (json['created_at'] != null) {
      final dateTime = DateTime.parse(json['created_at'].toString()).toLocal();
      formattedTime = DateFormat('HH:mm').format(dateTime); 
    }

    return CustomerHistory(
      id: json['id'].toString(),
      name: json['customer_name'] as String? ?? 'N/A', 
      transactionTime: formattedTime,
      items: items,
      discount: (json['discount'] as int?) ?? 4000,
    );
  }
}