import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDatasource _datasource;

  DashboardBloc({
    required DashboardRemoteDatasource datasource,
  })  : _datasource = datasource,
        super(const DashboardState()) {
    on<FetchDashboard>(_onFetchDashboard);
    on<FetchDashboardSummary>(_onFetchSummary);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ClearDashboardError>(_onClearError);
  }

  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    developer.log('🚀 FetchDashboard started', name: 'DashboardBloc');
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _datasource.getDashboard();

    result.fold(
      (error) {
        developer.log('❌ FetchDashboard error: $error', name: 'DashboardBloc');
        emit(state.copyWith(isLoading: false, error: error));
      },
      (data) {
        developer.log('✅ FetchDashboard success: todayRevenue=${data.todayRevenue}', name: 'DashboardBloc');
        emit(state.copyWith(isLoading: false, data: data));
      },
    );
  }

  Future<void> _onFetchSummary(
    FetchDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoadingSummary: true, clearError: true));

    final result = await _datasource.getSummary(period: event.period);

    result.fold(
      (error) => emit(state.copyWith(isLoadingSummary: false, error: error)),
      (summary) =>
          emit(state.copyWith(isLoadingSummary: false, summary: summary)),
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Don't show loading indicator for refresh
    final result = await _datasource.getDashboard();

    result.fold(
      (error) => emit(state.copyWith(error: error)),
      (data) => emit(state.copyWith(data: data)),
    );
  }

  void _onClearError(
    ClearDashboardError event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
