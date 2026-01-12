import '../../domain/entities/sales_entity.dart';

class SalesSummaryModel extends SalesSummaryEntity {
  SalesSummaryModel({
    required super.totalSales,
    required super.totalBookings,
    required super.cashSales,
    required super.onlineSales,
    required super.walletSales,
    required super.totalCommission,
    required super.totalRefunds,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? json;
    return SalesSummaryModel(
      totalSales: (summary['totalSales'] ?? 0).toDouble(),
      totalBookings: summary['totalBookings'] ?? 0,
      cashSales: (summary['cashSales'] ?? 0).toDouble(),
      onlineSales: (summary['onlineSales'] ?? 0).toDouble(),
      walletSales: (summary['walletSales'] ?? 0).toDouble(),
      totalCommission: (summary['totalCommission'] ?? 0).toDouble(),
      totalRefunds: (summary['totalRefunds'] ?? 0).toDouble(),
    );
  }
}

class SalesGroupedDataModel extends SalesGroupedDataEntity {
  SalesGroupedDataModel({
    required super.key,
    required super.sales,
    required super.bookings,
  });

  factory SalesGroupedDataModel.fromJson(Map<String, dynamic> json) {
    return SalesGroupedDataModel(
      key: json['key'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
      bookings: json['bookings'] ?? 0,
    );
  }
}
