import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paginated_sales_result.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/sale.dart';



class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Replace with your API URL
  String? _token;

  // Authentication
  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];  // Use underscore, not asterisk

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!); // Use underscore, not asterisk

        return User.fromJson(data['user']);
      } else {
        // Handle different error status codes
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

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

  // Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: await authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey('categories') && json['categories'] is List) {
          final List<dynamic> data = json['categories'];
          return data.map((item) => Category.fromJson(item)).toList();
        } else {
          throw Exception('Invalid response format: missing "categories" list');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }


  // Products

  // Sales
  Future<Map<String, dynamic>?> processSale(Sale sale) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: await authHeaders,
        body: json.encode(sale.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Error processing sale: $e');
    }
  }

  Future<Map<String, dynamic>> getPaginatedSales({int page = 1, int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/sales?page=$page&limit=$limit');
      final response = await http.get(url, headers: await authHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data; // Contains sales list and pagination info
      } else {
        throw Exception('Failed to fetch sales');
      }
    } catch (e) {
      throw Exception('Error fetching sales: $e');
    }
  }


  Future<PaginatedSalesResult> getSalesHistoryPaginated({
  int page = 1,
  int limit = 20,
  DateTime? startDate,
  DateTime? endDate,
  int? userId,
  }) async {
  try {
  String url = '$baseUrl/sales';
  List<String> queryParams = [];

  if (startDate != null) {
  queryParams.add('start_date=${startDate.toIso8601String()}');
  }
  if (endDate != null) {
  queryParams.add('end_date=${endDate.toIso8601String()}');
  }
  if (userId != null) {
  queryParams.add('user_id=$userId');
  }

  queryParams.add('page=$page');
  queryParams.add('limit=$limit');

  if (queryParams.isNotEmpty) {
  url += '?${queryParams.join('&')}';
  }

  final response = await http.get(
  Uri.parse(url),
  headers: await authHeaders,
  );

  if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final List<Map<String, dynamic>> sales =
  List<Map<String, dynamic>>.from(data['sales']);
  final pagination = data['pagination'];

  return PaginatedSalesResult(
  sales: sales,
  currentPage: pagination['current_page'],
  totalPages: pagination['total_pages'],
  totalRecords: pagination['total_records'],
  perPage: pagination['per_page'],
  );
  } else {
  throw Exception('Failed to load sales history');
  }
  } catch (e) {
  throw Exception('Error fetching sales history: $e');
  }
  }
}