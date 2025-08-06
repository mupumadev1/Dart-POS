import 'package:pos_app/models/user.dart';

class Store {
  final int? id;
  final String storeNumber;
  final String storeLocation;
  final String storeMobileNo;
  final String nextInvoiceNumber;
  final List<User>? users; // Associated users (if included from API)

  Store({
    this.id,
    required this.storeNumber,
    required this.storeLocation,
    required this.storeMobileNo,
    required this.nextInvoiceNumber,
    this.users,
  });

  // Factory constructor to create Store from JSON
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int?,
      storeNumber: json['store_number'] as String,
      storeLocation: json['store_location'] as String,
      storeMobileNo: json['store_mobile_no'] as String,
      nextInvoiceNumber: json['next_invoice_number'] as String,
      users: json['users'] != null
          ? (json['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList()
          : null,
    );
  }

  // Convert Store to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'store_number': storeNumber,
      'store_location': storeLocation,
      'store_mobile_no': storeMobileNo,
      'next_invoice_number': nextInvoiceNumber,
    };
    return data;
  }

}