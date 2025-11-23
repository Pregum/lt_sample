import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/ui_state.dart';
import '../services/mock_data_service.dart';

final searchProvider =
    StateNotifierProvider<SearchNotifier, UIStateData<List<Product>>>(
  (ref) => SearchNotifier(),
);

class SearchNotifier extends StateNotifier<UIStateData<List<Product>>> {
  SearchNotifier()
      : super(const UIStateData(
          state: UIState.empty,
          data: [],
        ));

  List<Product> _allProducts = [];
  String _lastQuery = '';

  Future<void> search(
    String query, {
    bool simulateError = false,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    _lastQuery = query;

    if (query.isEmpty) {
      state = const UIStateData(
        state: UIState.empty,
        data: [],
      );
      return;
    }

    state = state.copyWith(state: UIState.loading);

    try {
      if (_allProducts.isEmpty) {
        _allProducts = MockDataService.generateProducts(50);
      }

      final results = await MockDataService.simulateNetworkDelay(
        MockDataService.searchProducts(_allProducts, query),
        delay: delay,
        shouldFail: simulateError,
        errorMessage: 'Search failed. Please check your connection.',
      );

      if (results.isEmpty) {
        state = UIStateData(
          state: UIState.empty,
          data: [],
          errorMessage: 'No results found for "$query"',
        );
      } else if (results.length <= 2) {
        state = UIStateData(
          state: UIState.partial,
          data: results,
          itemCount: results.length,
        );
      } else {
        state = UIStateData(
          state: UIState.ideal,
          data: results,
          itemCount: results.length,
        );
      }
    } catch (e) {
      state = UIStateData(
        state: UIState.error,
        errorMessage: e.toString(),
        data: state.data,
      );
    }
  }

  void clearSearch() {
    _lastQuery = '';
    state = const UIStateData(
      state: UIState.empty,
      data: [],
    );
  }

  void retry() {
    if (_lastQuery.isNotEmpty) {
      search(_lastQuery);
    }
  }

  void setDemoState(UIState demoState) {
    switch (demoState) {
      case UIState.empty:
        state = const UIStateData(
          state: UIState.empty,
          data: [],
          errorMessage: 'No results found for "demo search"',
        );
        break;
      case UIState.loading:
        state = state.copyWith(state: UIState.loading);
        break;
      case UIState.error:
        state = UIStateData(
          state: UIState.error,
          errorMessage: 'Search connection failed',
          data: state.data,
        );
        break;
      case UIState.partial:
        state = UIStateData(
          state: UIState.partial,
          data: MockDataService.generateProducts(1),
          itemCount: 1,
        );
        break;
      case UIState.ideal:
        state = UIStateData(
          state: UIState.ideal,
          data: MockDataService.generateProducts(10),
          itemCount: 10,
        );
        break;
    }
  }
}