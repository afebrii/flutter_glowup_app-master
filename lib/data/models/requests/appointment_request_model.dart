class AppointmentRequestModel {
  final int customerId;
  final int serviceId;
  final int? staffId;
  final int? customerPackageId;
  final String appointmentDate;
  final String startTime;
  final String? notes;
  final String source;

  AppointmentRequestModel({
    required this.customerId,
    required this.serviceId,
    this.staffId,
    this.customerPackageId,
    required this.appointmentDate,
    required this.startTime,
    this.notes,
    this.source = 'walk_in',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'service_id': serviceId,
      'appointment_date': appointmentDate,
      'start_time': startTime,
      'source': source,
    };

    if (staffId != null) map['staff_id'] = staffId;
    if (customerPackageId != null) map['customer_package_id'] = customerPackageId;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;

    return map;
  }
}

class UpdateAppointmentStatusRequest {
  final String status;
  final String? cancelledReason;

  UpdateAppointmentStatusRequest({
    required this.status,
    this.cancelledReason,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'status': status};
    if (cancelledReason != null) map['cancelled_reason'] = cancelledReason;
    return map;
  }
}
