class DashboardModel {
  final int todayRevenue;
  final int monthlyRevenue;
  final int todayAppointments;
  final int monthlyAppointments;
  final int newCustomers;
  final int completedTreatments;
  final List<RevenueChartData> revenueChart;
  final List<TodayAppointment> todayAppointmentsList;

  DashboardModel({
    required this.todayRevenue,
    required this.monthlyRevenue,
    required this.todayAppointments,
    required this.monthlyAppointments,
    required this.newCustomers,
    required this.completedTreatments,
    required this.revenueChart,
    required this.todayAppointmentsList,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // API returns nested structure: today: {...}, month: {...}
    final today = json['today'] as Map<String, dynamic>? ?? {};
    final month = json['month'] as Map<String, dynamic>? ?? {};

    // Parse revenue chart: API returns {labels: [...], data: [...]}
    final revenueChartRaw = json['revenue_chart'];
    List<RevenueChartData> revenueChartList = [];
    if (revenueChartRaw is Map<String, dynamic>) {
      final labels = (revenueChartRaw['labels'] as List?) ?? [];
      final data = (revenueChartRaw['data'] as List?) ?? [];
      for (var i = 0; i < labels.length && i < data.length; i++) {
        revenueChartList.add(RevenueChartData(
          date: '',
          dayName: labels[i]?.toString() ?? '',
          amount: _parseInt(data[i]),
        ));
      }
    } else if (revenueChartRaw is List) {
      revenueChartList =
          revenueChartRaw.map((e) => RevenueChartData.fromJson(e)).toList();
    }

    // Parse today_appointments: array of full appointment objects
    final todayApptList = json['today_appointments'];
    List<TodayAppointment> appointmentsList = [];
    if (todayApptList is List) {
      appointmentsList =
          todayApptList.map((e) => TodayAppointment.fromJson(e)).toList();
    }

    return DashboardModel(
      todayRevenue: _parseInt(today['revenue'] ?? json['today_revenue']),
      monthlyRevenue:
          _parseInt(month['total_revenue'] ?? json['monthly_revenue']),
      todayAppointments:
          _parseInt(today['appointments'] ?? json['today_appointments']),
      monthlyAppointments:
          _parseInt(month['total_appointments'] ?? json['monthly_appointments']),
      newCustomers: _parseInt(today['new_customers'] ?? json['new_customers']),
      completedTreatments:
          _parseInt(today['completed'] ?? json['completed_treatments']),
      revenueChart: revenueChartList,
      todayAppointmentsList: appointmentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_revenue': todayRevenue,
      'monthly_revenue': monthlyRevenue,
      'today_appointments': todayAppointments,
      'monthly_appointments': monthlyAppointments,
      'new_customers': newCustomers,
      'completed_treatments': completedTreatments,
      'revenue_chart': revenueChart.map((e) => e.toJson()).toList(),
      'today_appointments_list':
          todayAppointmentsList.map((e) => e.toJson()).toList(),
    };
  }

  /// Create empty dashboard for initial state
  factory DashboardModel.empty() {
    return DashboardModel(
      todayRevenue: 0,
      monthlyRevenue: 0,
      todayAppointments: 0,
      monthlyAppointments: 0,
      newCustomers: 0,
      completedTreatments: 0,
      revenueChart: [],
      todayAppointmentsList: [],
    );
  }
}

class RevenueChartData {
  final String date;
  final String dayName;
  final int amount;

  RevenueChartData({
    required this.date,
    required this.dayName,
    required this.amount,
  });

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    return RevenueChartData(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? json['day'] ?? '',
      amount: DashboardModel._parseInt(json['amount'] ?? json['revenue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day_name': dayName,
      'amount': amount,
    };
  }
}

class TodayAppointment {
  final int id;
  final String customerName;
  final String? customerPhone;
  final String serviceName;
  final String startTime;
  final String endTime;
  final String status;
  final String? staffName;
  final int? staffId;

  TodayAppointment({
    required this.id,
    required this.customerName,
    this.customerPhone,
    required this.serviceName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.staffName,
    this.staffId,
  });

  /// Format time string to HH:mm (remove seconds if present)
  static String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    // If format is HH:mm:ss, trim to HH:mm
    if (time.length >= 5) {
      return time.substring(0, 5);
    }
    return time;
  }

  factory TodayAppointment.fromJson(Map<String, dynamic> json) {
    // API returns full appointment objects with nested customer/service/staff
    final customer = json['customer'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    final staff = json['staff'] as Map<String, dynamic>?;

    return TodayAppointment(
      id: json['id'] ?? 0,
      customerName: customer?['name'] ?? json['customer_name'] ?? '',
      customerPhone: customer?['phone'] ?? json['customer_phone'],
      serviceName: service?['name'] ?? json['service_name'] ?? '',
      startTime: _formatTime(json['start_time']),
      endTime: _formatTime(json['end_time']),
      status: json['status'] ?? 'pending',
      staffName: staff?['name'] ?? json['staff_name'],
      staffId: json['staff_id'] ?? staff?['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'staff_name': staffName,
      'staff_id': staffId,
    };
  }

  /// Get formatted start time (already formatted in fromJson)
  String get formattedStartTime => startTime;

  /// Get formatted end time (already formatted in fromJson)
  String get formattedEndTime => endTime;

  /// Get formatted time range
  String get timeRange => '$startTime - $endTime';
}

/// Dashboard quick summary
class DashboardSummary {
  final int totalCustomers;
  final int totalServices;
  final int totalStaff;
  final int todayAppointments;
  final int monthRevenue;
  final int monthTransactions;

  DashboardSummary({
    required this.totalCustomers,
    required this.totalServices,
    required this.totalStaff,
    required this.todayAppointments,
    required this.monthRevenue,
    required this.monthTransactions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalCustomers: json['total_customers'] ?? 0,
      totalServices: json['total_services'] ?? 0,
      totalStaff: json['total_staff'] ?? 0,
      todayAppointments: json['today_appointments'] ?? 0,
      monthRevenue: json['month_revenue'] ?? 0,
      monthTransactions: json['month_transactions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_customers': totalCustomers,
        'total_services': totalServices,
        'total_staff': totalStaff,
        'today_appointments': todayAppointments,
        'month_revenue': monthRevenue,
        'month_transactions': monthTransactions,
      };
}

/// Popular service data for dashboard
class PopularService {
  final int id;
  final String name;
  final int count;
  final double revenue;
  final String? formattedRevenue;

  PopularService({
    required this.id,
    required this.name,
    required this.count,
    required this.revenue,
    this.formattedRevenue,
  });

  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      formattedRevenue: json['formatted_revenue'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'count': count,
        'revenue': revenue,
        'formatted_revenue': formattedRevenue,
      };
}
