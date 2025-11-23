import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/ui_state.dart';
import '../providers/product_provider.dart';
import '../widgets/state_wrapper.dart';
import '../widgets/partial_state_widget.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List - Five UI States'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, notifier),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'error',
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Simulate Error'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStateSelector(context, notifier, uiState.state),
          Expanded(
            child: StateWrapper<List<Product>>(
              uiStateData: uiState,
              idealBuilder: (products) => _buildProductList(
                context,
                products,
                notifier,
                uiState.isPartial,
              ),
              emptyMessage: 'No products available',
              emptyButtonText: 'Add Products',
              onEmptyAction: () => notifier.loadProducts(count: 10),
              partialMessage: 'You have only a few products. Add more to enhance your catalog!',
              onPartialAction: () {
                final currentCount = uiState.data?.length ?? 0;
                notifier.loadProducts(count: currentCount + 5);
              },
              onRetry: () => notifier.loadProducts(count: 10),
            ),
          ),
        ],
      ),
      floatingActionButton: uiState.state != UIState.loading &&
              uiState.state != UIState.error
          ? FloatingActionButton.extended(
              onPressed: () => _addNewProduct(notifier),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
    );
  }

  Widget _buildStateSelector(
    BuildContext context,
    ProductListNotifier notifier,
    UIState currentState,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStateChip(
            context,
            'Empty',
            UIState.empty,
            currentState,
            () => notifier.setDemoState(UIState.empty),
          ),
          _buildStateChip(
            context,
            'Loading',
            UIState.loading,
            currentState,
            () => notifier.setDemoState(UIState.loading),
          ),
          _buildStateChip(
            context,
            'Error',
            UIState.error,
            currentState,
            () => notifier.setDemoState(UIState.error),
          ),
          _buildStateChip(
            context,
            'Partial',
            UIState.partial,
            currentState,
            () => notifier.setDemoState(UIState.partial),
          ),
          _buildStateChip(
            context,
            'Ideal',
            UIState.ideal,
            currentState,
            () => notifier.setDemoState(UIState.ideal),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip(
    BuildContext context,
    String label,
    UIState state,
    UIState currentState,
    VoidCallback onTap,
  ) {
    final isSelected = state == currentState;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    List<Product> products,
    ProductListNotifier notifier,
    bool isPartial,
  ) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product, notifier);
          },
        ),
        if (isPartial)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PartialStateWidget(
              message: 'Add more products to build your catalog',
              onAction: () {
                final currentCount = products.length;
                notifier.loadProducts(count: currentCount + 5);
              },
              actionText: 'Add More',
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ProductListNotifier notifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              product.name.substring(0, 1),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Stock: ${product.stock}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => notifier.removeProduct(product.id),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, ProductListNotifier notifier) {
    switch (action) {
      case 'refresh':
        notifier.loadProducts(count: 10);
        break;
      case 'clear':
        notifier.clearProducts();
        break;
      case 'error':
        notifier.loadProducts(count: 10, simulateError: true);
        break;
    }
  }

  void _addNewProduct(ProductListNotifier notifier) {
    final newProduct = Product(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: 'New Product ${DateTime.now().second}',
      description: 'A newly added product',
      price: 99.99,
      imageUrl: 'https://via.placeholder.com/150',
      stock: 50,
      category: 'New',
      createdAt: DateTime.now(),
    );
    notifier.addProduct(newProduct);
  }
}