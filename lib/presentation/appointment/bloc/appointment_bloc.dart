import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/appointment_remote_datasource.dart';
import '../../../data/models/requests/appointment_request_model.dart';
import '../../../data/models/responses/appointment_model.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRemoteDatasource _datasource;
  List<AppointmentModel> _allAppointments = [];

  AppointmentBloc()
      : _datasource = AppointmentRemoteDatasource(),
        super(AppointmentInitial()) {
    on<FetchAppointments>(_onFetchAppointments);
    on<FetchAppointmentsByDate>(_onFetchAppointmentsByDate);
    on<RefreshAppointments>(_onRefreshAppointments);
    on<SelectAppointment>(_onSelectAppointment);
    on<ClearSelectedAppointment>(_onClearSelectedAppointment);
    on<CreateAppointment>(_onCreateAppointment);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<FetchAvailableSlots>(_onFetchAvailableSlots);
  }

  Future<void> _onFetchAppointments(
    FetchAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());

    final date = event.date ?? DateTime.now();
    final result = await _datasource.getAppointments(
      date: date,
      status: event.status,
    );

    result.fold(
      (error) => emit(AppointmentError(error)),
      (appointments) {
        _allAppointments = appointments;
        emit(AppointmentLoaded(
          appointments: appointments,
          selectedDate: date,
        ));
      },
    );
  }

  Future<void> _onFetchAppointmentsByDate(
    FetchAppointmentsByDate event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(currentState.copyWith(selectedDate: event.date));
    }

    final result = await _datasource.getAppointments(date: event.date);

    result.fold(
      (error) => emit(AppointmentError(error)),
      (appointments) {
        _allAppointments = appointments;
        if (state is AppointmentLoaded) {
          final currentState = state as AppointmentLoaded;
          emit(currentState.copyWith(
            appointments: appointments,
            selectedDate: event.date,
            clearSelected: true,
          ));
        } else {
          emit(AppointmentLoaded(
            appointments: appointments,
            selectedDate: event.date,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshAppointments(
    RefreshAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      final result =
          await _datasource.getAppointments(date: currentState.selectedDate);

      result.fold(
        (error) => emit(AppointmentError(error)),
        (appointments) {
          _allAppointments = appointments;
          emit(currentState.copyWith(appointments: appointments));
        },
      );
    }
  }

  void _onSelectAppointment(
    SelectAppointment event,
    Emitter<AppointmentState> emit,
  ) {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      final appointment =
          _allAppointments.where((a) => a.id == event.appointmentId).firstOrNull;

      if (appointment != null) {
        emit(currentState.copyWith(selectedAppointment: appointment));
      }
    }
  }

  void _onClearSelectedAppointment(
    ClearSelectedAppointment event,
    Emitter<AppointmentState> emit,
  ) {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(currentState.copyWith(clearSelected: true));
    }
  }

  Future<void> _onCreateAppointment(
    CreateAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(currentState.copyWith(isCreating: true));

      final result = await _datasource.createAppointment(event.request);

      result.fold(
        (error) {
          emit(currentState.copyWith(isCreating: false));
          emit(AppointmentError(error));
        },
        (newAppointment) {
          _allAppointments.insert(0, newAppointment);

          emit(AppointmentCreated(newAppointment));
          emit(currentState.copyWith(
            appointments: List.from(_allAppointments),
            isCreating: false,
          ));
        },
      );
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(currentState.copyWith(isUpdating: true));

      final request = UpdateAppointmentStatusRequest(
        status: event.newStatus.toApiString(),
        cancelledReason: event.cancelledReason,
      );

      final result = await _datasource.updateStatus(event.appointmentId, request);

      result.fold(
        (error) {
          emit(currentState.copyWith(isUpdating: false));
          emit(AppointmentError(error));
        },
        (updatedAppointment) {
          final index = _allAppointments.indexWhere((a) => a.id == event.appointmentId);
          if (index != -1) {
            _allAppointments[index] = updatedAppointment;
          }

          emit(AppointmentStatusUpdated(updatedAppointment));
          emit(currentState.copyWith(
            appointments: List.from(_allAppointments),
            selectedAppointment: updatedAppointment,
            isUpdating: false,
          ));
        },
      );
    }
  }

  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlots event,
    Emitter<AppointmentState> emit,
  ) async {
    if (state is AppointmentLoaded) {
      final currentState = state as AppointmentLoaded;
      emit(currentState.copyWith(isFetchingSlots: true));

      final result = await _datasource.getAvailableSlots(
        date: event.date,
        serviceId: event.serviceId,
        staffId: event.staffId,
      );

      result.fold(
        (error) => emit(currentState.copyWith(isFetchingSlots: false)),
        (slots) {
          emit(currentState.copyWith(
            availableSlots: slots,
            isFetchingSlots: false,
          ));
        },
      );
    }
  }
}
