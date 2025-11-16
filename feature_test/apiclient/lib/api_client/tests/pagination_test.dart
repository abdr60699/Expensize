/// Tests for pagination utilities
library;

import 'package:flutter_test/flutter_test.dart';
import '../utils/pagination.dart';

void main() {
  group('PaginationParams', () {
    test('creates with default values', () {
      const params = PaginationParams();

      expect(params.page, 1);
      expect(params.pageSize, 20);
      expect(params.sortBy, null);
      expect(params.sortDirection, null);
      expect(params.search, null);
      expect(params.filters, null);
    });

    test('toQueryParams converts correctly', () {
      const params = PaginationParams(
        page: 2,
        pageSize: 10,
        sortBy: 'name',
        sortDirection: 'asc',
        search: 'test',
      );

      final queryParams = params.toQueryParams();

      expect(queryParams['page'], 2);
      expect(queryParams['pageSize'], 10);
      expect(queryParams['sortBy'], 'name');
      expect(queryParams['sortDirection'], 'asc');
      expect(queryParams['search'], 'test');
    });

    test('nextPage increments page number', () {
      const params = PaginationParams(page: 1);
      final nextParams = params.nextPage();

      expect(nextParams.page, 2);
    });

    test('previousPage decrements page number', () {
      const params = PaginationParams(page: 3);
      final prevParams = params.previousPage();

      expect(prevParams.page, 2);
    });

    test('previousPage does not go below 1', () {
      const params = PaginationParams(page: 1);
      final prevParams = params.previousPage();

      expect(prevParams.page, 1);
    });

    test('resetToFirstPage sets page to 1', () {
      const params = PaginationParams(page: 5);
      final resetParams = params.resetToFirstPage();

      expect(resetParams.page, 1);
    });
  });

  group('PaginatedResponse', () {
    test('creates from JSON correctly', () {
      final json = {
        'items': [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
        'currentPage': 1,
        'totalPages': 5,
        'totalItems': 100,
        'pageSize': 20,
      };

      final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
        json,
        (item) => item,
      );

      expect(response.items.length, 2);
      expect(response.currentPage, 1);
      expect(response.totalPages, 5);
      expect(response.totalItems, 100);
      expect(response.pageSize, 20);
      expect(response.hasNext, true);
      expect(response.hasPrevious, false);
    });

    test('creates from meta correctly', () {
      final items = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ];

      final meta = {
        'current_page': 2,
        'total_pages': 5,
        'total': 100,
        'per_page': 20,
      };

      final response = PaginatedResponse<Map<String, dynamic>>.fromMeta(
        items,
        meta,
      );

      expect(response.items.length, 2);
      expect(response.currentPage, 2);
      expect(response.totalPages, 5);
      expect(response.totalItems, 100);
      expect(response.hasNext, true);
      expect(response.hasPrevious, true);
    });

    test('isFirstPage returns true for page 1', () {
      final response = PaginatedResponse<String>(
        items: const ['item1'],
        currentPage: 1,
        totalPages: 5,
        totalItems: 50,
        pageSize: 10,
        hasNext: true,
        hasPrevious: false,
      );

      expect(response.isFirstPage, true);
    });

    test('isLastPage returns true for last page', () {
      final response = PaginatedResponse<String>(
        items: const ['item1'],
        currentPage: 5,
        totalPages: 5,
        totalItems: 50,
        pageSize: 10,
        hasNext: false,
        hasPrevious: true,
      );

      expect(response.isLastPage, true);
    });

    test('isEmpty returns true for empty list', () {
      final response = PaginatedResponse<String>(
        items: const [],
        currentPage: 1,
        totalPages: 0,
        totalItems: 0,
        pageSize: 10,
        hasNext: false,
        hasPrevious: false,
      );

      expect(response.isEmpty, true);
      expect(response.isNotEmpty, false);
    });
  });

  group('PaginationController', () {
    test('initializes with default params', () {
      final controller = PaginationController<String>(
        fetchData: (params) async {
          return PaginatedResponse<String>(
            items: const ['item1', 'item2'],
            currentPage: params.page,
            totalPages: 5,
            totalItems: 50,
            pageSize: params.pageSize,
            hasNext: true,
            hasPrevious: false,
          );
        },
      );

      expect(controller.params.page, 1);
      expect(controller.params.pageSize, 20);
      expect(controller.allItems, isEmpty);
    });

    test('loadFirstPage loads data', () async {
      final controller = PaginationController<String>(
        fetchData: (params) async {
          return PaginatedResponse<String>(
            items: const ['item1', 'item2'],
            currentPage: params.page,
            totalPages: 5,
            totalItems: 50,
            pageSize: params.pageSize,
            hasNext: true,
            hasPrevious: false,
          );
        },
      );

      await controller.loadFirstPage();

      expect(controller.allItems.length, 2);
      expect(controller.allItems, contains('item1'));
      expect(controller.allItems, contains('item2'));
      expect(controller.hasMore, true);
    });

    test('loadNextPage appends data', () async {
      var callCount = 0;

      final controller = PaginationController<String>(
        fetchData: (params) async {
          callCount++;
          final isFirstPage = callCount == 1;

          return PaginatedResponse<String>(
            items: isFirstPage
                ? const ['item1', 'item2']
                : const ['item3', 'item4'],
            currentPage: params.page,
            totalPages: 5,
            totalItems: 50,
            pageSize: params.pageSize,
            hasNext: true,
            hasPrevious: isFirstPage ? false : true,
          );
        },
      );

      await controller.loadFirstPage();
      await controller.loadNextPage();

      expect(controller.allItems.length, 4);
      expect(controller.allItems, containsAll(['item1', 'item2', 'item3', 'item4']));
    });

    test('search updates params and reloads', () async {
      final controller = PaginationController<String>(
        fetchData: (params) async {
          return PaginatedResponse<String>(
            items: params.search == 'test'
                ? const ['filtered1', 'filtered2']
                : const ['item1', 'item2'],
            currentPage: 1,
            totalPages: 1,
            totalItems: 2,
            pageSize: 20,
            hasNext: false,
            hasPrevious: false,
          );
        },
      );

      await controller.loadFirstPage();
      expect(controller.allItems.length, 2);

      await controller.search('test');
      expect(controller.allItems.length, 2);
      expect(controller.allItems, contains('filtered1'));
    });

    test('filter updates params and reloads', () async {
      final controller = PaginationController<String>(
        fetchData: (params) async {
          final hasFilter = params.filters?['status'] == 'active';

          return PaginatedResponse<String>(
            items: hasFilter
                ? const ['active1', 'active2']
                : const ['all1', 'all2'],
            currentPage: 1,
            totalPages: 1,
            totalItems: 2,
            pageSize: 20,
            hasNext: false,
            hasPrevious: false,
          );
        },
      );

      await controller.loadFirstPage();
      expect(controller.allItems, contains('all1'));

      await controller.filter({'status': 'active'});
      expect(controller.allItems, contains('active1'));
    });
  });
}
