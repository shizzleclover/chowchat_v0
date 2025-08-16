import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_color.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/post/twitter_post_tile.dart';
import '../../widgets/common/enhanced_loading.dart';
import '../../widgets/empty_states/contextual_empty_states.dart';
import '../../routes/app_router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).loadFeed();
    });
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMorePosts();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(feedProvider.notifier).loadFeed(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final feedState = ref.watch(feedProvider);
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          // App Bar
          _buildSliverAppBar(authState.user?.displayName ?? 'User'),
          
          // Top divider under app bar
          SliverToBoxAdapter(child: SizedBox(height: 4)),
          
          // Posts Feed
          if (feedState.isLoading && feedState.posts.isEmpty)
            const SliverFillRemaining(
              child: EnhancedLoading(),
            )
          else if (feedState.posts.isEmpty)
            const SliverFillRemaining(
              child: ContextualEmptyStates(
                type: EmptyStateType.feed,
              ),
            )
          else
            _buildPostsList(feedState),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(String userName) {
    final isDark = ref.watch(isDarkModeProvider);
    
    return SliverAppBar(
      floating: true,
      snap: true,
      centerTitle: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Home',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _buildStoriesSection() { return const SliverToBoxAdapter(child: SizedBox.shrink()); }

  Widget _buildAddStoryItem() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightMuted,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.lightBorder,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.lightMutedForeground,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Story',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightPrimary, AppColors.lightAccent],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightCard,
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  color: AppColors.lightMuted,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.lightMutedForeground,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'User $index',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.lightMutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(FeedState feedState) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < feedState.posts.length) {
            final post = feedState.posts[index];
            return TwitterPostTile(
              post: post,
            );
          } else if (feedState.isLoading) {
            // Loading indicator at bottom
            return Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return null;
        },
        childCount: feedState.posts.length + (feedState.isLoading ? 1 : 0),
      ),
    );
  }
}