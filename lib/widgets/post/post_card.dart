import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';
import '../../routes/app_router.dart';
import '../common/loading_widget.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  @override
  void initState() {
    super.initState();
    // Check if post is liked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likeProvider.notifier).checkLikeStatus(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isLiked = ref.watch(likeProvider)[widget.post.id] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap ?? () {
          AppNavigation.goToPostDetail(context, widget.post.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (widget.post.imageUrls.isNotEmpty || widget.post.videoUrl != null) ...[
                const SizedBox(height: 12),
                _buildMedia(),
              ],
              const SizedBox(height: 12),
              _buildStoreInfo(),
              const SizedBox(height: 12),
              _buildActions(isLiked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final displayName = widget.post.isAnonymous 
        ? 'Anonymous Foodie'
        : (widget.post.user?.displayName ?? widget.post.user?.username ?? 'Unknown User');
    
    final avatarUrl = widget.post.isAnonymous ? null : widget.post.user?.avatarUrl;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: widget.post.isAnonymous 
              ? AppColors.anonymous 
              : AppColors.primary,
          backgroundImage: avatarUrl != null 
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: avatarUrl == null
              ? Icon(
                  widget.post.isAnonymous ? Icons.person_outline : Icons.person,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.post.isAnonymous 
                          ? AppColors.anonymous 
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (widget.post.isAnonymous) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.visibility_off,
                      size: 12,
                      color: AppColors.anonymous,
                    ),
                  ],
                ],
              ),
              Text(
                Helpers.formatTimeAgo(widget.post.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.post.rating != null) _buildRating(),
      ],
    );
  }

  Widget _buildRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ratingFilled.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: AppColors.ratingFilled,
          ),
          const SizedBox(width: 2),
          Text(
            widget.post.rating!.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ratingFilled,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.post.imageUrls.isNotEmpty) {
      return _buildImageCarousel();
    } else if (widget.post.videoUrl != null) {
      return _buildVideoThumbnail();
    }
    return const SizedBox.shrink();
  }

  Widget _buildImageCarousel() {
    if (widget.post.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: widget.post.imageUrls.first,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: AppColors.surfaceVariant,
            child: const LoadingWidget(),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: widget.post.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const LoadingWidget(),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.post.storeName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.post.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.foodDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isLiked) {
    return Row(
      children: [
        _buildActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: Helpers.formatCount(widget.post.likesCount),
          color: isLiked ? AppColors.like : AppColors.textSecondary,
          onTap: _toggleLike,
        ),
        const SizedBox(width: 24),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: Helpers.formatCount(widget.post.commentsCount),
          color: AppColors.textSecondary,
          onTap: () {
            AppNavigation.goToPostDetail(context, widget.post.id);
          },
        ),
        const Spacer(),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: AppColors.textSecondary,
          onTap: _sharePost,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
}