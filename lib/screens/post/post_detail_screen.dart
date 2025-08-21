import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../config/app_color.dart';
import '../../providers/feed_provider.dart';
import '../../providers/comments_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/premium_input.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/enhanced_loading.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../utils/helpers.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String? postId;
  
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> 
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _heartAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _heartAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isAnonymousComment = false;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _heartAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    
    if (widget.postId == null) {
      return _buildErrorState('Post not found', isDark);
    }

    final feedState = ref.watch(feedProvider);
    final List<PostModel> matches = feedState.posts.where((p) => p.id == widget.postId).toList();
    final post = matches.isNotEmpty ? matches.first : null;
    
    if (post == null) {
      return _buildErrorState('Post not found', isDark);
    }

    final commentsState = ref.watch(commentsProvider(widget.postId!));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(isDark),
            _buildPostContent(post, isDark),
            _buildActionBar(post, isDark),
            _buildCommentsSection(commentsState, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildCommentInput(isDark),
    );
  }

  Widget _buildErrorState(String message, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Helpers.safeBack(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton(
              onPressed: () => Helpers.safeBack(context),
              text: 'Go Back',
              variant: PremiumButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => Helpers.safeBack(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
      ),
      title: Text(
        'Post',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showShareBottomSheet();
          },
          icon: Icon(
            Icons.share_rounded,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        IconButton(
          onPressed: () {
            _showMoreOptionsBottomSheet();
          },
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(PostModel post, bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            _buildUserHeader(post, isDark),
            
            // Post Content
            if (post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.content,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.5,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
              ),
            
            // Images
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageCarousel(post.imageUrls),
            ],
            
            // Rating & Location
            const SizedBox(height: 16),
            _buildPostMeta(post, isDark),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(PostModel post, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mutedForeground.withValues(alpha: 0.2),
              image: post.user?.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(post.user!.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: post.user?.avatarUrl == null
                ? Icon(
                    post.isAnonymous ? Icons.person_off_rounded : Icons.person_rounded,
                    color: AppColors.mutedForeground,
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.isAnonymous 
                      ? 'Anonymous Foodie' 
                      : post.user?.displayName ?? 'Unknown User',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                Text(
                  timeago.format(post.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          
          // Anonymous badge
          if (post.isAnonymous)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Anonymous',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostMeta(PostModel post, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating
          if (post.rating != null) ...[
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.rating}/5.0',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Store & Location
          if (post.storeName.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  post.storeName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          
          if (post.location.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.mutedForeground,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  post.location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar(PostModel post, bool isDark) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Like Button
            AnimatedBuilder(
              animation: _heartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          (ref.watch(likeProvider)[post.id] ?? false)
                              ? Icons.favorite_rounded 
                              : Icons.favorite_border_rounded,
                          color: (ref.watch(likeProvider)[post.id] ?? false)
                              ? Colors.red 
                              : AppColors.mutedForeground,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.likesCount}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(width: 32),
            
            // Comment Button
            GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.mutedForeground,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${post.commentsCount}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Share Button
            GestureDetector(
              onTap: _showShareBottomSheet,
              child: Icon(
                Icons.share_rounded,
                color: AppColors.mutedForeground,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(CommentsState commentsState, bool isDark) {
    if (commentsState.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: EnhancedLoading()),
        ),
      );
    }

    if (commentsState.comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share your thoughts!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final comment = commentsState.comments[index];
          return _buildCommentItem(comment, isDark, index);
        },
        childCount: commentsState.comments.length,
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, bool isDark, int index) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 12,
        top: index == 0 ? 16 : 0,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mutedForeground.withValues(alpha: 0.2),
                  image: comment.user?.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(comment.user!.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: comment.user?.avatarUrl == null
                    ? Icon(
                        comment.isAnonymous ? Icons.person_off_rounded : Icons.person_rounded,
                        color: AppColors.mutedForeground,
                        size: 18,
                      )
                    : null,
              ),
              
              const SizedBox(width: 8),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.isAnonymous 
                          ? 'Anonymous' 
                          : comment.user?.displayName ?? 'Unknown User',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Anonymous badge
              if (comment.isAnonymous)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Anon',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Comment Content
          Text(
            comment.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark) {
    final commentsState = ref.watch(commentsProvider(widget.postId!));
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Anonymous toggle
          Row(
            children: [
              Checkbox(
                value: _isAnonymousComment,
                onChanged: (value) {
                  setState(() {
                    _isAnonymousComment = value ?? false;
                  });
                },
                activeColor: AppColors.accent,
              ),
              Text(
                'Post anonymously',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Comment input
          Row(
            children: [
              Expanded(
                child: PremiumInput(
                  controller: _commentController,
                  placeholder: 'Share your thoughts...',
                  maxLines: 3,
                  variant: PremiumInputVariant.outline,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              PremiumButton(
                onPressed: commentsState.isPostingComment || _commentController.text.trim().isEmpty
                    ? null
                    : _postComment,
                isLoading: commentsState.isPostingComment,
                text: 'Post',
                size: PremiumButtonSize.sm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    final postId = widget.postId!;
    ref.read(likeProvider.notifier).toggleLike(postId);
    
    // Animate heart
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });
  }

  void _postComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    ref.read(commentsProvider(widget.postId!).notifier).addComment(
      widget.postId!,
      content,
      _isAnonymousComment,
    );

    _commentController.clear();
    setState(() {
      _isAnonymousComment = false;
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ref.watch(isDarkModeProvider) 
              ? AppColors.darkCard 
              : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedForeground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Post',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Share options would go here
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ref.watch(isDarkModeProvider) 
              ? AppColors.darkCard 
              : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedForeground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Post Options',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Post options would go here
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}