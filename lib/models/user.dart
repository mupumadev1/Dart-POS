import 'package:pos_app/models/store.dart';

class User {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final int storeId; // Reference to store table
  final Store? store; // Associated store object (when included from API)

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.storeId,
    this.store,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      storeId: json['store_id'],
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'store_id': storeId,
    };

    // Include store data if available
    if (store != null) {
      data['store'] = store!.toJson();
    }

    return data;
  }
}