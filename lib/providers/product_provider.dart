import 'package:flutter/material.dart';
import 'package:pos_app/services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/stock_adjustment.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  List<Product> _lowStockProducts = [];
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  String _error = '';
  int? _selectedCategoryId;

  // Pagination properties
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  int _perPage = 20;
  String _searchQuery = '';
  bool _activeOnly = true;

  // Getters
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<Product> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  String get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;
  int get perPage => _perPage;
  String get searchQuery => _searchQuery;
  bool get activeOnly => _activeOnly;

  final ApiService _apiService = ApiService();
  final ProductService _productService = ProductService();

  List<Product> get filteredProducts {
    if (_selectedCategoryId == null) return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _error = '';
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Products - Simple load (your existing method)
  Future<void> loadProducts({int? categoryId}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _products = await _productService.getProducts(categoryId: categoryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Products - Load with pagination
  Future<void> loadProductsWithPagination({
    int page = 1,
    String? search,
    int? categoryId,
    bool? activeOnly,
    bool append = false,
  }) async {
    if (!append) {
      _isLoading = true;
      _products.clear();
    }
    _error = '';
    notifyListeners();

    try {
      final response = await _productService.getProductsWithPagination(
        page: page,
        limit: _perPage,
        search: search,
        categoryId: categoryId,
        activeOnly: activeOnly,
      );

      if (append) {
        _products.addAll(response.products);
      } else {
        _products = response.products;
      }

      _currentPage = response.pagination.currentPage;
      _totalPages = response.pagination.totalPages;
      _totalRecords = response.pagination.totalRecords;
      _searchQuery = search ?? '';
      _selectedCategoryId = categoryId;
      _activeOnly = activeOnly ?? true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more products (for pagination)
  Future<void> loadMoreProducts() async {
    if (_currentPage < _totalPages && !_isLoading) {
      await loadProductsWithPagination(
        page: _currentPage + 1,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
        activeOnly: _activeOnly,
        append: true,
      );
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await loadProductsWithPagination(
      page: 1,
      search: query.isEmpty ? null : query,
      categoryId: _selectedCategoryId,
      activeOnly: _activeOnly,
    );
  }

  // Select category filter
  void selectCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    await loadProductsWithPagination(
      page: 1,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      categoryId: categoryId,
      activeOnly: _activeOnly,
    );
  }

  // Toggle active only filter
  void toggleActiveOnly() async {
    _activeOnly = !_activeOnly;
    await loadProductsWithPagination(
      page: 1,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      categoryId: _selectedCategoryId,
      activeOnly: _activeOnly,
    );
  }

  // Get single product
  Future<Product?> getProductById(int id) async {
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search by barcode (your existing method)
  Future<Product?> searchByBarcode(String barcode) async {
    try {
      return await _productService.getProductByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  // Create product
  Future<bool> createProduct(Product product) async {
    _isCreating = true;
    _error = '';
    notifyListeners();

    try {
      final createdProduct = await _productService.createProduct(product);
      if (createdProduct != null) {
        // Add to local list if it matches current filters
        if (_shouldIncludeInCurrentView(createdProduct)) {
          _products.insert(0, createdProduct);
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // Update product
  Future<bool> updateProduct(int id, Product product) async {
    _isUpdating = true;
    _error = '';
    notifyListeners();

    try {
      final updatedProduct = await _productService.updateProduct(id, product);
      if (updatedProduct != null) {
        // Update in local list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          if (_shouldIncludeInCurrentView(updatedProduct)) {
            _products[index] = updatedProduct;
          } else {
            _products.removeAt(index);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    _error = '';

    try {
      final success = await _productService.deleteProduct(id);
      if (success) {
        // Remove from local list
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Stock management
  Future<bool> updateStock(int productId, int quantity, {
    String? adjustmentType, // 'add', 'subtract', or null for direct set
    String? reason,
  }) async {
    _error = '';

    try {
      final result = await _productService.updateStock(
        productId,
        StockAdjustment(
          stockQuantity: quantity,
          adjustmentType: adjustmentType,
          adjustmentReason: reason,
        ),
      );

      if (result != null) {
        // Update product in local list
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = result['product'] as Product;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Convenience stock methods
  Future<bool> addStock(int productId, int quantity, {String? reason}) {
    return updateStock(productId, quantity, adjustmentType: 'add', reason: reason);
  }

  Future<bool> subtractStock(int productId, int quantity, {String? reason}) {
    return updateStock(productId, quantity, adjustmentType: 'subtract', reason: reason);
  }

  Future<bool> setStock(int productId, int quantity, {String? reason}) {
    return updateStock(productId, quantity, reason: reason);
  }

  // Load low stock products
  Future<void> loadLowStockProducts() async {
    _error = '';

    try {
      _lowStockProducts = await _productService.getLowStockProducts();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Get sales report for a product
  Future<Map<String, dynamic>?> getProductSalesReport(
      int productId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    _error = '';

    try {
      return await _productService.getProductSalesReport(
        productId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Helper method to check if product should be included in current view
  bool _shouldIncludeInCurrentView(Product product) {
    // Check active filter
    if (_activeOnly && !product.isActive) return false;

    // Check category filter
    if (_selectedCategoryId != null && product.categoryId != _selectedCategoryId) {
      return false;
    }

    // Check search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      final matchesName = product.name.toLowerCase().contains(query);
      final matchesClassCode= product.productClassCode?.toLowerCase().contains(query) ?? false;
      if (!matchesName && !matchesClassCode) return false;
    }

    return true;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadProductsWithPagination(
      page: 1,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      categoryId: _selectedCategoryId,
      activeOnly: _activeOnly,
    );
  }

  // Reset filters
  void resetFilters() async {
    _selectedCategoryId = null;
    _searchQuery = '';
    _activeOnly = true;
    await loadProductsWithPagination(page: 1);
  }
}