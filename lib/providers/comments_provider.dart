import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

// Comments state
class CommentsState {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool isPostingComment;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isPostingComment = false,
    this.error,
  });

  CommentsState copyWith({
    List<CommentModel>? comments,
    bool? isLoading,
    bool? isPostingComment,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isPostingComment: isPostingComment ?? this.isPostingComment,
      error: error ?? this.error,
    );
  }
}

// Comments notifier
class CommentsNotifier extends StateNotifier<CommentsState> {
  CommentsNotifier() : super(const CommentsState());

  // Load comments for a post
  Future<void> loadComments(String postId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate mock comments with Nigerian content
      final mockComments = _generateMockComments(postId);
      
      state = state.copyWith(
        comments: mockComments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load comments',
      );
    }
  }

  // Add a new comment
  Future<void> addComment(String postId, String content, bool isAnonymous) async {
    if (state.isPostingComment || content.trim().isEmpty) return;

    state = state.copyWith(isPostingComment: true, error: null);

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        userId: 'current_user_id',
        content: content.trim(),
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        user: isAnonymous
            ? null
            : UserModel(
                id: 'current_user_id',
                email: 'current.user@university.edu',
                username: 'current_user',
                displayName: 'You',
                avatarUrl: null,
                bio: null,
                campus: 'University of Lagos',
                createdAt: DateTime.now().subtract(const Duration(days: 10)),
                updatedAt: DateTime.now(),
              ),
      );

      state = state.copyWith(
        comments: [newComment, ...state.comments],
        isPostingComment: false,
      );
    } catch (e) {
      state = state.copyWith(
        isPostingComment: false,
        error: 'Failed to post comment',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Generate mock comments with Nigerian context
  List<CommentModel> _generateMockComments(String postId) {
    final mockUsers = [
      {'name': 'Adunni Olumide', 'username': 'adunni_o', 'avatar': null},
      {'name': 'Chidi Okwu', 'username': 'chidi_dev', 'avatar': null},
      {'name': 'Fatima Abubakar', 'username': 'fatima_a', 'avatar': null},
      {'name': 'Kemi Adeleke', 'username': 'kemi_foodie', 'avatar': null},
      {'name': 'Emeka Nwosu', 'username': 'emeka_n', 'avatar': null},
    ];

    final mockCommentTexts = [
      'Omo! This food is giving me life! 😍 Where exactly did you buy this from? I need to try it ASAP!',
      'Chai! Look at how the jollof rice is shining ✨ This one na premium jollof o! Chef abeg drop the recipe 👨‍🍳',
      'Why did nobody tell me Obile Ebi was this good? I\'ve been missing out! Going there tomorrow 🏃‍♀️💨',
      'The way this suya is arranged... it\'s giving art vibes! 🎨 But abeg how many pieces for 500 naira?',
      'This amala and ewedu combination is sending me! 🤤 Aunty\'s hand is blessed wallahi!',
      'Bro said the pepper is peppering properly 😂 I can feel the heat from here! But it looks worth it sha',
      'Campus food that actually looks like food? Revolutionary! 👏 What\'s the damage on the pocket though?',
      'The plantain is doing plantain things! 🍌 That golden color is everything! Recipe drop when?',
      'Not me salivating at 11pm looking at this food 😭 Why did you post this when everywhere is closed?',
      'This is why I love our school food scene! Always something new to discover 🔥 Thanks for the recommendation!',
    ];

    final comments = <CommentModel>[];
    final now = DateTime.now();

    for (int i = 0; i < 8; i++) {
      final user = mockUsers[i % mockUsers.length];
      final isAnonymous = i % 4 == 0; // Make some comments anonymous

      comments.add(CommentModel(
        id: 'comment_$i',
        postId: postId,
        userId: 'user_${i % mockUsers.length}',
        content: mockCommentTexts[i % mockCommentTexts.length],
        isAnonymous: isAnonymous,
        createdAt: now.subtract(Duration(
          hours: i * 2,
          minutes: (i * 15) % 60,
        )),
        updatedAt: now.subtract(Duration(
          hours: i * 2,
          minutes: (i * 15) % 60,
        )),
        user: isAnonymous
            ? null
            : UserModel(
                id: 'user_${i % mockUsers.length}',
                email: '${user['username']}@university.edu',
                username: user['username']!,
                displayName: user['name']!,
                avatarUrl: user['avatar'],
                bio: null,
                campus: 'University of Lagos',
                createdAt: now.subtract(const Duration(days: 30)),
                updatedAt: now.subtract(const Duration(days: 1)),
              ),
      ));
    }

    return comments;
  }
}

// Provider
final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
  (ref, postId) => CommentsNotifier()..loadComments(postId),
);