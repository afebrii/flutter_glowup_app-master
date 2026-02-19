import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/treatment_remote_datasource.dart';
import '../../../data/models/responses/treatment_record_model.dart';
import 'treatment_event.dart';
import 'treatment_state.dart';

class TreatmentBloc extends Bloc<TreatmentEvent, TreatmentState> {
  final TreatmentRemoteDatasource _datasource;

  TreatmentBloc({required TreatmentRemoteDatasource datasource})
    : _datasource = datasource,
      super(const TreatmentState()) {
    on<FetchTreatments>(_onFetchTreatments);
    on<FetchTreatmentById>(_onFetchById);
    on<FetchCustomerTreatments>(_onFetchCustomerTreatments);
    on<SelectTreatment>(_onSelect);
    on<ClearTreatmentError>(_onClearError);
    on<ClearTreatmentSuccess>(_onClearSuccess);
    on<CreateTreatment>(_onCreateTreatment);
  }

  Future<void> _onFetchTreatments(
    FetchTreatments event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _datasource.getTreatmentRecords(
      customerId: event.customerId,
      appointmentId: event.appointmentId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (response) {
        final treatments = event.page == 1
            ? response.data
            : [...state.treatments, ...response.data];
        emit(
          state.copyWith(
            isLoading: false,
            treatments: treatments,
            meta: response.meta,
          ),
        );
      },
    );
  }

  Future<void> _onFetchById(
    FetchTreatmentById event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));

    final result = await _datasource.getTreatmentById(event.treatmentId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingDetail: false, error: error)),
      (treatment) => emit(
        state.copyWith(isLoadingDetail: false, selectedTreatment: treatment),
      ),
    );
  }

  Future<void> _onFetchCustomerTreatments(
    FetchCustomerTreatments event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(state.copyWith(isLoadingCustomer: true, clearError: true));

    final result = await _datasource.getCustomerTreatments(
      event.customerId,
      perPage: event.limit,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingCustomer: false, error: error)),
      (treatments) => emit(
        state.copyWith(
          isLoadingCustomer: false,
          customerTreatments: treatments,
        ),
      ),
    );
  }

  void _onSelect(SelectTreatment event, Emitter<TreatmentState> emit) {
    if (event.treatmentId == null) {
      emit(state.copyWith(clearSelection: true));
    } else {
      final treatment = state.treatments
          .where((t) => t.id == event.treatmentId)
          .firstOrNull;
      if (treatment != null) {
        emit(state.copyWith(selectedTreatment: treatment));
      } else {
        add(FetchTreatmentById(event.treatmentId!));
      }
    }
  }

  void _onClearError(ClearTreatmentError event, Emitter<TreatmentState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(
    ClearTreatmentSuccess event,
    Emitter<TreatmentState> emit,
  ) {
    emit(state.copyWith(clearSuccess: true));
  }

  Future<void> _onCreateTreatment(
    CreateTreatment event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearError: true, clearSuccess: true));

    // Check if treatment already exists for this appointment
    final existing = await _datasource.getTreatmentByAppointment(
      event.appointmentId,
    );

    final existingTreatment = existing.fold(
      (_) => null,
      (treatment) => treatment,
    );

    late final Either<String, TreatmentRecordModel> result;

    if (existingTreatment != null) {
      // Update existing treatment
      result = await _datasource.updateTreatment(
        existingTreatment.id,
        notes: event.notes,
        recommendations: event.recommendations,
        followUpDate: event.followUpDate,
        newBeforePhotos: event.beforePhotos,
        newAfterPhotos: event.afterPhotos,
      );
    } else {
      // Create new treatment
      result = await _datasource.createTreatment(
        appointmentId: event.appointmentId,
        customerId: event.customerId,
        notes: event.notes,
        recommendations: event.recommendations,
        followUpDate: event.followUpDate,
        beforePhotos: event.beforePhotos,
        afterPhotos: event.afterPhotos,
        productsUsed: event.productsUsed,
      );
    }

    result.fold(
      (error) => emit(state.copyWith(isCreating: false, error: error)),
      (treatment) => emit(
        state.copyWith(
          isCreating: false,
          successMessage: existingTreatment != null
              ? 'Treatment record berhasil diperbarui'
              : 'Treatment record berhasil disimpan',
          treatments: existingTreatment != null
              ? state.treatments
                  .map((t) => t.id == treatment.id ? treatment : t)
                  .toList()
              : [treatment, ...state.treatments],
        ),
      ),
    );
  }
}
