import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/treatment_record_model.dart';

class TreatmentState extends Equatable {
  final List<TreatmentRecordModel> treatments;
  final TreatmentRecordModel? selectedTreatment;
  final List<TreatmentRecordModel> customerTreatments;
  final PaginationMeta? meta;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isLoadingCustomer;
  final bool isCreating;
  final String? error;
  final String? successMessage;

  const TreatmentState({
    this.treatments = const [],
    this.selectedTreatment,
    this.customerTreatments = const [],
    this.meta,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isLoadingCustomer = false,
    this.isCreating = false,
    this.error,
    this.successMessage,
  });

  TreatmentState copyWith({
    List<TreatmentRecordModel>? treatments,
    TreatmentRecordModel? selectedTreatment,
    List<TreatmentRecordModel>? customerTreatments,
    PaginationMeta? meta,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isLoadingCustomer,
    bool? isCreating,
    String? error,
    String? successMessage,
    bool clearSelection = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TreatmentState(
      treatments: treatments ?? this.treatments,
      selectedTreatment: clearSelection
          ? null
          : (selectedTreatment ?? this.selectedTreatment),
      customerTreatments: customerTreatments ?? this.customerTreatments,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingCustomer: isLoadingCustomer ?? this.isLoadingCustomer,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get hasTreatments => treatments.isNotEmpty;
  bool get hasSelection => selectedTreatment != null;
  bool get hasMore => meta?.hasMore ?? false;

  @override
  List<Object?> get props => [
        treatments,
        selectedTreatment,
        customerTreatments,
        meta,
        isLoading,
        isLoadingDetail,
        isLoadingCustomer,
        isCreating,
        error,
        successMessage,
      ];
}
