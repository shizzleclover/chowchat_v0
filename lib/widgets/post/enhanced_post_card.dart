import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';
import '../../utils/helpers.dart';
import '../../routes/app_router.dart';
import '../common/premium_card.dart';
import '../common/premium_button.dart';

class EnhancedPostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final bool showFullContent;

  const EnhancedPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showFullContent = false,
  });

  @override
  ConsumerState<EnhancedPostCard> createState() => _EnhancedPostCardState();
}

class _EnhancedPostCardState extends ConsumerState<EnhancedPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<Color?> _likeColorAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    _likeColorAnimation = ColorTween(
      begin: AppColors.mutedForeground,
      end: AppColors.like,
    ).animate(_likeAnimationController);

    // Check if post is liked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeProvider.notifier).checkLikeStatus(widget.post.id);
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isLiked = ref.watch(likeProvider)[widget.post.id] ?? false;

    // Trigger animation when like state changes
    if (isLiked) {
      _likeAnimationController.forward();
    } else {
      _likeAnimationController.reverse();
    }

    return PremiumCard.elevated(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      onTap: widget.onTap ?? () {
        AppNavigation.goToPostDetail(context, widget.post.id);
      },
      customShadow: AppThemes.shadowSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (widget.post.imageUrls.isNotEmpty || widget.post.videoUrl != null)
            _buildMedia(),
          _buildStoreInfo(),
          _buildActions(isLiked),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final displayName = widget.post.isAnonymous 
        ? 'Anonymous Foodie'
        : (widget.post.user?.displayName ?? widget.post.user?.username ?? 'Unknown User');
    
    final avatarUrl = widget.post.isAnonymous ? null : widget.post.user?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.post.isAnonymous 
                    ? AppColors.anonymous.withOpacity(0.3)
                    : AppColors.border.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: widget.post.isAnonymous 
                  ? AppColors.anonymous.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              backgroundImage: avatarUrl != null 
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Icon(
                      widget.post.isAnonymous ? Icons.person_outline : Icons.person,
                      color: widget.post.isAnonymous 
                          ? AppColors.anonymous 
                          : AppColors.primary,
                      size: 22,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: widget.post.isAnonymous 
                              ? AppColors.anonymous 
                              : AppColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.post.isAnonymous) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.anonymous.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_off,
                              size: 10,
                              color: AppColors.anonymous,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'ANON',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.anonymous,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      Helpers.formatTimeAgo(widget.post.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                    if (widget.post.rating != null) ...[
                      const SizedBox(width: 8),
                      _buildRatingChip(),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PremiumButton.icon(
            icon: Icons.more_horiz,
            variant: PremiumButtonVariant.ghost,
            onPressed: () => _showPostOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.ratingFilled.withOpacity(0.1),
            AppColors.ratingFilled.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.ratingFilled.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: AppColors.ratingFilled,
          ),
          const SizedBox(width: 3),
          Text(
            widget.post.rating!.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ratingFilled,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = widget.post.content;
    final shouldTruncate = !widget.showFullContent && content.length > 200;
    final displayContent = shouldTruncate 
        ? '${content.substring(0, 200)}...' 
        : content;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayContent,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.foreground,
              height: 1.4,
              letterSpacing: 0.1,
            ),
          ),
          if (shouldTruncate) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.onTap ?? () {
                AppNavigation.goToPostDetail(context, widget.post.id);
              },
              child: Text(
                'Read more',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: widget.post.imageUrls.isNotEmpty
          ? _buildImageCarousel()
          : _buildVideoThumbnail(),
    );
  }

  Widget _buildImageCarousel() {
    if (widget.post.imageUrls.length == 1) {
      return _buildSingleImage(widget.post.imageUrls.first);
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: widget.post.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildSingleImage(widget.post.imageUrls[index]),
          );
        },
      ),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radius),
        boxShadow: AppThemes.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppColors.radius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppColors.radius),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppColors.radius),
            ),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.mutedForeground,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppColors.radius),
        boxShadow: AppThemes.shadowSm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radius),
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.black54,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              size: 48,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: PremiumCard.ghost(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.store,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.post.storeName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.post.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.foodDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.foreground,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(bool isLiked) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: Helpers.formatCount(widget.post.likesCount),
            color: isLiked ? AppColors.like : AppColors.mutedForeground,
            onTap: _toggleLike,
            isAnimated: true,
          ),
          const SizedBox(width: 24),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: Helpers.formatCount(widget.post.commentsCount),
            color: AppColors.mutedForeground,
            onTap: () {
              AppNavigation.goToPostDetail(context, widget.post.id);
            },
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            color: AppColors.mutedForeground,
            onTap: _sharePost,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isAnimated = false,
  }) {
    Widget iconWidget = Icon(icon, size: 20, color: color);
    
    if (isAnimated) {
      iconWidget = AnimatedBuilder(
        animation: _likeAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _likeScaleAnimation.value,
            child: Icon(
              icon,
              size: 20,
              color: _likeColorAnimation.value,
            ),
          );
        },
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    try {
      await ref.read(likeProvider.notifier).toggleLike(widget.post.id);
      
      // Update post likes count optimistically
      final updatedPost = widget.post.copyWith(
        likesCount: ref.read(likeProvider)[widget.post.id] == true
            ? widget.post.likesCount + 1
            : widget.post.likesCount - 1,
      );
      
      ref.read(feedProvider.notifier).updatePost(updatedPost);
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update like', isError: true);
      }
    }
  }

  void _sharePost() {
    // Implement share functionality
    Helpers.showSnackBar(context, 'Share functionality coming soon!');
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.radius + 4),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.bookmark_border, color: AppColors.mutedForeground),
              title: Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                // Implement save functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.destructive),
              title: Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}