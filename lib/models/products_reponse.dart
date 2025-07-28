import 'package:pos_app/models/pagination.dart';
import 'package:pos_app/models/product.dart';

class ProductsResponse {
  final List<Product> products;
  final Pagination pagination;

  ProductsResponse({
    required this.products,
    required this.pagination,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: (json['products'] as List?)
          ?.map((product) => Product.fromJson(product))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
