import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App State Keys
class AppStateKeys {
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String hasCompletedProfileSetup = 'has_completed_profile_setup';
  static const String dismissedTooltips = 'dismissed_tooltips';
  static const String appVersion = 'app_version';
  static const String lastLaunchDate = 'last_launch_date';
}

// App State Model
class AppState {
  final bool hasSeenOnboarding;
  final bool hasCompletedProfileSetup;
  final Set<String> dismissedTooltips;
  final String? appVersion;
  final DateTime? lastLaunchDate;
  final bool isFirstLaunch;

  const AppState({
    this.hasSeenOnboarding = false,
    this.hasCompletedProfileSetup = false,
    this.dismissedTooltips = const {},
    this.appVersion,
    this.lastLaunchDate,
    this.isFirstLaunch = true,
  });

  AppState copyWith({
    bool? hasSeenOnboarding,
    bool? hasCompletedProfileSetup,
    Set<String>? dismissedTooltips,
    String? appVersion,
    DateTime? lastLaunchDate,
    bool? isFirstLaunch,
  }) {
    return AppState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasCompletedProfileSetup: hasCompletedProfileSetup ?? this.hasCompletedProfileSetup,
      dismissedTooltips: dismissedTooltips ?? this.dismissedTooltips,
      appVersion: appVersion ?? this.appVersion,
      lastLaunchDate: lastLaunchDate ?? this.lastLaunchDate,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

// App State Notifier
class AppStateNotifier extends StateNotifier<AppState> {
  late SharedPreferences _prefs;
  
  AppStateNotifier() : super(const AppState()) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      final hasSeenOnboarding = _prefs.getBool(AppStateKeys.hasSeenOnboarding) ?? false;
      final hasCompletedProfileSetup = _prefs.getBool(AppStateKeys.hasCompletedProfileSetup) ?? false;
      final dismissedTooltipsList = _prefs.getStringList(AppStateKeys.dismissedTooltips) ?? [];
      final appVersion = _prefs.getString(AppStateKeys.appVersion);
      final lastLaunchTimestamp = _prefs.getInt(AppStateKeys.lastLaunchDate);
      
      final lastLaunchDate = lastLaunchTimestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(lastLaunchTimestamp)
          : null;
      
      final isFirstLaunch = lastLaunchDate == null;
      
      state = AppState(
        hasSeenOnboarding: hasSeenOnboarding,
        hasCompletedProfileSetup: hasCompletedProfileSetup,
        dismissedTooltips: dismissedTooltipsList.toSet(),
        appVersion: appVersion,
        lastLaunchDate: lastLaunchDate,
        isFirstLaunch: isFirstLaunch,
      );

      // Update last launch date
      await _updateLastLaunchDate();
      
    } catch (e) {
      // Handle initialization error gracefully
      state = const AppState();
    }
  }

  Future<void> _updateLastLaunchDate() async {
    try {
      await _prefs.setInt(
        AppStateKeys.lastLaunchDate, 
        DateTime.now().millisecondsSinceEpoch,
      );
      
      state = state.copyWith(
        lastLaunchDate: DateTime.now(),
        isFirstLaunch: false,
      );
    } catch (e) {
      // Ignore error for non-critical operation
    }
  }

  Future<void> markOnboardingCompleted() async {
    try {
      await _prefs.setBool(AppStateKeys.hasSeenOnboarding, true);
      state = state.copyWith(hasSeenOnboarding: true);
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> markProfileSetupCompleted() async {
    try {
      await _prefs.setBool(AppStateKeys.hasCompletedProfileSetup, true);
      state = state.copyWith(hasCompletedProfileSetup: true);
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> dismissTooltip(String tooltipId) async {
    try {
      final updatedTooltips = {...state.dismissedTooltips, tooltipId};
      await _prefs.setStringList(
        AppStateKeys.dismissedTooltips, 
        updatedTooltips.toList(),
      );
      state = state.copyWith(dismissedTooltips: updatedTooltips);
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> setAppVersion(String version) async {
    try {
      await _prefs.setString(AppStateKeys.appVersion, version);
      state = state.copyWith(appVersion: version);
    } catch (e) {
      // Handle error gracefully
    }
  }

  bool hasTooltipBeenDismissed(String tooltipId) {
    return state.dismissedTooltips.contains(tooltipId);
  }

  // Reset all app state (useful for testing or logout)
  Future<void> resetAppState() async {
    try {
      await _prefs.clear();
      state = const AppState();
    } catch (e) {
      // Handle error gracefully
    }
  }
}

// Provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

// Convenience providers
final hasSeenOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).hasSeenOnboarding;
});

final hasCompletedProfileSetupProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).hasCompletedProfileSetup;
});

final isFirstLaunchProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isFirstLaunch;
});

// Tooltip management
class TooltipIds {
  static const String createFirstPost = 'create_first_post';
  static const String doubleTapToLike = 'double_tap_to_like';
  static const String tapToComment = 'tap_to_comment';
  static const String swipeToRefresh = 'swipe_to_refresh';
  static const String anonymousPosting = 'anonymous_posting';
}

final tooltipProvider = Provider.family<bool, String>((ref, tooltipId) {
  return ref.watch(appStateProvider.notifier).hasTooltipBeenDismissed(tooltipId);
});