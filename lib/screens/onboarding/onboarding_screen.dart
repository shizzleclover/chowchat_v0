import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/app_color.dart';
import '../../providers/app_state_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/premium_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.camera_alt_rounded,
      title: 'Snap & Share',
      subtitle: 'Post your campus meals in seconds with photos that make mouths water',
      gradient: [AppColors.lightPrimary, AppColors.lightAccent],
    ),
    OnboardingData(
      icon: Icons.dynamic_feed_rounded,
      title: 'Real-Time Feed',
      subtitle: 'See what everyone\'s eating right now and discover trending dishes',
      gradient: [AppColors.lightAccent, AppColors.lightPrimary],
    ),
    OnboardingData(
      icon: Icons.masks_rounded,
      title: 'Honest & Fun',
      subtitle: 'Share authentic reviews or go anonymous - your choice, your voice',
      gradient: [AppColors.lightPrimary, AppColors.lightSecondaryForeground],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appStateProvider.notifier).markOnboardingCompleted();
    if (mounted) {
      context.go(AppRoutes.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with skip button
              _buildHeader(),
              
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),
              
              // Bottom section with indicators and button
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightPrimary, AppColors.lightAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightMutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradient,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: data.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 64),
          
          // Title
          Text(
            data.title,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.lightForeground,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            data.subtitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppColors.lightMutedForeground,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.lightPrimary,
              dotColor: AppColors.lightBorder,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
              spacing: 8,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              onPressed: _nextPage,
              text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
              variant: PremiumButtonVariant.primary,
              size: PremiumButtonSize.lg,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Login link for returning users
          if (_currentPage == _pages.length - 1)
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.lightMutedForeground,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: AppColors.lightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}