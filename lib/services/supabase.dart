import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await dotenv.load();
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  // Auth Methods
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
    required String campus,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Create user profile
      final userProfile = await client
          .from('users')
          .insert({
            'id': response.user!.id,
            'email': email,
            'username': username,
            'campus': campus,
          })
          .select()
          .single();

      return UserModel.fromJson(userProfile);
    }
    return null;
  }

  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userProfile = await client
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userProfile);
    }
    return null;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // User Methods
  static Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  static Future<UserModel?> updateUserProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final response = await client
        .from('users')
        .update({
          if (displayName != null) 'display_name': displayName,
          if (bio != null) 'bio': bio,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // Post Methods
  static Future<PostModel> createPost({
    required String content,
    required List<String> imageUrls,
    String? videoUrl,
    double? rating,
    required String storeName,
    required String location,
    required String foodDescription,
    bool isAnonymous = false,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await client
        .from('posts')
        .insert({
          'user_id': user.id,
          'content': content,
          'image_urls': imageUrls,
          'video_url': videoUrl,
          'rating': rating,
          'store_name': storeName,
          'location': location,
          'food_description': foodDescription,
          'is_anonymous': isAnonymous,
        })
        .select()
        .single();

    return PostModel.fromJson(response);
  }

  static Future<List<PostModel>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await client
        .from('posts')
        .select('''
          *,
          user:users(*)
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response.map((json) => PostModel.fromJson(json)).toList();
  }

  static Future<PostModel?> getPost(String postId) async {
    final response = await client
        .from('posts')
        .select('''
          *,
          user:users(*)
        ''')
        .eq('id', postId)
        .single();

    return PostModel.fromJson(response);
  }

  // Like Methods
  static Future<void> likePost(String postId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await client.from('likes').insert({
      'post_id': postId,
      'user_id': user.id,
    });

    // Update likes count
    await client.rpc('increment_likes_count', params: {'post_id': postId});
  }

  static Future<void> unlikePost(String postId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await client
        .from('likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    // Update likes count
    await client.rpc('decrement_likes_count', params: {'post_id': postId});
  }

  static Future<bool> isPostLiked(String postId) async {
    final user = currentUser;
    if (user == null) return false;

    final response = await client
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    return response.isNotEmpty;
  }

  // Comment Methods
  static Future<CommentModel> addComment({
    required String postId,
    required String content,
    bool isAnonymous = false,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await client
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': user.id,
          'content': content,
          'is_anonymous': isAnonymous,
        })
        .select()
        .single();

    // Update comments count
    await client.rpc('increment_comments_count', params: {'post_id': postId});

    return CommentModel.fromJson(response);
  }

  static Future<List<CommentModel>> getPostComments(String postId) async {
    final response = await client
        .from('comments')
        .select('''
          *,
          user:users(*)
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return response.map((json) => CommentModel.fromJson(json)).toList();
  }

  // Storage Methods
  static Future<String> uploadImage(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await client.storage.from('images').uploadBinary(fileName, bytes);
    return client.storage.from('images').getPublicUrl(fileName);
  }

  static Future<String> uploadVideo(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await client.storage.from('videos').uploadBinary(fileName, bytes);
    return client.storage.from('videos').getPublicUrl(fileName);
  }
}