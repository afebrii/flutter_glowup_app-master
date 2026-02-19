import '../../../data/models/requests/appointment_request_model.dart';
import '../../../data/models/responses/appointment_model.dart';

abstract class AppointmentEvent {}

class FetchAppointments extends AppointmentEvent {
  final DateTime? date;
  final String? status;
  FetchAppointments({this.date, this.status});
}

class FetchAppointmentsByDate extends AppointmentEvent {
  final DateTime date;
  FetchAppointmentsByDate(this.date);
}

class RefreshAppointments extends AppointmentEvent {}

class SelectAppointment extends AppointmentEvent {
  final int appointmentId;
  SelectAppointment(this.appointmentId);
}

class ClearSelectedAppointment extends AppointmentEvent {}

class CreateAppointment extends AppointmentEvent {
  final AppointmentRequestModel request;
  CreateAppointment(this.request);
}

class UpdateAppointmentStatus extends AppointmentEvent {
  final int appointmentId;
  final AppointmentStatus newStatus;
  final String? cancelledReason;
  UpdateAppointmentStatus(this.appointmentId, this.newStatus, {this.cancelledReason});
}

class FetchAvailableSlots extends AppointmentEvent {
  final DateTime date;
  final int serviceId;
  final int? staffId;
  FetchAvailableSlots({required this.date, required this.serviceId, this.staffId});
}
