import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/datasources/staff_remote_datasource.dart';
import '../../../data/models/responses/user_model.dart';

// ==================== Events ====================

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class FetchStaff extends StaffEvent {
  final String? role;
  final bool activeOnly;

  const FetchStaff({this.role, this.activeOnly = true});

  @override
  List<Object?> get props => [role, activeOnly];
}

class FetchBeauticians extends StaffEvent {
  final bool activeOnly;

  const FetchBeauticians({this.activeOnly = true});

  @override
  List<Object?> get props => [activeOnly];
}

class SelectStaff extends StaffEvent {
  final UserModel? staff;

  const SelectStaff(this.staff);

  @override
  List<Object?> get props => [staff];
}

class FetchStaffAvailability extends StaffEvent {
  final int staffId;
  final DateTime date;

  const FetchStaffAvailability(this.staffId, this.date);

  @override
  List<Object?> get props => [staffId, date];
}

class ClearStaffSelection extends StaffEvent {
  const ClearStaffSelection();
}

class ClearStaffError extends StaffEvent {
  const ClearStaffError();
}

// ==================== State ====================

class StaffState extends Equatable {
  final List<UserModel> staff;
  final List<UserModel> beauticians;
  final UserModel? selectedStaff;
  final List<Map<String, dynamic>> availability;
  final bool isLoading;
  final bool isLoadingBeauticians;
  final bool isLoadingAvailability;
  final String? error;

  const StaffState({
    this.staff = const [],
    this.beauticians = const [],
    this.selectedStaff,
    this.availability = const [],
    this.isLoading = false,
    this.isLoadingBeauticians = false,
    this.isLoadingAvailability = false,
    this.error,
  });

  StaffState copyWith({
    List<UserModel>? staff,
    List<UserModel>? beauticians,
    UserModel? selectedStaff,
    List<Map<String, dynamic>>? availability,
    bool? isLoading,
    bool? isLoadingBeauticians,
    bool? isLoadingAvailability,
    String? error,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return StaffState(
      staff: staff ?? this.staff,
      beauticians: beauticians ?? this.beauticians,
      selectedStaff:
          clearSelection ? null : (selectedStaff ?? this.selectedStaff),
      availability: availability ?? this.availability,
      isLoading: isLoading ?? this.isLoading,
      isLoadingBeauticians: isLoadingBeauticians ?? this.isLoadingBeauticians,
      isLoadingAvailability:
          isLoadingAvailability ?? this.isLoadingAvailability,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasStaff => staff.isNotEmpty;
  bool get hasBeauticians => beauticians.isNotEmpty;
  bool get hasSelection => selectedStaff != null;

  @override
  List<Object?> get props => [
        staff,
        beauticians,
        selectedStaff,
        availability,
        isLoading,
        isLoadingBeauticians,
        isLoadingAvailability,
        error,
      ];
}

// ==================== BLoC ====================

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRemoteDatasource _staffDatasource;

  StaffBloc({required StaffRemoteDatasource staffDatasource})
      : _staffDatasource = staffDatasource,
        super(const StaffState()) {
    on<FetchStaff>(_onFetchStaff);
    on<FetchBeauticians>(_onFetchBeauticians);
    on<SelectStaff>(_onSelectStaff);
    on<FetchStaffAvailability>(_onFetchAvailability);
    on<ClearStaffSelection>(_onClearSelection);
    on<ClearStaffError>(_onClearError);
  }

  Future<void> _onFetchStaff(
    FetchStaff event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _staffDatasource.getStaff(
      role: event.role,
      activeOnly: event.activeOnly,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (staff) => emit(state.copyWith(isLoading: false, staff: staff)),
    );
  }

  Future<void> _onFetchBeauticians(
    FetchBeauticians event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(isLoadingBeauticians: true, clearError: true));

    final result = await _staffDatasource.getBeauticians(
      activeOnly: event.activeOnly,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingBeauticians: false, error: error)),
      (beauticians) => emit(state.copyWith(
        isLoadingBeauticians: false,
        beauticians: beauticians,
      )),
    );
  }

  void _onSelectStaff(SelectStaff event, Emitter<StaffState> emit) {
    emit(state.copyWith(selectedStaff: event.staff));
  }

  Future<void> _onFetchAvailability(
    FetchStaffAvailability event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(isLoadingAvailability: true, clearError: true));

    final result = await _staffDatasource.getStaffAvailability(
      event.staffId,
      event.date,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingAvailability: false, error: error)),
      (availability) => emit(state.copyWith(
        isLoadingAvailability: false,
        availability: availability,
      )),
    );
  }

  void _onClearSelection(ClearStaffSelection event, Emitter<StaffState> emit) {
    emit(state.copyWith(clearSelection: true));
  }

  void _onClearError(ClearStaffError event, Emitter<StaffState> emit) {
    emit(state.copyWith(clearError: true));
  }
}
