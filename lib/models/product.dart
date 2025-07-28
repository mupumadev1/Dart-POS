import 'category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final String? barcode;
  final int? categoryId;
  final int stockQuantity;
  final int minStockLevel;
  final bool isActive;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.cost,
    this.barcode,
    this.categoryId,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.isActive,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      cost: double.parse(json['cost'].toString()),
      barcode: json['barcode'],
      categoryId: json['category_id'],
      stockQuantity: json['stock_quantity'] ?? 0,
      minStockLevel: json['min_stock_level'] ?? 0,
      isActive: json['is_active'] ?? true,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'barcode': barcode,
      'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'is_active': isActive,
    };
  }
  bool get isLowStock => stockQuantity <= minStockLevel;
}