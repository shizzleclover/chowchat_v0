import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme State
enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isDarkMode = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadThemeFromPrefs();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      final themeMode = AppThemeMode.values[themeIndex];
      
      // Determine if dark mode based on system or user preference
      bool isDarkMode = false;
      if (themeMode == AppThemeMode.dark) {
        isDarkMode = true;
      } else if (themeMode == AppThemeMode.system) {
        // For now, default to light mode for system
        // In a real app, you'd check the system brightness
        isDarkMode = false;
      }

      state = state.copyWith(
        themeMode: themeMode,
        isDarkMode: isDarkMode,
      );
    } catch (e) {
      // If loading fails, stick with default
    }
  }

  Future<void> _saveThemeToPrefs(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    bool isDarkMode = false;
    
    switch (themeMode) {
      case AppThemeMode.light:
        isDarkMode = false;
        break;
      case AppThemeMode.dark:
        isDarkMode = true;
        break;
      case AppThemeMode.system:
        // For now, default to light mode for system
        // In a real app, you'd check MediaQuery.platformBrightnessOf(context)
        isDarkMode = false;
        break;
    }

    state = state.copyWith(
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    );

    await _saveThemeToPrefs(themeMode);
  }

  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Convenience providers
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});

final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});