import 'package:flutter/material.dart';
import '../../config/app_color.dart';
import '../common/premium_button.dart';
import '../common/premium_card.dart';

class EnhancedEmptyState extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool showCard;

  const EnhancedEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.showCard = true,
  });

  @override
  State<EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<EnhancedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: widget.showCard ? _buildCardContent() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return PremiumCard.ghost(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(32),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIllustration(),
        const SizedBox(height: 24),
        _buildTitle(),
        const SizedBox(height: 12),
        _buildMessage(),
        if (widget.actionText != null && widget.onAction != null) ...[
          const SizedBox(height: 32),
          _buildAction(),
        ],
      ],
    );
  }

  Widget _buildIllustration() {
    if (widget.illustration != null) {
      return widget.illustration!;
    }

    if (widget.icon != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (widget.iconColor ?? AppColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: 64,
          color: widget.iconColor ?? AppColors.primary,
        ),
      );
    }

    return _buildDefaultIllustration();
  }

  Widget _buildDefaultIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Icon(
        Icons.inbox_outlined,
        size: 48,
        color: AppColors.primary.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.foreground,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Text(
        widget.message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedForeground,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAction() {
    return PremiumButton.primary(
      text: widget.actionText!,
      onPressed: widget.onAction,
      size: PremiumButtonSize.lg,
    );
  }
}

// Predefined enhanced empty states
class EnhancedEmptyFeed extends StatelessWidget {
  final VoidCallback? onCreatePost;

  const EnhancedEmptyFeed({super.key, this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      title: 'No posts yet!',
      message: 'Be the first to share what you\'re eating on campus. Start the conversation and discover amazing food together!',
      illustration: _buildFoodIllustration(),
      actionText: 'Create First Post',
      onAction: onCreatePost,
    );
  }

  Widget _buildFoodIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text('🍕', style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            top: 30,
            right: 15,
            child: Text('🍔', style: TextStyle(fontSize: 20)),
          ),
          Positioned(
            bottom: 25,
            left: 15,
            child: Text('🌮', style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Text('🍜', style: TextStyle(fontSize: 26)),
          ),
          Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 32,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedEmptyComments extends StatelessWidget {
  const EnhancedEmptyComments({super.key});

  @override
  Widget build(BuildContext context) {
    return const EnhancedEmptyState(
      title: 'No comments yet',
      message: 'Be the first to share your thoughts about this delicious post!',
      icon: Icons.chat_bubble_outline,
      iconColor: AppColors.accent,
      showCard: false,
    );
  }
}

class EnhancedEmptySearch extends StatelessWidget {
  final String? searchQuery;

  const EnhancedEmptySearch({super.key, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      title: 'No results found',
      message: searchQuery != null
          ? 'No posts found for "$searchQuery". Try adjusting your search terms or explore different food options.'
          : 'Try adjusting your search terms or explore different food options.',
      icon: Icons.search_off,
      iconColor: AppColors.mutedForeground,
      showCard: false,
    );
  }
}

class EnhancedErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const EnhancedErrorState({
    super.key,
    this.title = 'Oops! Something went wrong',
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      title: title,
      message: message,
      icon: Icons.error_outline,
      iconColor: AppColors.destructive,
      actionText: retryText ?? 'Try Again',
      onAction: onRetry,
    );
  }
}

class EnhancedOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const EnhancedOfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      title: 'You\'re offline',
      message: 'Check your internet connection and try again to see the latest food posts.',
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      actionText: 'Retry',
      onAction: onRetry,
    );
  }
}