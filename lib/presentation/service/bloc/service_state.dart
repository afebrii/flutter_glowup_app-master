import '../../../data/models/responses/service_category_model.dart';
import '../../../data/models/responses/service_model.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceCategoryModel> categories;
  final List<ServiceModel> services;
  final List<ServiceModel> filteredServices;
  final int? selectedCategoryId;
  final String searchQuery;

  ServiceLoaded({
    required this.categories,
    required this.services,
    required this.filteredServices,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  ServiceLoaded copyWith({
    List<ServiceCategoryModel>? categories,
    List<ServiceModel>? services,
    List<ServiceModel>? filteredServices,
    int? selectedCategoryId,
    String? searchQuery,
    bool clearCategory = false,
  }) {
    return ServiceLoaded(
      categories: categories ?? this.categories,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ServiceError extends ServiceState {
  final String message;
  ServiceError(this.message);
}
