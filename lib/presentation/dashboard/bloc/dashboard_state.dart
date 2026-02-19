import 'package:equatable/equatable.dart';
import '../../../data/models/responses/dashboard_model.dart';

class DashboardState extends Equatable {
  final DashboardModel? data;
  final DashboardSummary? summary;
  final bool isLoading;
  final bool isLoadingSummary;
  final String? error;

  const DashboardState({
    this.data,
    this.summary,
    this.isLoading = false,
    this.isLoadingSummary = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardModel? data,
    DashboardSummary? summary,
    bool? isLoading,
    bool? isLoadingSummary,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      data: data ?? this.data,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasData => data != null;
  bool get hasSummary => summary != null;

  // Convenience getters for dashboard stats
  int get todayAppointmentsCount => data?.todayAppointments ?? 0;
  int get monthlyAppointmentsCount => data?.monthlyAppointments ?? 0;
  int get todayRevenueAmount => data?.todayRevenue ?? 0;
  int get monthlyRevenueAmount => data?.monthlyRevenue ?? 0;
  List<TodayAppointment> get todayAppointmentsList =>
      data?.todayAppointmentsList ?? [];

  @override
  List<Object?> get props => [
        data,
        summary,
        isLoading,
        isLoadingSummary,
        error,
      ];
}
