import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../routes/app_router.dart';
import '../../services/supabase.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Supabase
      await SupabaseService.initialize();
      
      // Load app state
      await _loadAppState();
      
      // Check auth session
      await _checkAuthSession();
      
      // Wait minimum splash duration
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to appropriate screen
      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        _showErrorAndNavigate();
      }
    }
  }

  Future<void> _loadAppState() async {
    // App state is automatically loaded by the provider
    ref.read(appStateProvider);
  }

  Future<void> _checkAuthSession() async {
    // Auth state is automatically loaded by the provider
    ref.read(authProvider);
  }

  void _navigateToNextScreen() {
    final appState = ref.read(appStateProvider);
    final authState = ref.read(authProvider);

    // Routing logic based on app state
    if (authState.user == null) {
      // Not logged in → Check if they've seen onboarding
      if (!appState.hasSeenOnboarding) {
        // First time user → Onboarding
        context.go(AppRoutes.onboarding);
      } else {
        // Returning user → Login
        context.go(AppRoutes.login);
      }
    } else if (authState.isNewUser && !appState.hasCompletedProfileSetup) {
      // New user who just signed up → Profile Setup
      context.go(AppRoutes.profileSetup);
    } else {
      // Existing user or completed setup → Home
      context.go(AppRoutes.home);
    }
  }

  void _showErrorAndNavigate() {
    // On error, go to onboarding for fresh start
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.lightPrimary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Logo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.lightPrimary,
                                      AppColors.lightAccent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.lightPrimary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // App Name
                              Text(
                                'ChowChat',
                                style: GoogleFonts.montserrat(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lightForeground,
                                  letterSpacing: -1,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Tagline
                              Text(
                                'Where Campus Eats Talk',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightMutedForeground,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              
                              const SizedBox(height: 48),
                              
                              // Loading indicator
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lightPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Version info
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightMutedForeground.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}