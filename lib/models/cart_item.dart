class CartItem {
  final int productId;
  final String productName;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(productId: json['productId'], productName: json['productName'], unitPrice: json['unitPrice'], quantity: json['quantity']);
  }
}