import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/supabase.dart';

// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isNewUser;
  
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isNewUser = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isNewUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthState();
  }

  static const String _kAuthUserKey = 'auth_user';

  Future<void> _checkAuthState() async {
    // 1) Try local persisted user first (works with mock auth)
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kAuthUserKey);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        state = state.copyWith(user: user);
        return;
      }
    } catch (_) {}

    // 2) Fallback to Supabase profile if a real session exists
    try {
      final user = await SupabaseService.getCurrentUserProfile();
      state = state.copyWith(user: user);
    } catch (_) {
      state = state.copyWith(user: null);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String campus,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // For demo purposes, create a mock user
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        final mockUser = UserModel(
          id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: username,
          username: username,
          campus: campus,
          bio: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        state = state.copyWith(user: mockUser, isLoading: false, isNewUser: true);
        await _persistUser(mockUser);
      } else {
        state = state.copyWith(
          error: 'Please fill in all required fields',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // For demo purposes, create a mock user for any valid email/password
      if (email.isNotEmpty && password.isNotEmpty) {
        final mockUser = UserModel(
          id: 'demo-user-123',
          email: email,
          displayName: 'Demo User',
          username: email.split('@').first,
          campus: 'Demo University',
          bio: 'Demo user for ChowChat testing',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        state = state.copyWith(user: mockUser, isLoading: false, isNewUser: false);
        await _persistUser(mockUser);
      } else {
        state = state.copyWith(
          error: 'Please enter valid credentials',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await SupabaseService.signOut();
      await _clearPersistedUser();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (state.user == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await SupabaseService.updateUserProfile(
        userId: state.user!.id,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      if (updatedUser != null) {
        state = state.copyWith(user: updatedUser, isLoading: false);
        await _persistUser(updatedUser);
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Upload avatar image and return URL
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = state.user;
      if (user == null) throw Exception('User not logged in');

      // Upload to Supabase Storage
      final fileName = 'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadResult = await SupabaseService.uploadImage(imageFile, fileName);
      
      return uploadResult;
    } catch (e) {
      state = state.copyWith(error: 'Failed to upload avatar: $e');
      rethrow;
    }
  }

  // Persistence helpers
  Future<void> _persistUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAuthUserKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<void> _clearPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAuthUserKey);
    } catch (_) {}
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Computed providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});

final isLoadingAuthProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});