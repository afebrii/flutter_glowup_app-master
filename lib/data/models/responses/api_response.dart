/// Generic API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;

  ApiResponse({this.data, this.message, this.errors});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(
              json['errors'].map((k, v) => MapEntry(k, List<String>.from(v))))
          : null,
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstValue = errors!.values.first;
    return firstValue.isNotEmpty ? firstValue.first : null;
  }
}

/// Paginated Response wrapper for list endpoints
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.meta});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'],
      to: json['to'],
    );
  }

  bool get hasMore => currentPage < lastPage;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage >= lastPage;
  int get nextPage => hasMore ? currentPage + 1 : currentPage;
  int get previousPage => currentPage > 1 ? currentPage - 1 : 1;
}
