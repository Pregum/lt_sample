import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/ui_state.dart';
import '../services/mock_data_service.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UIStateData<UserProfile>>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UIStateData<UserProfile>> {
  UserProfileNotifier()
      : super(UIStateData(
          state: UIState.empty,
          data: UserProfile.empty('user_001'),
        ));

  Future<void> loadProfile({
    bool isEmpty = false,
    bool isPartial = false,
    bool isComplete = false,
    bool simulateError = false,
    Duration delay = const Duration(seconds: 2),
  }) async {
    state = state.copyWith(state: UIState.loading);

    try {
      final profile = await MockDataService.simulateNetworkDelay(
        MockDataService.generateUserProfile(
          userId: 'user_001',
          isEmpty: isEmpty,
          isPartial: isPartial,
          isComplete: isComplete,
        ),
        delay: delay,
        shouldFail: simulateError,
        errorMessage: 'Failed to load profile. Please try again.',
      );

      if (isEmpty || (profile.name == null && profile.email == null)) {
        state = UIStateData(
          state: UIState.empty,
          data: profile,
        );
      } else if (profile.isPartial || profile.completionPercentage < 60) {
        state = UIStateData(
          state: UIState.partial,
          data: profile,
          itemCount: profile.completionPercentage,
        );
      } else {
        state = UIStateData(
          state: UIState.ideal,
          data: profile,
          itemCount: profile.completionPercentage,
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

  void updateProfileField({
    String? name,
    String? email,
    String? bio,
    String? phoneNumber,
    List<String>? interests,
  }) {
    final currentProfile = state.data;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: name ?? currentProfile.name,
      email: email ?? currentProfile.email,
      bio: bio ?? currentProfile.bio,
      phoneNumber: phoneNumber ?? currentProfile.phoneNumber,
      interests: interests ?? currentProfile.interests,
      updatedAt: DateTime.now(),
    );

    final isComplete = updatedProfile.completionPercentage == 100;
    final updatedProfileWithStatus = updatedProfile.copyWith(
      isComplete: isComplete,
    );

    if (updatedProfileWithStatus.completionPercentage == 0) {
      state = UIStateData(
        state: UIState.empty,
        data: updatedProfileWithStatus,
      );
    } else if (updatedProfileWithStatus.completionPercentage < 60) {
      state = UIStateData(
        state: UIState.partial,
        data: updatedProfileWithStatus,
        itemCount: updatedProfileWithStatus.completionPercentage,
      );
    } else {
      state = UIStateData(
        state: UIState.ideal,
        data: updatedProfileWithStatus,
        itemCount: updatedProfileWithStatus.completionPercentage,
      );
    }
  }

  void resetProfile() {
    state = UIStateData(
      state: UIState.empty,
      data: UserProfile.empty('user_001'),
    );
  }

  void setDemoState(UIState demoState) {
    switch (demoState) {
      case UIState.empty:
        state = UIStateData(
          state: UIState.empty,
          data: MockDataService.generateUserProfile(
            userId: 'user_001',
            isEmpty: true,
          ),
        );
        break;
      case UIState.loading:
        state = state.copyWith(state: UIState.loading);
        break;
      case UIState.error:
        state = UIStateData(
          state: UIState.error,
          errorMessage: 'Failed to save profile changes',
          data: state.data,
        );
        break;
      case UIState.partial:
        final profile = MockDataService.generateUserProfile(
          userId: 'user_001',
          isPartial: true,
        );
        state = UIStateData(
          state: UIState.partial,
          data: profile,
          itemCount: profile.completionPercentage,
        );
        break;
      case UIState.ideal:
        final profile = MockDataService.generateUserProfile(
          userId: 'user_001',
          isComplete: true,
        );
        state = UIStateData(
          state: UIState.ideal,
          data: profile,
          itemCount: profile.completionPercentage,
        );
        break;
    }
  }
}