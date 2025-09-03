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

  // New fields from Sequelize model
  final String? invNumber;
  final String? receiptNo;
  final String? sdcId;
  final String? receiptSig;
  final String? intrlData;
  final String? qrCodeUrl;
  final String? vsdcrcpDate;
  final String? invoiceNo;
  final String? qrFilePath;

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
    // New fields
    this.invNumber,
    this.receiptNo,
    this.sdcId,
    this.receiptSig,
    this.intrlData,
    this.qrCodeUrl,
    this.vsdcrcpDate,
    this.invoiceNo,
    this.qrFilePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      // New fields
      'invnumber': invNumber,
      'receipt_no': receiptNo,
      'sdcid': sdcId,
      'receiptsig': receiptSig,
      'intrldata': intrlData,
      'qrcode_url': qrCodeUrl,
      'vsdcrcpdate': vsdcrcpDate,
      'invoice_no': invoiceNo,
      'qrfilepath': qrFilePath,
    };
  }
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      receiptNumber: json['receipt_number'],
      userId: json['user_id'],
      customerId: json['customer_id'],
      subtotal: (json['subtotal'] as num).toDouble(),
      discountId: json['discount_id'],
      discountAmount: (json['discount_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'],
      amountPaid: (json['amount_paid'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      notes: json['notes'],
      invNumber: json['invnumber'],
      receiptNo: json['receipt_no'],
      sdcId: json['sdcid'],
      receiptSig: json['receiptsig'],
      intrlData: json['intrldata'],
      qrCodeUrl: json['qrcode_url'],
      vsdcrcpDate: json['vsdcrcpdate'],
      invoiceNo: json['invoice_no'],
      qrFilePath: json['qrfilepath'],
    );
  }

}
