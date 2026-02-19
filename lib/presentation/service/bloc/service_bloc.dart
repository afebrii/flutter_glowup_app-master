import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/service_remote_datasource.dart';
import '../../../data/models/responses/service_category_model.dart';
import '../../../data/models/responses/service_model.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRemoteDatasource _datasource;

  List<ServiceCategoryModel> _categories = [];
  List<ServiceModel> _allServices = [];

  ServiceBloc() : _datasource = ServiceRemoteDatasource(), super(ServiceInitial()) {
    on<FetchServices>(_onFetchServices);
    on<FetchServicesByCategory>(_onFetchServicesByCategory);
    on<RefreshServices>(_onRefreshServices);
    on<SearchServices>(_onSearchServices);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchServices(
    FetchServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());

    final categoriesResult = await _datasource.getCategories();
    final servicesResult = await _datasource.getServices();

    categoriesResult.fold(
      (error) => emit(ServiceError(error)),
      (categories) {
        _categories = categories;
        servicesResult.fold(
          (error) => emit(ServiceError(error)),
          (services) {
            _allServices = services;
            emit(ServiceLoaded(
              categories: categories,
              services: services,
              filteredServices: services,
            ));
          },
        );
      },
    );
  }

  Future<void> _onFetchServicesByCategory(
    FetchServicesByCategory event,
    Emitter<ServiceState> emit,
  ) async {
    if (state is ServiceLoaded) {
      final currentState = state as ServiceLoaded;

      final filtered = _allServices
          .where((s) => s.categoryId == event.categoryId)
          .toList();

      emit(currentState.copyWith(
        filteredServices: filtered,
        selectedCategoryId: event.categoryId,
        searchQuery: '',
      ));
    }
  }

  Future<void> _onRefreshServices(
    RefreshServices event,
    Emitter<ServiceState> emit,
  ) async {
    final servicesResult = await _datasource.getServices();

    servicesResult.fold(
      (error) => emit(ServiceError(error)),
      (services) {
        _allServices = services;
        if (state is ServiceLoaded) {
          final currentState = state as ServiceLoaded;
          List<ServiceModel> filtered = services;

          if (currentState.selectedCategoryId != null) {
            filtered = services
                .where((s) => s.categoryId == currentState.selectedCategoryId)
                .toList();
          }

          emit(currentState.copyWith(
            services: services,
            filteredServices: filtered,
          ));
        } else {
          emit(ServiceLoaded(
            categories: _categories,
            services: services,
            filteredServices: services,
          ));
        }
      },
    );
  }

  void _onSearchServices(
    SearchServices event,
    Emitter<ServiceState> emit,
  ) {
    if (state is ServiceLoaded) {
      final currentState = state as ServiceLoaded;
      final query = event.query.toLowerCase();

      List<ServiceModel> baseList = currentState.selectedCategoryId != null
          ? _allServices.where((s) => s.categoryId == currentState.selectedCategoryId).toList()
          : _allServices;

      final filtered = query.isEmpty
          ? baseList
          : baseList.where((s) {
              return s.name.toLowerCase().contains(query) ||
                  (s.description?.toLowerCase().contains(query) ?? false);
            }).toList();

      emit(currentState.copyWith(
        filteredServices: filtered,
        searchQuery: event.query,
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<ServiceState> emit,
  ) {
    if (state is ServiceLoaded) {
      final currentState = state as ServiceLoaded;

      List<ServiceModel> filtered = currentState.selectedCategoryId != null
          ? _allServices.where((s) => s.categoryId == currentState.selectedCategoryId).toList()
          : _allServices;

      emit(currentState.copyWith(
        filteredServices: filtered,
        searchQuery: '',
        clearCategory: true,
      ));
    }
  }
}
