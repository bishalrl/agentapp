class SalesSummaryEntity {
  final double totalSales;
  final int totalBookings;
  final double cashSales;
  final double onlineSales;
  final double walletSales;
  final double totalCommission;
  final double totalRefunds;

  SalesSummaryEntity({
    required this.totalSales,
    required this.totalBookings,
    required this.cashSales,
    required this.onlineSales,
    required this.walletSales,
    required this.totalCommission,
    required this.totalRefunds,
  });
}

class SalesGroupedDataEntity {
  final String key;
  final double sales;
  final int bookings;

  SalesGroupedDataEntity({
    required this.key,
    required this.sales,
    required this.bookings,
  });
}
