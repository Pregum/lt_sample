import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/ui_state.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/state_wrapper.dart';
import '../widgets/partial_state_widget.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(userProfileProvider);
    final notifier = ref.read(userProfileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile - Five UI States'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, notifier),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'empty',
                child: Text('Load Empty Profile'),
              ),
              const PopupMenuItem(
                value: 'partial',
                child: Text('Load Partial Profile'),
              ),
              const PopupMenuItem(
                value: 'complete',
                child: Text('Load Complete Profile'),
              ),
              const PopupMenuItem(
                value: 'error',
                child: Text('Simulate Error'),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Profile'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStateSelector(context, notifier, uiState.state),
          Expanded(
            child: StateWrapper<UserProfile>(
              uiStateData: uiState,
              idealBuilder: (profile) => _buildProfileView(
                context,
                profile,
                notifier,
                uiState.isPartial,
              ),
              emptyMessage: 'Create your profile to get started',
              emptyButtonText: 'Create Profile',
              onEmptyAction: () => _showProfileEditor(context, notifier),
              onRetry: () => notifier.loadProfile(isComplete: true),
            ),
          ),
        ],
      ),
      floatingActionButton: uiState.state != UIState.loading &&
              uiState.state != UIState.error
          ? FloatingActionButton.extended(
              onPressed: () => _showProfileEditor(context, notifier),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            )
          : null,
    );
  }

  Widget _buildStateSelector(
    BuildContext context,
    UserProfileNotifier notifier,
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

  Widget _buildProfileView(
    BuildContext context,
    UserProfile profile,
    UserProfileNotifier notifier,
    bool isPartial,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (isPartial)
            PartialStateBanner(
              title: 'Complete Your Profile',
              description:
                  'Add more information to unlock all features and connect with others',
              completionPercentage: profile.completionPercentage,
              onComplete: () => _showProfileEditor(context, notifier),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile.avatarUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.email ?? 'No Email',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 24),
                _buildProfileSection(
                  context,
                  'Bio',
                  profile.bio ?? 'No bio added yet',
                  Icons.info_outline,
                  isEmpty: profile.bio == null,
                ),
                _buildProfileSection(
                  context,
                  'Phone',
                  profile.phoneNumber ?? 'No phone number',
                  Icons.phone_outlined,
                  isEmpty: profile.phoneNumber == null,
                ),
                _buildProfileSection(
                  context,
                  'Birth Date',
                  profile.birthDate?.toString().split(' ')[0] ?? 'Not specified',
                  Icons.cake_outlined,
                  isEmpty: profile.birthDate == null,
                ),
                _buildInterestsSection(context, profile.interests),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isEmpty = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isEmpty
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                    : null,
              ),
        ),
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context, List<String> interests) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.interests_outlined),
                const SizedBox(width: 8),
                Text(
                  'Interests',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            interests.isEmpty
                ? Text(
                    'No interests added',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: interests
                        .map((interest) => Chip(
                              label: Text(interest),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, UserProfileNotifier notifier) {
    switch (action) {
      case 'empty':
        notifier.loadProfile(isEmpty: true);
        break;
      case 'partial':
        notifier.loadProfile(isPartial: true);
        break;
      case 'complete':
        notifier.loadProfile(isComplete: true);
        break;
      case 'error':
        notifier.loadProfile(simulateError: true);
        break;
      case 'reset':
        notifier.resetProfile();
        break;
    }
  }

  void _showProfileEditor(BuildContext context, UserProfileNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.updateProfileField(name: value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.updateProfileField(email: value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSubmitted: (value) {
                  notifier.updateProfileField(bio: value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  notifier.updateProfileField(
                    name: 'John Doe',
                    email: 'john.doe@example.com',
                    bio: 'Passionate developer',
                    interests: ['Flutter', 'Mobile Development'],
                  );
                  Navigator.pop(context);
                },
                child: const Text('Fill Sample Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}