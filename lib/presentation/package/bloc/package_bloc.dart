import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/package_remote_datasource.dart';
import 'package_event.dart';
import 'package_state.dart';

class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final PackageRemoteDatasource _datasource;

  PackageBloc({required PackageRemoteDatasource datasource})
      : _datasource = datasource,
        super(const PackageState()) {
    on<FetchPackages>(_onFetchPackages);
    on<FetchPackageById>(_onFetchById);
    on<FetchCustomerPackages>(_onFetchCustomerPackages);
    on<SellPackage>(_onSellPackage);
    on<UsePackageSession>(_onUseSession);
    on<FetchUsablePackages>(_onFetchUsable);
    on<SelectCustomerPackage>(_onSelectCustomerPackage);
    on<ClearPackageError>(_onClearError);
    on<ClearPackageSuccess>(_onClearSuccess);
  }

  Future<void> _onFetchPackages(
    FetchPackages event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _datasource.getPackages(
      serviceId: event.serviceId,
      activeOnly: event.activeOnly,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (packages) =>
          emit(state.copyWith(isLoading: false, packages: packages)),
    );
  }

  Future<void> _onFetchById(
    FetchPackageById event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));

    final result = await _datasource.getPackageById(event.packageId);

    result.fold(
      (error) => emit(state.copyWith(isLoadingDetail: false, error: error)),
      (package) => emit(state.copyWith(
        isLoadingDetail: false,
        selectedPackage: package,
      )),
    );
  }

  Future<void> _onFetchCustomerPackages(
    FetchCustomerPackages event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(isLoadingCustomerPackages: true, clearError: true));

    final result = await _datasource.getCustomerPackages(
      customerId: event.customerId,
      status: event.status,
      usableOnly: event.usableOnly,
      page: event.page,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingCustomerPackages: false, error: error)),
      (response) {
        final packages = event.page == 1
            ? response.data
            : [...state.customerPackages, ...response.data];
        emit(state.copyWith(
          isLoadingCustomerPackages: false,
          customerPackages: packages,
          customerPackagesMeta: response.meta,
        ));
      },
    );
  }

  Future<void> _onSellPackage(
    SellPackage event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(
        isSelling: true, clearError: true, clearSuccess: true));

    final result = await _datasource.sellPackage(
      customerId: event.customerId,
      packageId: event.packageId,
      pricePaid: event.pricePaid,
      notes: event.notes,
    );

    result.fold(
      (error) => emit(state.copyWith(isSelling: false, error: error)),
      (customerPackage) => emit(state.copyWith(
        isSelling: false,
        customerPackages: [...state.customerPackages, customerPackage],
        successMessage: 'Paket berhasil dijual!',
      )),
    );
  }

  Future<void> _onUseSession(
    UsePackageSession event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(
        isUsingSession: true, clearError: true, clearSuccess: true));

    final result = await _datasource.useSession(
      event.customerPackageId,
      appointmentId: event.appointmentId,
      notes: event.notes,
    );

    result.fold(
      (error) => emit(state.copyWith(isUsingSession: false, error: error)),
      (updated) {
        final updatedList = state.customerPackages.map((p) {
          return p.id == event.customerPackageId ? updated : p;
        }).toList();
        emit(state.copyWith(
          isUsingSession: false,
          customerPackages: updatedList,
          selectedCustomerPackage:
              state.selectedCustomerPackage?.id == event.customerPackageId
                  ? updated
                  : null,
          successMessage: 'Sesi berhasil digunakan!',
        ));
      },
    );
  }

  Future<void> _onFetchUsable(
    FetchUsablePackages event,
    Emitter<PackageState> emit,
  ) async {
    emit(state.copyWith(isLoadingUsable: true, clearError: true));

    final result = await _datasource.getUsablePackagesForService(
      event.customerId,
      event.serviceId,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingUsable: false, error: error)),
      (packages) =>
          emit(state.copyWith(isLoadingUsable: false, usablePackages: packages)),
    );
  }

  void _onSelectCustomerPackage(
    SelectCustomerPackage event,
    Emitter<PackageState> emit,
  ) {
    if (event.customerPackageId == null) {
      emit(state.copyWith(clearSelectedCustomerPackage: true));
      return;
    }
    final found = state.customerPackages
        .where((p) => p.id == event.customerPackageId)
        .firstOrNull;
    if (found != null) {
      emit(state.copyWith(selectedCustomerPackage: found));
    }
  }

  void _onClearError(ClearPackageError event, Emitter<PackageState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(ClearPackageSuccess event, Emitter<PackageState> emit) {
    emit(state.copyWith(clearSuccess: true));
  }
}
