abstract class ServiceEvent {}

class FetchServices extends ServiceEvent {}

class FetchServicesByCategory extends ServiceEvent {
  final int categoryId;
  FetchServicesByCategory(this.categoryId);
}

class RefreshServices extends ServiceEvent {}

class SearchServices extends ServiceEvent {
  final String query;
  SearchServices(this.query);
}

class ClearSearch extends ServiceEvent {}
