class ShoppingItem {
  final String id;
  final DateTime createdAt;
  double price, discount, taxRate;
  int quantity;

  ShoppingItem({required this.id, required this.createdAt, required this.price, required this.discount, this.quantity = 1, this.taxRate = 0.0});

  double get finalPrice => (price * (1 - discount / 100) * (1 + taxRate)) * quantity;

  Map<String, dynamic> toJson() => {'id': id, 'time': createdAt.toIso8601String(), 'p': price, 'd': discount, 'q': quantity, 't': taxRate};
  factory ShoppingItem.fromJson(Map<String, dynamic> j) => ShoppingItem(
    id: j['id'] ?? DateTime.now().toString(),
    createdAt: j['time'] != null ? DateTime.parse(j['time']) : DateTime.now(),
    price: (j['p'] ?? 0).toDouble(), discount: (j['d'] ?? 0).toDouble(), quantity: j['q'] ?? 1, taxRate: (j['t'] ?? 0.0).toDouble(),
  );
}