import 'package:flutter/material.dart';
import '../../config/app_color.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states
class EmptyFeedWidget extends StatelessWidget {
  final VoidCallback? onCreatePost;

  const EmptyFeedWidget({super.key, this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.restaurant_menu,
      title: 'No posts yet!',
      message: 'Be the first to share what you\'re eating on campus. Start the conversation!',
      actionText: 'Create First Post',
      onAction: onCreatePost,
    );
  }
}

class EmptyCommentsWidget extends StatelessWidget {
  const EmptyCommentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'No comments yet',
      message: 'Be the first to share your thoughts about this post!',
    );
  }
}

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      message: 'Try adjusting your search terms or explore different food options.',
    );
  }
}