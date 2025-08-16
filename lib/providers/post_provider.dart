import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/supabase.dart';

// Post Creation State
class PostCreationState {
  final String content;
  final List<File> images;
  final File? video;
  final double? rating;
  final String storeName;
  final String location;
  final String foodDescription;
  final bool isAnonymous;
  final bool isLoading;
  final String? error;

  const PostCreationState({
    this.content = '',
    this.images = const [],
    this.video,
    this.rating,
    this.storeName = '',
    this.location = '',
    this.foodDescription = '',
    this.isAnonymous = false,
    this.isLoading = false,
    this.error,
  });

  PostCreationState copyWith({
    String? content,
    List<File>? images,
    File? video,
    double? rating,
    String? storeName,
    String? location,
    String? foodDescription,
    bool? isAnonymous,
    bool? isLoading,
    String? error,
  }) {
    return PostCreationState(
      content: content ?? this.content,
      images: images ?? this.images,
      video: video ?? this.video,
      rating: rating ?? this.rating,
      storeName: storeName ?? this.storeName,
      location: location ?? this.location,
      foodDescription: foodDescription ?? this.foodDescription,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Post Creation Provider
class PostCreationNotifier extends StateNotifier<PostCreationState> {
  PostCreationNotifier() : super(const PostCreationState());

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void updateStoreName(String storeName) {
    state = state.copyWith(storeName: storeName);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateFoodDescription(String foodDescription) {
    state = state.copyWith(foodDescription: foodDescription);
  }

  void updateRating(double? rating) {
    state = state.copyWith(rating: rating);
  }

  void toggleAnonymous() {
    state = state.copyWith(isAnonymous: !state.isAnonymous);
  }

  Future<void> addImage() async {
    if (state.images.length >= 5) return; // Max 5 images

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final newImages = [...state.images, File(pickedFile.path)];
      state = state.copyWith(images: newImages);
    }
  }

  Future<void> addImageFromCamera() async {
    if (state.images.length >= 5) return; // Max 5 images

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      final newImages = [...state.images, File(pickedFile.path)];
      state = state.copyWith(images: newImages);
    }
  }

  void removeImage(int index) {
    final newImages = [...state.images];
    newImages.removeAt(index);
    state = state.copyWith(images: newImages);
  }

  Future<void> addVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      state = state.copyWith(video: File(pickedFile.path));
    }
  }

  void removeVideo() {
    state = state.copyWith(video: null);
  }

  Future<PostModel?> submitPost() async {
    if (!_isValid()) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Upload images
      List<String> imageUrls = [];
      for (int i = 0; i < state.images.length; i++) {
        final file = state.images[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await SupabaseService.uploadImage(file, fileName);
        imageUrls.add(url);
      }

      // Upload video if exists
      String? videoUrl;
      if (state.video != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
        videoUrl = await SupabaseService.uploadVideo(state.video!, fileName);
      }

      // Create post
      final post = await SupabaseService.createPost(
        content: state.content,
        imageUrls: imageUrls,
        videoUrl: videoUrl,
        rating: state.rating,
        storeName: state.storeName,
        location: state.location,
        foodDescription: state.foodDescription,
        isAnonymous: state.isAnonymous,
      );

      // Reset state
      state = const PostCreationState();
      return post;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  bool _isValid() {
    return state.content.isNotEmpty &&
           state.storeName.isNotEmpty &&
           state.location.isNotEmpty &&
           state.foodDescription.isNotEmpty &&
           (state.images.isNotEmpty || state.video != null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const PostCreationState();
  }
}

final postCreationProvider = StateNotifierProvider<PostCreationNotifier, PostCreationState>((ref) {
  return PostCreationNotifier();
});

// Comments Provider
class CommentsNotifier extends StateNotifier<Map<String, List<CommentModel>>> {
  CommentsNotifier() : super({});

  Future<void> loadComments(String postId) async {
    try {
      final comments = await SupabaseService.getPostComments(postId);
      state = {...state, postId: comments};
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addComment({
    required String postId,
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      final comment = await SupabaseService.addComment(
        postId: postId,
        content: content,
        isAnonymous: isAnonymous,
      );

      final currentComments = state[postId] ?? [];
      state = {...state, postId: [...currentComments, comment]};
    } catch (e) {
      rethrow;
    }
  }
}

final commentsProvider = StateNotifierProvider<CommentsNotifier, Map<String, List<CommentModel>>>((ref) {
  return CommentsNotifier();
});