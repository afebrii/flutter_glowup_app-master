import 'package:equatable/equatable.dart';
import '../../../data/models/responses/api_response.dart';
import '../../../data/models/responses/package_model.dart';

class PackageState extends Equatable {
  final List<PackageModel> packages;
  final List<CustomerPackageModel> customerPackages;
  final PackageModel? selectedPackage;
  final CustomerPackageModel? selectedCustomerPackage;
  final List<CustomerPackageModel> usablePackages;
  final PaginationMeta? customerPackagesMeta;
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isLoadingCustomerPackages;
  final bool isSelling;
  final bool isUsingSession;
  final bool isLoadingUsable;
  final String? error;
  final String? successMessage;

  const PackageState({
    this.packages = const [],
    this.customerPackages = const [],
    this.selectedPackage,
    this.selectedCustomerPackage,
    this.usablePackages = const [],
    this.customerPackagesMeta,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isLoadingCustomerPackages = false,
    this.isSelling = false,
    this.isUsingSession = false,
    this.isLoadingUsable = false,
    this.error,
    this.successMessage,
  });

  PackageState copyWith({
    List<PackageModel>? packages,
    List<CustomerPackageModel>? customerPackages,
    PackageModel? selectedPackage,
    CustomerPackageModel? selectedCustomerPackage,
    List<CustomerPackageModel>? usablePackages,
    PaginationMeta? customerPackagesMeta,
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isLoadingCustomerPackages,
    bool? isSelling,
    bool? isUsingSession,
    bool? isLoadingUsable,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
    bool clearSelectedCustomerPackage = false,
  }) {
    return PackageState(
      packages: packages ?? this.packages,
      customerPackages: customerPackages ?? this.customerPackages,
      selectedPackage:
          clearSelected ? null : (selectedPackage ?? this.selectedPackage),
      selectedCustomerPackage: clearSelectedCustomerPackage
          ? null
          : (selectedCustomerPackage ?? this.selectedCustomerPackage),
      usablePackages: usablePackages ?? this.usablePackages,
      customerPackagesMeta: customerPackagesMeta ?? this.customerPackagesMeta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isLoadingCustomerPackages:
          isLoadingCustomerPackages ?? this.isLoadingCustomerPackages,
      isSelling: isSelling ?? this.isSelling,
      isUsingSession: isUsingSession ?? this.isUsingSession,
      isLoadingUsable: isLoadingUsable ?? this.isLoadingUsable,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get hasMoreCustomerPackages => customerPackagesMeta?.hasMore ?? false;

  @override
  List<Object?> get props => [
        packages,
        customerPackages,
        selectedPackage,
        selectedCustomerPackage,
        usablePackages,
        customerPackagesMeta,
        isLoading,
        isLoadingDetail,
        isLoadingCustomerPackages,
        isSelling,
        isUsingSession,
        isLoadingUsable,
        error,
        successMessage,
      ];
}
