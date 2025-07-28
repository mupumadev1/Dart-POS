class StockAdjustment {
  final int stockQuantity;
  final String? adjustmentType; // 'add', 'subtract', or null for direct set
  final String? adjustmentReason;

  StockAdjustment({
    required this.stockQuantity,
    this.adjustmentType,
    this.adjustmentReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'stock_quantity': stockQuantity,
      if (adjustmentType != null) 'adjustment_type': adjustmentType,
      if (adjustmentReason != null) 'adjustment_reason': adjustmentReason,
    };
  }
}