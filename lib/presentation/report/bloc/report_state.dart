import 'package:equatable/equatable.dart';
import '../../../data/models/responses/report_model.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportSummary summary;
  final List<SalesReportItem> salesReport;
  final List<ServiceReportItem> serviceReport;
  final CustomerReportStats customerStats;
  final List<CustomerReportItem> topCustomers;
  final List<StaffReportItem> staffReport;
  final PackageReportStats packageStats;
  final List<PackageReportItem> packageReport;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    this.period = 'bulan_ini',
    this.startDate,
    this.endDate,
    required this.summary,
    this.salesReport = const [],
    this.serviceReport = const [],
    required this.customerStats,
    this.topCustomers = const [],
    this.staffReport = const [],
    required this.packageStats,
    this.packageReport = const [],
    this.errorMessage,
  });

  factory ReportState.initial() {
    return ReportState(
      summary: ReportSummary.empty(),
      customerStats: CustomerReportStats.empty(),
      packageStats: PackageReportStats.empty(),
    );
  }

  ReportState copyWith({
    ReportStatus? status,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    ReportSummary? summary,
    List<SalesReportItem>? salesReport,
    List<ServiceReportItem>? serviceReport,
    CustomerReportStats? customerStats,
    List<CustomerReportItem>? topCustomers,
    List<StaffReportItem>? staffReport,
    PackageReportStats? packageStats,
    List<PackageReportItem>? packageReport,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      summary: summary ?? this.summary,
      salesReport: salesReport ?? this.salesReport,
      serviceReport: serviceReport ?? this.serviceReport,
      customerStats: customerStats ?? this.customerStats,
      topCustomers: topCustomers ?? this.topCustomers,
      staffReport: staffReport ?? this.staffReport,
      packageStats: packageStats ?? this.packageStats,
      packageReport: packageReport ?? this.packageReport,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ReportStatus.loading;
  bool get isLoaded => status == ReportStatus.loaded;
  bool get hasError => status == ReportStatus.error;

  String get periodLabel {
    switch (period) {
      case 'hari_ini':
        return 'Hari Ini';
      case 'minggu_ini':
        return 'Minggu Ini';
      case 'bulan_ini':
        return 'Bulan Ini';
      case 'tahun_ini':
        return 'Tahun Ini';
      case 'custom':
        return 'Custom';
      default:
        return 'Bulan Ini';
    }
  }

  @override
  List<Object?> get props => [
        status,
        period,
        startDate,
        endDate,
        summary,
        salesReport,
        serviceReport,
        customerStats,
        topCustomers,
        staffReport,
        packageStats,
        packageReport,
        errorMessage,
      ];
}
