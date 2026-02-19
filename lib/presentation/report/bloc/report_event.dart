import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Load all report data
class LoadReportData extends ReportEvent {
  final String period;
  final String? startDate;
  final String? endDate;

  const LoadReportData({
    required this.period,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [period, startDate, endDate];
}

/// Change report period
class ChangePeriod extends ReportEvent {
  final String period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Set custom date range
class SetCustomDateRange extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const SetCustomDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load sales report only
class LoadSalesReport extends ReportEvent {
  const LoadSalesReport();
}

/// Load services report only
class LoadServicesReport extends ReportEvent {
  const LoadServicesReport();
}

/// Load customers report only
class LoadCustomersReport extends ReportEvent {
  const LoadCustomersReport();
}

/// Load staff report only
class LoadStaffReport extends ReportEvent {
  const LoadStaffReport();
}

/// Load packages report only
class LoadPackagesReport extends ReportEvent {
  const LoadPackagesReport();
}

/// Refresh all report data
class RefreshReport extends ReportEvent {
  const RefreshReport();
}
