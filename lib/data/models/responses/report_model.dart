/// Report Models for GlowUp Clinic App

/// Summary report data
class ReportSummary {
  final int totalRevenue;
  final int totalTransactions;
  final int newCustomers;
  final int averageTransaction;
  final double revenueChange;
  final double transactionChange;
  final double customerChange;
  final double averageChange;

  ReportSummary({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.newCustomers,
    required this.averageTransaction,
    this.revenueChange = 0,
    this.transactionChange = 0,
    this.customerChange = 0,
    this.averageChange = 0,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalRevenue: json['total_revenue'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
      newCustomers: json['new_customers'] ?? 0,
      averageTransaction: json['average_transaction'] ?? 0,
      revenueChange: (json['revenue_change'] ?? 0).toDouble(),
      transactionChange: (json['transaction_change'] ?? 0).toDouble(),
      customerChange: (json['customer_change'] ?? 0).toDouble(),
      averageChange: (json['average_change'] ?? 0).toDouble(),
    );
  }

  factory ReportSummary.empty() {
    return ReportSummary(
      totalRevenue: 0,
      totalTransactions: 0,
      newCustomers: 0,
      averageTransaction: 0,
    );
  }
}

/// Daily sales report item
class SalesReportItem {
  final String date;
  final int transactions;
  final int revenue;

  SalesReportItem({
    required this.date,
    required this.transactions,
    required this.revenue,
  });

  factory SalesReportItem.fromJson(Map<String, dynamic> json) {
    return SalesReportItem(
      date: json['date'] ?? '',
      transactions: json['transactions'] ?? 0,
      revenue: json['revenue'] ?? 0,
    );
  }
}

/// Service report item
class ServiceReportItem {
  final int id;
  final String name;
  final int count;
  final int revenue;

  ServiceReportItem({
    required this.id,
    required this.name,
    required this.count,
    required this.revenue,
  });

  factory ServiceReportItem.fromJson(Map<String, dynamic> json) {
    return ServiceReportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      revenue: json['revenue'] ?? 0,
    );
  }
}

/// Customer report item
class CustomerReportItem {
  final int id;
  final String name;
  final int visits;
  final int totalSpent;
  final String? photoUrl;

  CustomerReportItem({
    required this.id,
    required this.name,
    required this.visits,
    required this.totalSpent,
    this.photoUrl,
  });

  factory CustomerReportItem.fromJson(Map<String, dynamic> json) {
    return CustomerReportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      visits: json['visits'] ?? 0,
      totalSpent: json['total_spent'] ?? json['total'] ?? 0,
      photoUrl: json['photo_url'],
    );
  }
}

/// Customer stats for report
class CustomerReportStats {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomers;

  CustomerReportStats({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomers,
  });

  factory CustomerReportStats.fromJson(Map<String, dynamic> json) {
    return CustomerReportStats(
      totalCustomers: json['total_customers'] ?? json['total'] ?? 0,
      activeCustomers: json['active_customers'] ?? json['active'] ?? 0,
      newCustomers: json['new_customers'] ?? json['new'] ?? 0,
    );
  }

  factory CustomerReportStats.empty() {
    return CustomerReportStats(
      totalCustomers: 0,
      activeCustomers: 0,
      newCustomers: 0,
    );
  }
}

/// Staff report item
class StaffReportItem {
  final int id;
  final String name;
  final String role;
  final int patients;
  final int revenue;
  final String? photoUrl;

  StaffReportItem({
    required this.id,
    required this.name,
    required this.role,
    required this.patients,
    required this.revenue,
    this.photoUrl,
  });

  factory StaffReportItem.fromJson(Map<String, dynamic> json) {
    return StaffReportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      patients: json['patients'] ?? json['appointments'] ?? 0,
      revenue: json['revenue'] ?? 0,
      photoUrl: json['photo_url'],
    );
  }
}

/// Package report item
class PackageReportItem {
  final int id;
  final String name;
  final int sold;
  final int revenue;

  PackageReportItem({
    required this.id,
    required this.name,
    required this.sold,
    required this.revenue,
  });

  factory PackageReportItem.fromJson(Map<String, dynamic> json) {
    return PackageReportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sold: json['sold'] ?? json['count'] ?? 0,
      revenue: json['revenue'] ?? 0,
    );
  }
}

/// Package report stats
class PackageReportStats {
  final int totalSold;
  final int totalRevenue;

  PackageReportStats({
    required this.totalSold,
    required this.totalRevenue,
  });

  factory PackageReportStats.fromJson(Map<String, dynamic> json) {
    return PackageReportStats(
      totalSold: json['total_sold'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
    );
  }

  factory PackageReportStats.empty() {
    return PackageReportStats(totalSold: 0, totalRevenue: 0);
  }
}

/// Complete report data
class ReportData {
  final ReportSummary summary;
  final List<SalesReportItem> salesReport;
  final List<ServiceReportItem> serviceReport;
  final CustomerReportStats customerStats;
  final List<CustomerReportItem> topCustomers;
  final List<StaffReportItem> staffReport;
  final PackageReportStats packageStats;
  final List<PackageReportItem> packageReport;

  ReportData({
    required this.summary,
    required this.salesReport,
    required this.serviceReport,
    required this.customerStats,
    required this.topCustomers,
    required this.staffReport,
    required this.packageStats,
    required this.packageReport,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      summary: ReportSummary.fromJson(json['summary'] ?? {}),
      salesReport: (json['sales'] as List? ?? [])
          .map((e) => SalesReportItem.fromJson(e))
          .toList(),
      serviceReport: (json['services'] as List? ?? [])
          .map((e) => ServiceReportItem.fromJson(e))
          .toList(),
      customerStats: CustomerReportStats.fromJson(json['customer_stats'] ?? {}),
      topCustomers: (json['top_customers'] as List? ?? [])
          .map((e) => CustomerReportItem.fromJson(e))
          .toList(),
      staffReport: (json['staff'] as List? ?? [])
          .map((e) => StaffReportItem.fromJson(e))
          .toList(),
      packageStats: PackageReportStats.fromJson(json['package_stats'] ?? {}),
      packageReport: (json['packages'] as List? ?? [])
          .map((e) => PackageReportItem.fromJson(e))
          .toList(),
    );
  }

  factory ReportData.empty() {
    return ReportData(
      summary: ReportSummary.empty(),
      salesReport: [],
      serviceReport: [],
      customerStats: CustomerReportStats.empty(),
      topCustomers: [],
      staffReport: [],
      packageStats: PackageReportStats.empty(),
      packageReport: [],
    );
  }
}
