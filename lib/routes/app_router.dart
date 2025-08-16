import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/enhanced_login_screen.dart';
import '../screens/auth/enhanced_signup_screen.dart';
import '../screens/profile/profile_setup_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/home/feed_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/post/create_post_screen.dart';
import '../screens/post/post_detail_screen.dart';

// Route names
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String feed = '/feed';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String createPost = '/post/create';
  static const String postDetail = '/post/:id';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.user != null;
            final isLoginRoute = state.fullPath == AppRoutes.login ||
                          state.fullPath == AppRoutes.signup;
      
      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isLoginRoute) {
        return AppRoutes.login;
        // ignore: dead_code
      }
      
      // If authenticated and trying to access auth routes
      if (isAuthenticated && isLoginRoute) {
        return AppRoutes.home;
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding route
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const EnhancedLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const EnhancedSignupScreen(),
      ),
      
      // Profile setup route
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      
      // Feed route
      GoRoute(
        path: AppRoutes.feed,
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      
      // Profile routes
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'];
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      // Post routes
      GoRoute(
        path: AppRoutes.createPost,
        name: 'createPost',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: AppRoutes.postDetail,
        name: 'postDetail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helper methods
class AppNavigation {
  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
  
  static void goToSignup(BuildContext context) {
    context.go(AppRoutes.signup);
  }
  
  static void goToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
  
  static void goToFeed(BuildContext context) {
    context.go(AppRoutes.feed);
  }
  
  static void goToProfile(BuildContext context, {String? userId}) {
    if (userId != null) {
      context.go('${AppRoutes.profile}?userId=$userId');
    } else {
      context.go(AppRoutes.profile);
    }
  }
  
  static void goToEditProfile(BuildContext context) {
    context.go(AppRoutes.editProfile);
  }
  
  static void goToCreatePost(BuildContext context) {
    context.go(AppRoutes.createPost);
  }
  
  static void goToPostDetail(BuildContext context, String postId) {
    context.go('/post/$postId');
  }
  
  static void goBack(BuildContext context) {
    context.pop();
  }
}