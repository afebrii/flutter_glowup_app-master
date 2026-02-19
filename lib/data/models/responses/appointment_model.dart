import 'customer_model.dart';
import 'service_model.dart';
import 'user_model.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Menunggu';
      case AppointmentStatus.confirmed:
        return 'Dikonfirmasi';
      case AppointmentStatus.inProgress:
        return 'Sedang Berjalan';
      case AppointmentStatus.completed:
        return 'Selesai';
      case AppointmentStatus.cancelled:
        return 'Dibatalkan';
      case AppointmentStatus.noShow:
        return 'Tidak Hadir';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.inProgress:
        return 'in_progress';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.noShow:
        return 'no_show';
    }
  }
}

enum AppointmentSource {
  walkIn,
  phone,
  whatsapp,
  online;

  String get label {
    switch (this) {
      case AppointmentSource.walkIn:
        return 'Walk-in';
      case AppointmentSource.phone:
        return 'Telepon';
      case AppointmentSource.whatsapp:
        return 'WhatsApp';
      case AppointmentSource.online:
        return 'Online';
    }
  }

  String toApiString() {
    switch (this) {
      case AppointmentSource.walkIn:
        return 'walk_in';
      case AppointmentSource.phone:
        return 'phone';
      case AppointmentSource.whatsapp:
        return 'whatsapp';
      case AppointmentSource.online:
        return 'online';
    }
  }

  static AppointmentSource fromString(String value) {
    switch (value) {
      case 'walk_in':
        return AppointmentSource.walkIn;
      case 'phone':
        return AppointmentSource.phone;
      case 'whatsapp':
        return AppointmentSource.whatsapp;
      case 'online':
        return AppointmentSource.online;
      default:
        return AppointmentSource.walkIn;
    }
  }
}

class AppointmentModel {
  final int id;
  final int customerId;
  final int serviceId;
  final int? staffId;
  final int? customerPackageId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final AppointmentStatus status;
  final AppointmentSource source;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final CustomerModel? customer;
  final ServiceModel? service;
  final UserModel? staff;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    this.staffId,
    this.customerPackageId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.source = AppointmentSource.walkIn,
    this.notes,
    this.cancelledAt,
    this.cancelledReason,
    this.customer,
    this.service,
    this.staff,
    required this.createdAt,
  });

  DateTime get startDateTime {
    final parts = startTime.split(':');
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime get endDateTime {
    final parts = endTime.split(':');
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Get formatted start time (HH:mm)
  String get formattedStartTime => _formatTime(startTime);

  /// Get formatted end time (HH:mm)
  String get formattedEndTime => _formatTime(endTime);

  /// Format time string to HH:mm (remove seconds if present)
  static String _formatTime(String time) {
    if (time.isEmpty) return '';
    // If format is HH:mm:ss, trim to HH:mm
    if (time.length >= 5) {
      return time.substring(0, 5);
    }
    return time;
  }

  String get timeRange => '$formattedStartTime - $formattedEndTime';

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get isPast {
    return endDateTime.isBefore(DateTime.now());
  }

  bool get canCancel {
    return status == AppointmentStatus.pending ||
        status == AppointmentStatus.confirmed;
  }

  bool get canStart {
    return status == AppointmentStatus.confirmed && isToday;
  }

  bool get canComplete {
    return status == AppointmentStatus.inProgress;
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      customerId: json['customer_id'],
      serviceId: json['service_id'],
      staffId: json['staff_id'],
      customerPackageId: json['customer_package_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: AppointmentStatus.fromString(json['status'] ?? 'pending'),
      source: AppointmentSource.fromString(json['source'] ?? 'walk_in'),
      notes: json['notes'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      cancelledReason: json['cancelled_reason'],
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'])
          : null,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      staff: json['staff'] != null ? UserModel.fromJson(json['staff']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'service_id': serviceId,
        'staff_id': staffId,
        'customer_package_id': customerPackageId,
        'appointment_date': appointmentDate.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'status': status.toApiString(),
        'source': source.toApiString(),
        'notes': notes,
        'cancelled_at': cancelledAt?.toIso8601String(),
        'cancelled_reason': cancelledReason,
        'created_at': createdAt.toIso8601String(),
      };

  AppointmentModel copyWith({
    int? id,
    int? customerId,
    int? serviceId,
    int? staffId,
    int? customerPackageId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    AppointmentStatus? status,
    AppointmentSource? source,
    String? notes,
    DateTime? cancelledAt,
    String? cancelledReason,
    CustomerModel? customer,
    ServiceModel? service,
    UserModel? staff,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      staffId: staffId ?? this.staffId,
      customerPackageId: customerPackageId ?? this.customerPackageId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      customer: customer ?? this.customer,
      service: service ?? this.service,
      staff: staff ?? this.staff,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({required this.time, this.isAvailable = true});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      isAvailable: json['available'] ?? json['is_available'] ?? true,
    );
  }
}
