import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../data/datasources/report_remote_datasource.dart';
import '../../../data/models/responses/report_model.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRemoteDatasource _datasource;

  ReportBloc({required ReportRemoteDatasource datasource})
      : _datasource = datasource,
        super(ReportState.initial()) {
    on<LoadReportData>(_onLoadReportData);
    on<ChangePeriod>(_onChangePeriod);
    on<SetCustomDateRange>(_onSetCustomDateRange);
    on<LoadSalesReport>(_onLoadSalesReport);
    on<LoadServicesReport>(_onLoadServicesReport);
    on<LoadCustomersReport>(_onLoadCustomersReport);
    on<LoadStaffReport>(_onLoadStaffReport);
    on<LoadPackagesReport>(_onLoadPackagesReport);
    on<RefreshReport>(_onRefreshReport);
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _onLoadReportData(
    LoadReportData event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      period: event.period,
    ));

    // Load all report data
    final result = await _datasource.getReportData(
      period: event.period,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        summary: data.summary,
        salesReport: data.salesReport,
        serviceReport: data.serviceReport,
        customerStats: data.customerStats,
        topCustomers: data.topCustomers,
        staffReport: data.staffReport,
        packageStats: data.packageStats,
        packageReport: data.packageReport,
      )),
    );
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      period: event.period,
      startDate: null,
      endDate: null,
    ));

    await _loadAllData(emit, event.period);
  }

  Future<void> _onSetCustomDateRange(
    SetCustomDateRange event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      period: 'custom',
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    await _loadAllData(
      emit,
      'custom',
      startDate: _formatDate(event.startDate),
      endDate: _formatDate(event.endDate),
    );
  }

  Future<void> _loadAllData(
    Emitter<ReportState> emit,
    String period, {
    String? startDate,
    String? endDate,
  }) async {
    final result = await _datasource.getReportData(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        summary: data.summary,
        salesReport: data.salesReport,
        serviceReport: data.serviceReport,
        customerStats: data.customerStats,
        topCustomers: data.topCustomers,
        staffReport: data.staffReport,
        packageStats: data.packageStats,
        packageReport: data.packageReport,
      )),
    );
  }

  Future<void> _onLoadSalesReport(
    LoadSalesReport event,
    Emitter<ReportState> emit,
  ) async {
    final result = await _datasource.getSalesReport(
      period: state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        salesReport: data,
      )),
    );
  }

  Future<void> _onLoadServicesReport(
    LoadServicesReport event,
    Emitter<ReportState> emit,
  ) async {
    final result = await _datasource.getServicesReport(
      period: state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        serviceReport: data,
      )),
    );
  }

  Future<void> _onLoadCustomersReport(
    LoadCustomersReport event,
    Emitter<ReportState> emit,
  ) async {
    final result = await _datasource.getCustomersReport(
      period: state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        customerStats: data['stats'] as CustomerReportStats,
        topCustomers: data['top_customers'] as List<CustomerReportItem>,
      )),
    );
  }

  Future<void> _onLoadStaffReport(
    LoadStaffReport event,
    Emitter<ReportState> emit,
  ) async {
    final result = await _datasource.getStaffReport(
      period: state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        staffReport: data,
      )),
    );
  }

  Future<void> _onLoadPackagesReport(
    LoadPackagesReport event,
    Emitter<ReportState> emit,
  ) async {
    final result = await _datasource.getPackagesReport(
      period: state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: error,
      )),
      (data) => emit(state.copyWith(
        status: ReportStatus.loaded,
        packageStats: data['stats'] as PackageReportStats,
        packageReport: data['packages'] as List<PackageReportItem>,
      )),
    );
  }

  Future<void> _onRefreshReport(
    RefreshReport event,
    Emitter<ReportState> emit,
  ) async {
    await _loadAllData(
      emit,
      state.period,
      startDate: state.startDate != null ? _formatDate(state.startDate!) : null,
      endDate: state.endDate != null ? _formatDate(state.endDate!) : null,
    );
  }
}
