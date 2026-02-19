import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/datasources/settings_remote_datasource.dart';
import '../../../data/models/responses/settings_model.dart';

// ==================== Events ====================

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchSettings extends SettingsEvent {
  const FetchSettings();
}

class FetchBranding extends SettingsEvent {
  const FetchBranding();
}

class FetchOperatingHours extends SettingsEvent {
  const FetchOperatingHours();
}

class FetchLoyaltyConfig extends SettingsEvent {
  const FetchLoyaltyConfig();
}

class UpdateClinicInfo extends SettingsEvent {
  final Map<String, dynamic> clinicData;
  const UpdateClinicInfo(this.clinicData);

  @override
  List<Object?> get props => [clinicData];
}

class UpdateOperatingHours extends SettingsEvent {
  final List<Map<String, dynamic>> hoursData;
  const UpdateOperatingHours(this.hoursData);

  @override
  List<Object?> get props => [hoursData];
}

class ClearSettingsError extends SettingsEvent {
  const ClearSettingsError();
}

// ==================== State ====================

class SettingsState extends Equatable {
  final SettingsModel? settings;
  final BrandingInfo? branding;
  final List<OperatingHourModel> operatingHours;
  final LoyaltyConfig? loyaltyConfig;
  final bool isLoading;
  final bool isLoadingBranding;
  final bool isLoadingHours;
  final bool isLoadingLoyalty;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const SettingsState({
    this.settings,
    this.branding,
    this.operatingHours = const [],
    this.loyaltyConfig,
    this.isLoading = false,
    this.isLoadingBranding = false,
    this.isLoadingHours = false,
    this.isLoadingLoyalty = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  SettingsState copyWith({
    SettingsModel? settings,
    BrandingInfo? branding,
    List<OperatingHourModel>? operatingHours,
    LoyaltyConfig? loyaltyConfig,
    bool? isLoading,
    bool? isLoadingBranding,
    bool? isLoadingHours,
    bool? isLoadingLoyalty,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      branding: branding ?? this.branding,
      operatingHours: operatingHours ?? this.operatingHours,
      loyaltyConfig: loyaltyConfig ?? this.loyaltyConfig,
      isLoading: isLoading ?? this.isLoading,
      isLoadingBranding: isLoadingBranding ?? this.isLoadingBranding,
      isLoadingHours: isLoadingHours ?? this.isLoadingHours,
      isLoadingLoyalty: isLoadingLoyalty ?? this.isLoadingLoyalty,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool hasFeature(String feature) => settings?.hasFeature(feature) ?? false;

  bool get hasProducts => hasFeature('products');
  bool get hasTreatmentRecords => hasFeature('treatment_records');
  bool get hasPackages => hasFeature('packages');
  bool get hasLoyalty => hasFeature('loyalty');
  bool get hasOnlineBooking => hasFeature('online_booking');

  String? get clinicName => settings?.clinic.name;
  String? get clinicPhone => settings?.clinic.phone;
  String? get clinicAddress => settings?.clinic.fullAddress;

  @override
  List<Object?> get props => [
        settings,
        branding,
        operatingHours,
        loyaltyConfig,
        isLoading,
        isLoadingBranding,
        isLoadingHours,
        isLoadingLoyalty,
        isSaving,
        error,
        successMessage,
      ];
}

// ==================== BLoC ====================

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRemoteDatasource _settingsDatasource;

  SettingsBloc({required SettingsRemoteDatasource settingsDatasource})
      : _settingsDatasource = settingsDatasource,
        super(const SettingsState()) {
    on<FetchSettings>(_onFetchSettings);
    on<FetchBranding>(_onFetchBranding);
    on<FetchOperatingHours>(_onFetchOperatingHours);
    on<FetchLoyaltyConfig>(_onFetchLoyaltyConfig);
    on<UpdateClinicInfo>(_onUpdateClinicInfo);
    on<UpdateOperatingHours>(_onUpdateOperatingHours);
    on<ClearSettingsError>(_onClearError);
  }

  Future<void> _onFetchSettings(
    FetchSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _settingsDatasource.getSettings();

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (settings) => emit(state.copyWith(
        isLoading: false,
        settings: settings,
        operatingHours: settings.operatingHours,
      )),
    );
  }

  Future<void> _onFetchBranding(
    FetchBranding event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingBranding: true, clearError: true));

    final result = await _settingsDatasource.getBranding();

    result.fold(
      (error) => emit(state.copyWith(isLoadingBranding: false, error: error)),
      (branding) =>
          emit(state.copyWith(isLoadingBranding: false, branding: branding)),
    );
  }

  Future<void> _onFetchOperatingHours(
    FetchOperatingHours event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingHours: true, clearError: true));

    final result = await _settingsDatasource.getOperatingHours();

    result.fold(
      (error) => emit(state.copyWith(isLoadingHours: false, error: error)),
      (hours) =>
          emit(state.copyWith(isLoadingHours: false, operatingHours: hours)),
    );
  }

  Future<void> _onFetchLoyaltyConfig(
    FetchLoyaltyConfig event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingLoyalty: true, clearError: true));

    final result = await _settingsDatasource.getLoyaltyConfig();

    result.fold(
      (error) => emit(state.copyWith(isLoadingLoyalty: false, error: error)),
      (config) =>
          emit(state.copyWith(isLoadingLoyalty: false, loyaltyConfig: config)),
    );
  }

  Future<void> _onUpdateClinicInfo(
    UpdateClinicInfo event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await _settingsDatasource.updateClinicInfo(event.clinicData);

    result.fold(
      (error) => emit(state.copyWith(isSaving: false, error: error)),
      (settings) => emit(state.copyWith(
        isSaving: false,
        settings: settings,
        operatingHours: settings.operatingHours,
        successMessage: 'Profil klinik berhasil diperbarui',
      )),
    );
  }

  Future<void> _onUpdateOperatingHours(
    UpdateOperatingHours event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    final result = await _settingsDatasource.updateOperatingHours(event.hoursData);

    result.fold(
      (error) => emit(state.copyWith(isSaving: false, error: error)),
      (hours) => emit(state.copyWith(
        isSaving: false,
        operatingHours: hours,
        successMessage: 'Jam operasional berhasil diperbarui',
      )),
    );
  }

  void _onClearError(ClearSettingsError event, Emitter<SettingsState> emit) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
