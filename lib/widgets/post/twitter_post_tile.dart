import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/post_model.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_color.dart';
import '../../routes/app_router.dart';

class TwitterPostTile extends ConsumerStatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const TwitterPostTile({super.key, required this.post, this.onTap});

  @override
  ConsumerState<TwitterPostTile> createState() => _TwitterPostTileState();
}

class _TwitterPostTileState extends ConsumerState<TwitterPostTile>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.25)
        .animate(CurvedAnimation(parent: _likeController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLiked = ref.watch(likeProvider)[widget.post.id] ?? false;

    if (isLiked) {
      _likeController.forward();
    } else {
      _likeController.reverse();
    }

    return InkWell(
      onTap: widget.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(child: _buildBody(isDark, isLiked)),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = widget.post.isAnonymous ? null : widget.post.user?.avatarUrl;
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.muted.withValues(alpha: 0.4),
      backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
      child: avatarUrl == null
          ? Icon(
              widget.post.isAnonymous ? Icons.person_off_rounded : Icons.person_rounded,
              color: AppColors.mutedForeground,
              size: 20,
            )
          : null,
    );
  }

  Widget _buildBody(bool isDark, bool isLiked) {
    final name = widget.post.isAnonymous
        ? 'Anonymous Foodie'
        : (widget.post.user?.displayName ?? widget.post.user?.username ?? 'User');
    final username = widget.post.isAnonymous ? '' : '@${widget.post.user?.username ?? 'user'}';
    final time = timeago.format(widget.post.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                          ),
                    ),
                    if (username.isNotEmpty) const TextSpan(text: '  '),
                    if (username.isNotEmpty)
                      TextSpan(
                        text: username,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    const TextSpan(text: ' · '),
                    TextSpan(
                      text: time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: _showMore,
              icon: const Icon(Icons.more_horiz_rounded, size: 20),
              color: AppColors.mutedForeground,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (widget.post.content.isNotEmpty)
          Text(
            widget.post.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  height: 1.35,
                ),
          ),
        if (widget.post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildImage(),
        ],
        const SizedBox(height: 8),
        _buildMeta(),
        const SizedBox(height: 8),
        _buildActions(isLiked),
      ],
    );
  }

  Widget _buildImage() {
    final url = widget.post.imageUrls.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      ),
    );
  }

  Widget _buildMeta() {
    // Show store and location like a subtle context line
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        if (widget.post.storeName.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.store_rounded, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text(widget.post.storeName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      )),
            ],
          ),
        if (widget.post.location.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text(widget.post.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      )),
            ],
          ),
      ],
    );
  }

  Widget _buildActions(bool isLiked) {
    final muted = AppColors.mutedForeground;
    return Row(
      children: [
        _iconAction(Icons.chat_bubble_outline_rounded, _onComments, label: '${widget.post.commentsCount}', color: muted),
        const SizedBox(width: 24),
        ScaleTransition(
          scale: _likeScale,
          child: _iconAction(
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            _onLike,
            label: '${widget.post.likesCount}',
            color: isLiked ? Colors.red : muted,
          ),
        ),
        const Spacer(),
        _iconAction(Icons.share_rounded, _onShare, color: muted, label: 'Share'),
      ],
    );
  }

  Widget _iconAction(IconData icon, VoidCallback onTap, {required String label, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  void _onComments() {
    AppNavigation.goToPostDetail(context, widget.post.id);
  }

  Future<void> _onLike() async {
    try {
      await ref.read(likeProvider.notifier).toggleLike(widget.post.id);
      final isLiked = ref.read(likeProvider)[widget.post.id] == true;
      final updated = widget.post.copyWith(
        likesCount: isLiked ? widget.post.likesCount + 1 : widget.post.likesCount - 1,
      );
      ref.read(feedProvider.notifier).updatePost(updated);
    } catch (_) {}
  }

  void _onShare() {}

  void _showMore() {}
}

