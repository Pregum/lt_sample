import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/ui_state.dart';
import '../services/mock_data_service.dart';

final productListProvider =
    StateNotifierProvider<ProductListNotifier, UIStateData<List<Product>>>(
  (ref) => ProductListNotifier(),
);

class ProductListNotifier extends StateNotifier<UIStateData<List<Product>>> {
  ProductListNotifier()
      : super(const UIStateData(
          state: UIState.empty,
          data: [],
        ));

  Future<void> loadProducts({
    int count = 10,
    bool simulateError = false,
    Duration delay = const Duration(seconds: 2),
  }) async {
    state = state.copyWith(state: UIState.loading);

    try {
      final products = await MockDataService.simulateNetworkDelay(
        MockDataService.generateProducts(count),
        delay: delay,
        shouldFail: simulateError,
        errorMessage: 'Failed to load products. Please check your connection.',
      );

      if (products.isEmpty) {
        state = const UIStateData(
          state: UIState.empty,
          data: [],
        );
      } else if (products.length <= 2) {
        state = UIStateData(
          state: UIState.partial,
          data: products,
          itemCount: products.length,
        );
      } else {
        state = UIStateData(
          state: UIState.ideal,
          data: products,
          itemCount: products.length,
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

  void clearProducts() {
    state = const UIStateData(
      state: UIState.empty,
      data: [],
    );
  }

  void setDemoState(UIState demoState, {int itemCount = 10}) {
    switch (demoState) {
      case UIState.empty:
        state = const UIStateData(state: UIState.empty, data: []);
        break;
      case UIState.loading:
        state = state.copyWith(state: UIState.loading);
        break;
      case UIState.error:
        state = UIStateData(
          state: UIState.error,
          errorMessage: 'This is a demo error message',
          data: state.data,
        );
        break;
      case UIState.partial:
        state = UIStateData(
          state: UIState.partial,
          data: MockDataService.generateProducts(2),
          itemCount: 2,
        );
        break;
      case UIState.ideal:
        state = UIStateData(
          state: UIState.ideal,
          data: MockDataService.generateProducts(itemCount),
          itemCount: itemCount,
        );
        break;
    }
  }

  void addProduct(Product product) {
    final currentProducts = state.data ?? [];
    final updatedProducts = [...currentProducts, product];

    if (updatedProducts.length <= 2) {
      state = UIStateData(
        state: UIState.partial,
        data: updatedProducts,
        itemCount: updatedProducts.length,
      );
    } else {
      state = UIStateData(
        state: UIState.ideal,
        data: updatedProducts,
        itemCount: updatedProducts.length,
      );
    }
  }

  void removeProduct(String productId) {
    final currentProducts = state.data ?? [];
    final updatedProducts =
        currentProducts.where((p) => p.id != productId).toList();

    if (updatedProducts.isEmpty) {
      state = const UIStateData(
        state: UIState.empty,
        data: [],
      );
    } else if (updatedProducts.length <= 2) {
      state = UIStateData(
        state: UIState.partial,
        data: updatedProducts,
        itemCount: updatedProducts.length,
      );
    } else {
      state = UIStateData(
        state: UIState.ideal,
        data: updatedProducts,
        itemCount: updatedProducts.length,
      );
    }
  }
}