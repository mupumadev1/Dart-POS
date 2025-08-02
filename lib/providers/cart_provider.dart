import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final double _taxRate = 0.16; // 16% tax rate
  double _discountAmount = 0.0;
  String _paymentMethod = 'cash';
  double _amountPaid = 0.0;
  String _notes= "";
  final ApiService _apiService = ApiService();

  // Getters
  List<CartItem> get items => _items;

  double get taxRate => _taxRate;

  double get discountAmount => _discountAmount;

  String get paymentMethod => _paymentMethod;

  double get amountPaid => _amountPaid;
  String get notes => _notes;
  // Calculate subtotal (sum of all item prices)
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Calculate tax amount (tax applied after discount)
  double get taxAmount {
    final taxableAmount = subtotal - _discountAmount;
    return taxableAmount > 0 ? taxableAmount * _taxRate : 0.0;
  }

  // Calculate total amount (subtotal - discount + tax)
  double get totalAmount {
    return subtotal - _discountAmount + taxAmount;
  }

  // Calculate change amount
  double get changeAmount {
    final change = _amountPaid - totalAmount;
    return change > 0 ? change : 0.0;
  }

  // Get total number of items in cart
  int get itemCount => _items.length;

  // Get total quantity of all items
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(Product product) {
    if (product.stockQuantity <= 0) return;

    final existingIndex = _items.indexWhere(
          (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Check if we can add more of this item
      if (_items[existingIndex].quantity < product.stockQuantity) {
        _items[existingIndex].quantity++;
      }
    } else {
      // Add new item to cart
      _items.add(CartItem(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void incrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void setDiscountAmount(double amount) {
    _discountAmount = amount.clamp(0.0, subtotal);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setAmountPaid(double amount) {
    _amountPaid = amount;
    notifyListeners();
  }

  void setNotes(String value) {
    _notes= value;
    notifyListeners();
  }

  // Check if payment amount is sufficient
  bool get isPaymentSufficient => _amountPaid >= totalAmount;

  // Get formatted currency strings
  String get formattedSubtotal => subtotal.toStringAsFixed(2);

  String get formattedDiscountAmount => _discountAmount.toStringAsFixed(2);

  String get formattedTaxAmount => taxAmount.toStringAsFixed(2);

  String get formattedTotalAmount => totalAmount.toStringAsFixed(2);

  String get formattedAmountPaid => _amountPaid.toStringAsFixed(2);

  String get formattedChangeAmount => changeAmount.toStringAsFixed(2);

  Future<bool> processSale(int userId) async {
    if (_items.isEmpty) return false;
    if (!isPaymentSufficient) return false;

    final receiptNumber = 'R${DateTime
        .now()
        .millisecondsSinceEpoch}';

    final sale = Sale(
        receiptNumber: receiptNumber,
        userId: userId,
        subtotal: subtotal,
        discountAmount: _discountAmount,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentMethod: _paymentMethod,
        amountPaid: _amountPaid,
        changeAmount: changeAmount,
        items: _items,
        notes
        :_notes
    );

    try {
      final result = await _apiService.processSale(sale);
      if (result != null) {
       // clearCart();
        return true;
      }
      return false;
    } catch (e) {
      print('Error processing sale: $e');
      return false;
    }
  }

  void clearCart() {
    _items.clear();
    _discountAmount = 0.0;
    _amountPaid = 0.0;
    _paymentMethod = 'cash';
    notifyListeners();
  }

  // Validation methods
  bool get hasItems => _items.isNotEmpty;

  bool validateSale() {
    return hasItems && isPaymentSufficient;
  }


}