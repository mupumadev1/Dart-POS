class User {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final String storeLocation;
  final String storeMobileNo;
  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.storeLocation,
    required this.storeMobileNo
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
        createdAt:DateTime.now(),
      storeLocation: json['store_location'],
      storeMobileNo: json['store_mobile_no']
    );
  }
}