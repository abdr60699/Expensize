/// Pagination helper for list endpoints
library;

/// Pagination request parameters
class PaginationParams {
  /// Current page number (0-indexed or 1-indexed based on API)
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Sort field
  final String? sortBy;

  /// Sort direction (asc or desc)
  final String? sortDirection;

  /// Search query
  final String? search;

  /// Additional filters
  final Map<String, dynamic>? filters;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortDirection,
    this.search,
    this.filters,
  });

  /// Convert to query parameters map
  Map<String, dynamic> toQueryParams({
    String pageKey = 'page',
    String pageSizeKey = 'pageSize',
    String sortByKey = 'sortBy',
    String sortDirectionKey = 'sortDirection',
    String searchKey = 'search',
  }) {
    final params = <String, dynamic>{
      pageKey: page,
      pageSizeKey: pageSize,
    };

    if (sortBy != null) {
      params[sortByKey] = sortBy;
    }

    if (sortDirection != null) {
      params[sortDirectionKey] = sortDirection;
    }

    if (search != null && search!.isNotEmpty) {
      params[searchKey] = search;
    }

    if (filters != null) {
      params.addAll(filters!);
    }

    return params;
  }

  /// Create copy with modifications
  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortDirection,
    String? search,
    Map<String, dynamic>? filters,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      search: search ?? this.search,
      filters: filters ?? this.filters,
    );
  }

  /// Create params for next page
  PaginationParams nextPage() {
    return copyWith(page: page + 1);
  }

  /// Create params for previous page
  PaginationParams previousPage() {
    return copyWith(page: page > 1 ? page - 1 : 1);
  }

  /// Reset to first page
  PaginationParams resetToFirstPage() {
    return copyWith(page: 1);
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  /// List of items
  final List<T> items;

  /// Current page number
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Total number of items
  final int totalItems;

  /// Number of items per page
  final int pageSize;

  /// Whether there's a next page
  final bool hasNext;

  /// Whether there's a previous page
  final bool hasPrevious;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Create from API response
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson, {
    String itemsKey = 'items',
    String currentPageKey = 'currentPage',
    String totalPagesKey = 'totalPages',
    String totalItemsKey = 'totalItems',
    String pageSizeKey = 'pageSize',
  }) {
    final itemsList = json[itemsKey] as List;
    final items = itemsList
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    final currentPage = json[currentPageKey] as int;
    final totalPages = json[totalPagesKey] as int;
    final totalItems = json[totalItemsKey] as int;
    final pageSize = json[pageSizeKey] as int;

    return PaginatedResponse<T>(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      pageSize: pageSize,
      hasNext: currentPage < totalPages,
      hasPrevious: currentPage > 1,
    );
  }

  /// Create from alternative API response format
  factory PaginatedResponse.fromMeta(
    List<T> items,
    Map<String, dynamic> meta, {
    String currentPageKey = 'current_page',
    String totalPagesKey = 'total_pages',
    String totalItemsKey = 'total',
    String pageSizeKey = 'per_page',
  }) {
    final currentPage = meta[currentPageKey] as int;
    final totalPages = meta[totalPagesKey] as int;
    final totalItems = meta[totalItemsKey] as int;
    final pageSize = meta[pageSizeKey] as int;

    return PaginatedResponse<T>(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      pageSize: pageSize,
      hasNext: currentPage < totalPages,
      hasPrevious: currentPage > 1,
    );
  }

  /// Whether this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Whether this is the last page
  bool get isLastPage => currentPage == totalPages;

  /// Whether the list is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the list is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Number of items in current page
  int get itemCount => items.length;

  @override
  String toString() {
    return 'PaginatedResponse(items: ${items.length}, page: $currentPage/$totalPages, total: $totalItems)';
  }
}

/// Pagination controller for managing paginated lists
class PaginationController<T> {
  /// Current pagination params
  PaginationParams params;

  /// All loaded items (across all pages)
  final List<T> allItems = [];

  /// Whether currently loading
  bool isLoading = false;

  /// Whether there's an error
  bool hasError = false;

  /// Error message
  String? errorMessage;

  /// Last response metadata
  PaginatedResponse<T>? lastResponse;

  /// Callback to fetch data
  final Future<PaginatedResponse<T>> Function(PaginationParams) fetchData;

  PaginationController({
    required this.fetchData,
    PaginationParams? initialParams,
  }) : params = initialParams ?? const PaginationParams();

  /// Load first page
  Future<void> loadFirstPage() async {
    params = params.resetToFirstPage();
    allItems.clear();
    await loadNextPage();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (isLoading) return;
    if (lastResponse != null && !lastResponse!.hasNext) return;

    isLoading = true;
    hasError = false;
    errorMessage = null;

    try {
      final response = await fetchData(params);
      lastResponse = response;
      allItems.addAll(response.items);
      params = params.nextPage();
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Refresh (reload from first page)
  Future<void> refresh() async {
    await loadFirstPage();
  }

  /// Update search query and reload
  Future<void> search(String query) async {
    params = params.copyWith(search: query);
    await loadFirstPage();
  }

  /// Update sort and reload
  Future<void> sort(String sortBy, {String sortDirection = 'asc'}) async {
    params = params.copyWith(
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
    await loadFirstPage();
  }

  /// Update filters and reload
  Future<void> filter(Map<String, dynamic> filters) async {
    params = params.copyWith(filters: filters);
    await loadFirstPage();
  }

  /// Whether has more pages to load
  bool get hasMore => lastResponse?.hasNext ?? true;

  /// Whether list is empty
  bool get isEmpty => allItems.isEmpty && !isLoading;

  /// Total items count
  int get totalCount => lastResponse?.totalItems ?? 0;
}
