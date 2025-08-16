import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_themes.dart';
import 'routes/app_router.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (handled in splash screen now)
  // try {
  //   await SupabaseService.initialize();
  // } catch (e) {
  //   // Handle initialization error gracefully
  //   debugPrint('Supabase initialization error: $e');
  // }

  runApp(
    const ProviderScope(
      child: ChowChatApp(),
    ),
  );
}

class ChowChatApp extends ConsumerWidget {
  const ChowChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);
    
    ThemeMode themeMode;
    switch (themeState.themeMode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        themeMode = ThemeMode.system;
        break;
    }
    
    return MaterialApp.router(
      title: 'ChowChat',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
