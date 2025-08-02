class PaginatedSalesResult {
  final List<Map<String, dynamic>> sales;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int perPage;

  PaginatedSalesResult({
    required this.sales,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.perPage,
  });
}