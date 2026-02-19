import '../../../data/models/responses/appointment_model.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;
  final AppointmentModel? selectedAppointment;
  final DateTime selectedDate;
  final List<TimeSlot> availableSlots;
  final bool isCreating;
  final bool isUpdating;
  final bool isFetchingSlots;

  AppointmentLoaded({
    required this.appointments,
    this.selectedAppointment,
    required this.selectedDate,
    this.availableSlots = const [],
    this.isCreating = false,
    this.isUpdating = false,
    this.isFetchingSlots = false,
  });

  // Group appointments by status for easier display
  List<AppointmentModel> get pendingAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.pending).toList();

  List<AppointmentModel> get confirmedAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.confirmed).toList();

  List<AppointmentModel> get inProgressAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.inProgress).toList();

  List<AppointmentModel> get completedAppointments =>
      appointments.where((a) => a.status == AppointmentStatus.completed).toList();

  List<AppointmentModel> get activeAppointments => appointments
      .where((a) =>
          a.status == AppointmentStatus.pending ||
          a.status == AppointmentStatus.confirmed ||
          a.status == AppointmentStatus.inProgress)
      .toList();

  AppointmentLoaded copyWith({
    List<AppointmentModel>? appointments,
    AppointmentModel? selectedAppointment,
    DateTime? selectedDate,
    List<TimeSlot>? availableSlots,
    bool? isCreating,
    bool? isUpdating,
    bool? isFetchingSlots,
    bool clearSelected = false,
  }) {
    return AppointmentLoaded(
      appointments: appointments ?? this.appointments,
      selectedAppointment:
          clearSelected ? null : (selectedAppointment ?? this.selectedAppointment),
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isFetchingSlots: isFetchingSlots ?? this.isFetchingSlots,
    );
  }
}

class AppointmentError extends AppointmentState {
  final String message;
  AppointmentError(this.message);
}

class AppointmentCreated extends AppointmentState {
  final AppointmentModel appointment;
  AppointmentCreated(this.appointment);
}

class AppointmentStatusUpdated extends AppointmentState {
  final AppointmentModel appointment;
  AppointmentStatusUpdated(this.appointment);
}

class AvailableSlotsLoaded extends AppointmentState {
  final List<TimeSlot> slots;
  AvailableSlotsLoaded(this.slots);
}
