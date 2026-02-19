import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/referral_remote_datasource.dart';
import 'referral_event.dart';
import 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ReferralRemoteDatasource _referralDatasource;

  ReferralBloc({required ReferralRemoteDatasource referralDatasource})
      : _referralDatasource = referralDatasource,
        super(const ReferralState()) {
    on<FetchReferralInfo>(_onFetchInfo);
    on<FetchReferralHistory>(_onFetchHistory);
    on<FetchReferredCustomers>(_onFetchReferred);
    on<ValidateReferralCode>(_onValidate);
    on<ApplyReferralCode>(_onApply);
    on<FetchProgramInfo>(_onFetchProgram);
    on<ClearReferralError>(_onClearError);
    on<ClearReferralSuccess>(_onClearSuccess);
    on<ClearValidation>(_onClearValidation);
  }

  Future<void> _onFetchInfo(
    FetchReferralInfo event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingInfo: true, clearError: true));

    final result =
        await _referralDatasource.getCustomerReferral(event.customerId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingInfo: false, error: error)),
      (info) => emit(state.copyWith(isLoadingInfo: false, referralInfo: info)),
    );
  }

  Future<void> _onFetchHistory(
    FetchReferralHistory event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true, clearError: true));

    final result = await _referralDatasource.getReferralHistory(
      event.customerId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingHistory: false, error: error)),
      (response) {
        final history = event.page == 1
            ? response.data
            : [...state.history, ...response.data];
        emit(state.copyWith(
          isLoadingHistory: false,
          history: history,
          historyMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onFetchReferred(
    FetchReferredCustomers event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingReferred: true, clearError: true));

    final result = await _referralDatasource.getReferredCustomers(
      event.customerId,
      page: event.page,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingReferred: false, error: error)),
      (response) {
        final customers = event.page == 1
            ? response.data
            : [...state.referredCustomers, ...response.data];
        emit(state.copyWith(
          isLoadingReferred: false,
          referredCustomers: customers,
          referredMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onValidate(
    ValidateReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(
        isValidating: true, clearError: true, clearValidation: true));

    final result = await _referralDatasource.validateCode(event.code);

    result.fold(
      (error) => emit(state.copyWith(isValidating: false, error: error)),
      (data) =>
          emit(state.copyWith(isValidating: false, validationResult: data)),
    );
  }

  Future<void> _onApply(
    ApplyReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(
        isApplying: true, clearError: true, clearSuccess: true));

    final result = await _referralDatasource.applyReferralCode(
      event.customerId,
      event.code,
    );

    result.fold(
      (error) => emit(state.copyWith(isApplying: false, error: error)),
      (data) => emit(state.copyWith(
        isApplying: false,
        successMessage: 'Kode referral berhasil diterapkan!',
      )),
    );
  }

  Future<void> _onFetchProgram(
    FetchProgramInfo event,
    Emitter<ReferralState> emit,
  ) async {
    emit(state.copyWith(isLoadingProgram: true, clearError: true));

    final result = await _referralDatasource.getProgramInfo();

    result.fold(
      (error) => emit(state.copyWith(isLoadingProgram: false, error: error)),
      (info) =>
          emit(state.copyWith(isLoadingProgram: false, programInfo: info)),
    );
  }

  void _onClearError(ClearReferralError event, Emitter<ReferralState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(ClearReferralSuccess event, Emitter<ReferralState> emit) {
    emit(state.copyWith(clearSuccess: true));
  }

  void _onClearValidation(ClearValidation event, Emitter<ReferralState> emit) {
    emit(state.copyWith(clearValidation: true));
  }
}
