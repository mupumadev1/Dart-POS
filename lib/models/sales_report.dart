class SalesReportSummary {
  final int totalQuantitySold;
  final double totalRevenue;
  final int totalTransactions;
  final double averageQuantityPerSale;

  SalesReportSummary({
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageQuantityPerSale,
  });

  factory SalesReportSummary.fromJson(Map<String, dynamic> json) {
    return SalesReportSummary(
      totalQuantitySold: json['total_quantity_sold'] ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['total_transactions'] ?? 0,
      averageQuantityPerSale: (json['average_quantity_per_sale'] as num?)?.toDouble() ?? 0.0,
    );
  }
}