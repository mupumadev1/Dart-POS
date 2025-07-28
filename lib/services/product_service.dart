import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/exception.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/products_reponse.dart';
import '../models/sales_report.dart';
import '../models/stock_adjustment.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Replace with your API URL
  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<Map<String, String>> get authHeaders async {
    await loadToken(); // Ensure token is loaded
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
  // Helper method to handle API responses
  T _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body);
      return fromJson(data);
    } else {
      final Map<String, dynamic>? errorData =
      response.body.isNotEmpty ? json.decode(response.body) : null;
      final String errorMessage = errorData?['message'] ?? 'Unknown error occurred';
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // Get all products with pagination and search (enhanced version of your existing method)
  Future<ProductsResponse> getProductsWithPagination({
    int page = 1,
    int limit = 20,
    String? search,
    int? categoryId,
    bool? activeOnly,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (activeOnly != null) {
        queryParams['active_only'] = activeOnly.toString();
      }

      final Uri uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await authHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Your existing simple products method (keeping for backward compatibility)
  Future<List<Product>> getProducts({int? categoryId}) async {
    try {
      String url = '$baseUrl/products';
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> productsData = responseData['products'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['product']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Your existing barcode method (keeping as is)
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/barcode/$barcode'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['product']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create new product
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: await authHeaders,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Product.fromJson(data['product']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create product');
      }
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  // Update product
  Future<Product?> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: await authHeaders,
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data['product']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // Update stock quantity
  Future<Map<String, dynamic>?> updateStock(int id, StockAdjustment adjustment) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/products/$id/stock'),
        headers: await authHeaders,
        body: json.encode(adjustment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'product': Product.fromJson(data['product']),
          'previous_stock': data['previous_stock'],
          'new_stock': data['new_stock'],
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update stock');
      }
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/reports/low-stock'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsData = data['products'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load low stock products');
      }
    } catch (e) {
      throw Exception('Error fetching low stock products: $e');
    }
  }

  // Get product sales report
  Future<Map<String, dynamic>?> getProductSalesReport(
      int productId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      final Map<String, String> queryParams = {};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final Uri uri = Uri.parse('$baseUrl/products/$productId/sales-report')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await authHeaders);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'product_sales': data['product_sales'],
          'summary': SalesReportSummary.fromJson(data['summary']),
        };
      } else {
        throw Exception('Failed to load sales report');
      }
    } catch (e) {
      throw Exception('Error fetching sales report: $e');
    }
  }

  // Delete product (soft delete)
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Convenience methods for stock adjustments
  Future<Map<String, dynamic>?> addStock(int productId, int quantity, {String? reason}) {
    return updateStock(
      productId,
      StockAdjustment(
        stockQuantity: quantity,
        adjustmentType: 'add',
        adjustmentReason: reason,
      ),
    );
  }

  Future<Map<String, dynamic>?> subtractStock(int productId, int quantity, {String? reason}) {
    return updateStock(
      productId,
      StockAdjustment(
        stockQuantity: quantity,
        adjustmentType: 'subtract',
        adjustmentReason: reason,
      ),
    );
  }

  Future<Map<String, dynamic>?> setStock(int productId, int quantity, {String? reason}) {
    return updateStock(
      productId,
      StockAdjustment(
        stockQuantity: quantity,
        adjustmentReason: reason,
      ),
    );
  }

  // Categories (your existing method pattern)
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}