import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/user_profile.dart';
import '../models/ui_state.dart';
import '../services/mock_data_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';
import '../widgets/partial_state_widget.dart';

/// UI State Catalog - Storybook-like page for screenshot capture
class UIStateCatalogScreen extends StatelessWidget {
  const UIStateCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI State Catalog'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'The Five UI States'),
          const SizedBox(height: 8),
          Text(
            'This catalog showcases all 5 UI states for easy screenshot capture and visual reference.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 32),

          // 1. Blank State
          _buildSectionHeader(context, '1. Blank State'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Blank State',
            'No data available - First time use',
            const EmptyStateWidget(
              message: 'No products available',
              buttonText: 'Add Products',
              icon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Loading State
          _buildSectionHeader(context, '2. Loading State'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Loading State',
            'Data fetching with shimmer effects',
            const SizedBox(
              height: 400,
              child: LoadingStateWidget(
                showListShimmer: true,
                itemCount: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Error State
          _buildSectionHeader(context, '3. Error State'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Error State',
            'Error handling with retry functionality',
            ErrorStateWidget(
              message: 'Failed to load products. Please check your connection.',
              details: 'Network error: Connection timeout',
              onRetry: () {},
            ),
          ),
          const SizedBox(height: 24),

          // 4. Partial State
          _buildSectionHeader(context, '4. Partial State'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Partial State - Banner',
            'Incomplete data with completion prompts',
            PartialStateBanner(
              title: 'Complete Your Profile',
              description: 'Add more information to unlock all features',
              completionPercentage: 45,
              onComplete: () {},
            ),
          ),
          const SizedBox(height: 16),
          _buildStateCard(
            context,
            'Partial State - Bottom Bar',
            'Few items with add more prompt',
            SizedBox(
              height: 80,
              child: Stack(
                children: [
                  Container(color: Colors.transparent),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PartialStateWidget(
                      message: 'Add more products to build your catalog',
                      onAction: () {},
                      actionText: 'Add More',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Ideal State - Product List
          _buildSectionHeader(context, '5. Ideal State - Product List'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Ideal State',
            'Full data - Optimal user experience',
            _buildProductList(context),
          ),
          const SizedBox(height: 24),

          // 6. Ideal State - User Profile
          _buildSectionHeader(context, '6. Ideal State - User Profile'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Complete Profile',
            'Fully populated user profile',
            _buildUserProfile(context),
          ),
          const SizedBox(height: 24),

          // 7. Search Results - Blank
          _buildSectionHeader(context, '7. Search - Blank State'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'No Search Results',
            'Blank search with suggestions',
            _buildSearchEmpty(context),
          ),
          const SizedBox(height: 24),

          // 8. Search Results - Partial
          _buildSectionHeader(context, '8. Search - Partial Results'),
          const SizedBox(height: 8),
          _buildStateCard(
            context,
            'Few Search Results',
            'Limited results with suggestions',
            _buildSearchPartial(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildStateCard(
    BuildContext context,
    String title,
    String description,
    Widget child,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 400,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    final products = MockDataService.generateProducts(5);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
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
            subtitle: Text(
              '\$${product.price.toStringAsFixed(2)} • Stock: ${product.stock}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final profile = MockDataService.generateUserProfile(
      userId: 'user_001',
      isComplete: true,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name ?? 'User Name',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            profile.email ?? 'email@example.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Bio'),
              subtitle: Text(profile.bio ?? 'No bio'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone'),
              subtitle: Text(profile.phoneNumber ?? 'No phone'),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.interests_outlined),
                      SizedBox(width: 8),
                      Text('Interests'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (profile.interests.isEmpty
                            ? ['Technology', 'Programming', 'Mobile Development']
                            : profile.interests)
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Electronics', 'Clothing', 'Books'].map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {},
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPartial(BuildContext context) {
    final products = MockDataService.generateProducts(2);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length + 1,
      itemBuilder: (context, index) {
        if (index == products.length) {
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
              child: Icon(
                Icons.devices,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: Text(product.name),
            subtitle: Text(
              '${product.category} • \$${product.price.toStringAsFixed(2)}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
