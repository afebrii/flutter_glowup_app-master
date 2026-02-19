import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboard extends DashboardEvent {
  const FetchDashboard();
}

class FetchDashboardSummary extends DashboardEvent {
  final String? period;

  const FetchDashboardSummary({this.period});

  @override
  List<Object?> get props => [period];
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class ClearDashboardError extends DashboardEvent {
  const ClearDashboardError();
}
