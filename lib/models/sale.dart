import 'cart_item.dart';

class Sale {
  final int? id;
  final String receiptNumber;
  final int userId;
  final int? customerId;
  final double subtotal;
  final int? discountId;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final double amountPaid;
  final double changeAmount;
  final List<CartItem> items;
  final String? notes;

  Sale({
    this.id,
    required this.receiptNumber,
    required this.userId,
    this.customerId,
    required this.subtotal,
    this.discountId,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'receipt_number': receiptNumber,
      'user_id': userId,
      'customer_id': customerId,
      'subtotal': subtotal,
      'discount_id': discountId,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }
}