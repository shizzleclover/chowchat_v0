import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/supabase.dart';

// Feed State
class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Feed Provider
class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        posts: [],
        hasMore: true,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return; // Already loading
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final mockPosts = _generateMockPosts(0);

      state = state.copyWith(
        posts: mockPosts,
        isLoading: false,
        hasMore: mockPosts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMorePosts() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final morePosts = _generateMockPosts(state.posts.length);

      state = state.copyWith(
        posts: [...state.posts, ...morePosts],
        isLoadingMore: false,
        hasMore: morePosts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingMore: false,
      );
    }
  }

  Future<void> addPost(PostModel post) async {
    state = state.copyWith(
      posts: [post, ...state.posts],
    );
  }

  Future<void> updatePost(PostModel updatedPost) async {
    final posts = state.posts.map((post) {
      return post.id == updatedPost.id ? updatedPost : post;
    }).toList();

    state = state.copyWith(posts: posts);
  }

  Future<void> removePost(String postId) async {
    final posts = state.posts.where((post) => post.id != postId).toList();
    state = state.copyWith(posts: posts);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  List<PostModel> _generateMockPosts(int offset) {
    final mockUsers = [
      {'name': 'Sarah Johnson', 'username': 'sarah_j'},
      {'name': 'Mike Chen', 'username': 'mike_c'},
      {'name': 'Emily Davis', 'username': 'emily_d'},
      {'name': 'Alex Rodriguez', 'username': 'alex_r'},
      {'name': 'Jessica Kim', 'username': 'jess_k'},
      {'name': 'David Thompson', 'username': 'david_t'},
      {'name': 'Maria Garcia', 'username': 'maria_g'},
      {'name': 'Anonymous Foodie', 'username': 'anonymous'},
    ];

    final mockContent = [
      {'text': 'Guys, this jollof rice at Buka House is sending me to heaven! 😭 The pepper is peppering properly and the rice is rice-ing! Chef abeg what did you put inside? 🍚🔥', 'location': 'Buka House', 'rating': 5},
      {'text': 'Omo! Obile Ebi just served me the best amala and ewedu of my life! 💀 I can\'t feel my legs, this food is too good. Aunty you want to kill me with enjoyment? 🤤', 'location': 'Obile Ebi', 'rating': 5},
      {'text': 'Who said cafeteria food is trash? This fried rice and chicken at Main Cafeteria just made me question everything I know about food 😱 P.S: The plantain is giving what it\'s supposed to give! 🍌', 'location': 'Main Cafeteria', 'rating': 4},
      {'text': 'Buka House suya is not normal! 🌶️ I ordered "small pepper" and now I\'m seeing my ancestors. But will I stop eating? NEVER! 💪', 'location': 'Buka House', 'rating': 5},
      {'text': 'Y\'all sleeping on the pounded yam at Obile Ebi! This thing smooth like baby skin and the egusi soup? CHEF\'S KISS! 👨‍🍳💋 My village people can never! 🍲', 'location': 'Obile Ebi', 'rating': 5},
      {'text': 'Late night vibes at Student Hub! Their indomie and egg combo is basic but it hits different when you\'re broke and hungry 😂 Sometimes simple is supreme! 🍜', 'location': 'Student Hub', 'rating': 4},
      {'text': 'Cafeteria Special jollof today was ELITE! 🏆 No cap, I finished my plate and was eyeing my neighbor\'s own. Food wey go make you forget your name! 😋', 'location': 'Main Cafeteria', 'rating': 5},
      {'text': 'Obile Ebi pepper soup is not for the weak! 🌶️💀 One spoon and I was speaking in tongues. But the fish inside? FRESH! Will definitely come back for punishment 😤', 'location': 'Obile Ebi', 'rating': 4},
      {'text': 'Campus Grills shawarma is the real deal! 🌯 Chicken tender, sauce on point, and the guy even added extra meat without me asking. This is customer service! 🙌', 'location': 'Campus Grills', 'rating': 4},
      {'text': 'Buka House just served me rice and stew that made me call my mom to say thank you for life 😭 This food get spiritual backing! The meat sef plenty like Christmas! 🎄', 'location': 'Buka House', 'rating': 5}
    ];

    final posts = <PostModel>[];
    final now = DateTime.now();

    for (int i = 0; i < 20 && (offset + i) < 50; i++) {
      final userIndex = (offset + i) % mockUsers.length;
      final contentIndex = (offset + i) % mockContent.length;
      final user = mockUsers[userIndex];
      final content = mockContent[contentIndex];
      final isAnonymous = userIndex == 7;

      posts.add(PostModel(
        id: 'mock_post_$offset$i',
        userId: 'mock_user_$userIndex',
        content: content['text'] as String,
        imageUrls: (offset + i) % 3 == 0 ? ['https://picsum.photos/400/300?random=${offset + i}'] : [],
        videoUrl: null,
        location: content['location'] as String,
        rating: (content['rating'] as int).toDouble(),
        storeName: 'Food Vendor ${userIndex + 1}',
        foodDescription: 'Delicious ${content['location']} food',
        isAnonymous: isAnonymous,
        likesCount: 5 + (offset + i) % 25,
        commentsCount: 1 + (offset + i) % 8,
        createdAt: now.subtract(Duration(hours: i + 1, minutes: (offset + i) % 60)),
        updatedAt: now.subtract(Duration(hours: i + 1, minutes: (offset + i) % 60)),
        user: UserModel(
          id: 'mock_user_$userIndex',
          email: '${user['username']}@university.edu',
          displayName: isAnonymous ? null : user['name'] as String,
          username: user['username'] as String,
          campus: 'Demo University',
          bio: isAnonymous ? null : 'Student at Demo University',
          avatarUrl: null,
          createdAt: now.subtract(Duration(days: 30 + userIndex)),
          updatedAt: now.subtract(Duration(days: 1)),
        ),
      ));
    }

    return posts;
  }
}

// Provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});

// Like Provider
class LikeNotifier extends StateNotifier<Map<String, bool>> {
  LikeNotifier() : super({});

  Future<void> toggleLike(String postId) async {
    final isLiked = state[postId] ?? false;
    
    // Optimistic update
    state = {...state, postId: !isLiked};

    try {
      if (isLiked) {
        await SupabaseService.unlikePost(postId);
      } else {
        await SupabaseService.likePost(postId);
      }
    } catch (e) {
      // Revert on error
      state = {...state, postId: isLiked};
      rethrow;
    }
  }

  Future<void> checkLikeStatus(String postId) async {
    try {
      final isLiked = await SupabaseService.isPostLiked(postId);
      state = {...state, postId: isLiked};
    } catch (e) {
      // Handle error silently
    }
  }
}

final likeProvider = StateNotifierProvider<LikeNotifier, Map<String, bool>>((ref) {
  return LikeNotifier();
});