import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../models/responses/dashboard_model.dart';
import 'api_service.dart';
import 'auth_local_datasource.dart';

class DashboardRemoteDatasource {
  final AuthLocalDatasource _localDatasource = AuthLocalDatasource();
  final ApiService? _api;

  DashboardRemoteDatasource({ApiService? api}) : _api = api;

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _localDatasource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get dashboard data
  Future<Either<String, DashboardModel>> getDashboard() async {
    try {
      developer.log('📡 getDashboard: Fetching from ${Variables.dashboard}', name: 'DashboardDatasource');

      final headers = await _getHeaders();
      developer.log('🔑 getDashboard: Token present: ${headers['Authorization']?.isNotEmpty ?? false}', name: 'DashboardDatasource');

      final response = await http.get(
        Uri.parse(Variables.dashboard),
        headers: headers,
      );

      developer.log('📥 getDashboard: Status ${response.statusCode}', name: 'DashboardDatasource');
      developer.log('📥 getDashboard: Body length ${response.body.length}', name: 'DashboardDatasource');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        developer.log('✅ getDashboard: Parsing response...', name: 'DashboardDatasource');
        final dashboard = DashboardModel.fromJson(body['data'] ?? body);
        developer.log('✅ getDashboard: Success! todayRevenue=${dashboard.todayRevenue}', name: 'DashboardDatasource');
        return Right(dashboard);
      } else if (response.statusCode == 401) {
        developer.log('🔒 getDashboard: Unauthorized - clearing session', name: 'DashboardDatasource');
        await _localDatasource.clearAll();
        return const Left('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        developer.log('⚠️ getDashboard: API not found (404)', name: 'DashboardDatasource');
        return const Left('Dashboard API tidak ditemukan.');
      } else {
        final message = body['message'] ?? 'Gagal mengambil data dashboard.';
        developer.log('❌ getDashboard: Error - $message', name: 'DashboardDatasource');
        return Left(message);
      }
    } catch (e, stackTrace) {
      developer.log('💥 getDashboard: Exception - $e', name: 'DashboardDatasource', error: e, stackTrace: stackTrace);
      return Left('Gagal mengambil data dashboard: $e');
    }
  }

  /// Get dashboard summary (quick stats)
  Future<Either<String, DashboardSummary>> getSummary({String? period}) async {
    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;

    final uri = Uri.parse(Variables.dashboardSummary).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (_api != null) {
      final result = await _api.get(uri.toString());
      return result.fold(
        (error) => Left(error),
        (data) {
          try {
            return Right(DashboardSummary.fromJson(data['data'] ?? data));
          } catch (e) {
            return Left('Gagal memproses data summary: $e');
          }
        },
      );
    }

    try {
      developer.log('📡 GET $uri', name: 'Dashboard');
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      developer.log('📥 Status ${response.statusCode}', name: 'Dashboard');
      developer.log('📥 Body: ${response.body}', name: 'Dashboard');

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(DashboardSummary.fromJson(body['data'] ?? body));
      } else {
        final message = body['message'] ?? 'Gagal mengambil data summary.';
        return Left(message);
      }
    } catch (e) {
      developer.log('❌ getSummary error: $e', name: 'Dashboard');
      return Left('Terjadi kesalahan jaringan.');
    }
  }

  /// Get dashboard with mock data for testing
  Future<Either<String, DashboardModel>> getDashboardMock() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock data
    final mockData = DashboardModel(
      todayRevenue: 2500000,
      monthlyRevenue: 45000000,
      todayAppointments: 12,
      monthlyAppointments: 156,
      newCustomers: 8,
      completedTreatments: 10,
      revenueChart: [
        RevenueChartData(date: '2025-01-22', dayName: 'Sen', amount: 1800000),
        RevenueChartData(date: '2025-01-23', dayName: 'Sel', amount: 2200000),
        RevenueChartData(date: '2025-01-24', dayName: 'Rab', amount: 1500000),
        RevenueChartData(date: '2025-01-25', dayName: 'Kam', amount: 2800000),
        RevenueChartData(date: '2025-01-26', dayName: 'Jum', amount: 3200000),
        RevenueChartData(date: '2025-01-27', dayName: 'Sab', amount: 4100000),
        RevenueChartData(date: '2025-01-28', dayName: 'Min', amount: 2500000),
      ],
      todayAppointmentsList: [
        TodayAppointment(
          id: 1,
          customerName: 'Sarah Wijaya',
          customerPhone: '081234567890',
          serviceName: 'Facial Treatment',
          startTime: '09:00',
          endTime: '10:00',
          status: 'confirmed',
          staffName: 'Dr. Rina',
        ),
        TodayAppointment(
          id: 2,
          customerName: 'Linda Susanti',
          customerPhone: '081234567891',
          serviceName: 'Laser Rejuvenation',
          startTime: '10:30',
          endTime: '11:30',
          status: 'in_progress',
          staffName: 'Dr. Maya',
        ),
        TodayAppointment(
          id: 3,
          customerName: 'Dewi Anggraini',
          customerPhone: '081234567892',
          serviceName: 'Chemical Peeling',
          startTime: '13:00',
          endTime: '14:00',
          status: 'pending',
          staffName: 'Dr. Rina',
        ),
        TodayAppointment(
          id: 4,
          customerName: 'Rika Maharani',
          customerPhone: '081234567893',
          serviceName: 'Botox Injection',
          startTime: '14:30',
          endTime: '15:00',
          status: 'pending',
        ),
        TodayAppointment(
          id: 5,
          customerName: 'Amanda Putri',
          customerPhone: '081234567894',
          serviceName: 'Microdermabrasi',
          startTime: '15:30',
          endTime: '16:30',
          status: 'pending',
          staffName: 'Dr. Maya',
        ),
      ],
    );

    return Right(mockData);
  }
}
