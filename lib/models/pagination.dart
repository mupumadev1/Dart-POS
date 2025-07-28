class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int perPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.perPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalRecords: json['total_records'] ?? 0,
      perPage: json['per_page'] ?? 20,
    );
  }
}
