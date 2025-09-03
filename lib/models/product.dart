import 'category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final String? productClassCode;
  final String? productCode;
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
    this.productClassCode,
    this.productCode,
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
      productClassCode: json['product_class_code'],
      productCode: json['product_code'],
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
      'product_class_code':productClassCode,
      'product_code':productCode,
      'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'min_stock_level': minStockLevel,
      'is_active': isActive,
    };
  }
  bool get isLowStock => stockQuantity <= minStockLevel;
}