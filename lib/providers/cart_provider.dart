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

  final ApiService _apiService = ApiService();

  List<CartItem> get items => _items;
  double get taxRate => _taxRate;
  double get discountAmount => _discountAmount;
  String get paymentMethod => _paymentMethod;
  double get amountPaid => _amountPaid;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get taxAmount => subtotal * _taxRate;

  double get totalAmount => subtotal + taxAmount - _discountAmount;

  double get changeAmount => _amountPaid - totalAmount;

  int get itemCount => _items.length;

  void addItem(Product product) {
    if (product.stockQuantity <= 0) return;

    final existingIndex = _items.indexWhere(
          (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity < product.stockQuantity) {
        _items[existingIndex].quantity++;
      }
    } else {
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

  void setDiscountAmount(double amount) {
    _discountAmount = amount;
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

  Future<bool> processSale(int userId) async {
    if (_items.isEmpty) return false;

    final receiptNumber = 'K${DateTime.now().millisecondsSinceEpoch}';

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
    );

    try {
      final result = await _apiService.processSale(sale);
      if (result != null) {
        clearCart();
        return true;
      }
      return false;
    } catch (e) {
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
}