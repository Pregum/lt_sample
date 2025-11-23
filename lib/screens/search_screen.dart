import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/ui_state.dart';
import '../providers/search_provider.dart';
import '../widgets/state_wrapper.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search - Five UI States'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isNotEmpty) {
                  notifier.search(value);
                } else {
                  notifier.clearSearch();
                }
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildStateSelector(context, notifier, uiState.state),
          Expanded(
            child: StateWrapper<List<Product>>(
              uiStateData: uiState,
              idealBuilder: (products) => _buildSearchResults(
                context,
                products,
                uiState.isPartial,
              ),
              emptyWidget: _buildEmptySearch(
                context,
                uiState.errorMessage,
              ),
              partialMessage:
                  'Only found a few results. Try different search terms for more results.',
              onRetry: () => notifier.retry(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSelector(
    BuildContext context,
    SearchNotifier notifier,
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

  Widget _buildEmptySearch(BuildContext context, String? errorMessage) {
    final hasSearchTerm = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchTerm ? Icons.search_off : Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearchTerm
                  ? errorMessage ?? 'No results found'
                  : 'Start searching',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearchTerm
                  ? 'Try different keywords or check spelling'
                  : 'Enter a search term to find products',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchTerm) ...[
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  'Electronics',
                  'Clothing',
                  'Books',
                  'Home',
                  'Sports'
                ].map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      ref.read(searchProvider.notifier).search(suggestion);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Product> products,
    bool isPartial,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length + (isPartial ? 1 : 0),
      itemBuilder: (context, index) {
        if (isPartial && index == products.length) {
          return Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.tips_and_updates,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'Few results found',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Try broader search terms for more results',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.8),
                ),
              ),
            ),
          );
        }

        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconForCategory(product.category),
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: _highlightSearchTerm(
                  product.name,
                  _searchController.text,
                  Theme.of(context),
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${product.name}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      case 'books':
        return Icons.book;
      case 'home':
        return Icons.home;
      case 'sports':
        return Icons.sports_basketball;
      default:
        return Icons.category;
    }
  }

  List<TextSpan> _highlightSearchTerm(
    String text,
    String searchTerm,
    ThemeData theme,
  ) {
    if (searchTerm.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerSearchTerm = searchTerm.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerSearchTerm);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + searchTerm.length),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
      );

      start = index + searchTerm.length;
      index = lowerText.indexOf(lowerSearchTerm, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}