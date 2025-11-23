import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/product_list_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/ui_state_catalog_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Five UI States Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductListScreen(),
    SearchScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Five UI States'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'UI State Catalog (for Screenshots)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UIStateCatalogScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.dashboard_customize,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The Five UI States Pattern',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every screen has 5 distinct states',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'The Five States',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStateCard(
              context,
              icon: Icons.inbox_outlined,
              title: '1. Empty State',
              description:
                  'When there\'s no data to show. First time use, cleared data, or no search results.',
              color: Colors.grey,
            ),
            _buildStateCard(
              context,
              icon: Icons.hourglass_empty,
              title: '2. Loading State',
              description:
                  'When fetching data or processing. Shows progress indicators or skeleton screens.',
              color: Colors.blue,
            ),
            _buildStateCard(
              context,
              icon: Icons.error_outline,
              title: '3. Error State',
              description:
                  'When something goes wrong. Network errors, validation issues, or failures.',
              color: Colors.red,
            ),
            _buildStateCard(
              context,
              icon: Icons.pie_chart_outline,
              title: '4. Partial State',
              description:
                  'When data is incomplete. Few items, incomplete profiles, or minimal content.',
              color: Colors.orange,
            ),
            _buildStateCard(
              context,
              icon: Icons.check_circle_outline,
              title: '5. Ideal State',
              description:
                  'When everything is perfect. Full data, complete profiles, successful operations.',
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                              Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to Use This Demo',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Navigate to different screens using the bottom navigation\n'
                      '• Each screen demonstrates all 5 UI states\n'
                      '• Use the state selector chips to switch between states\n'
                      '• Interact with the screens to see natural state transitions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer
                                .withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UIStateCatalogScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Open UI State Catalog (for Screenshots)'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}