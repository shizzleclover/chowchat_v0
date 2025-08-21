import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';
import '../../providers/app_state_provider.dart';
import '../common/premium_button.dart';

enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  center,
}

class ContextualTooltip extends ConsumerStatefulWidget {
  final String tooltipId;
  final String title;
  final String message;
  final Widget child;
  final TooltipPosition position;
  final bool showOnFirstRender;
  final Duration? showDelay;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? backgroundColor;
  final Color? textColor;

  const ContextualTooltip({
    super.key,
    required this.tooltipId,
    required this.title,
    required this.message,
    required this.child,
    this.position = TooltipPosition.top,
    this.showOnFirstRender = true,
    this.showDelay,
    this.onAction,
    this.actionText,
    this.backgroundColor,
    this.textColor,
  });

  @override
  ConsumerState<ContextualTooltip> createState() => _ContextualTooltipState();
}

class _ContextualTooltipState extends ConsumerState<ContextualTooltip>
    with TickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  OverlayEntry? _overlayEntry;
  bool _isTooltipVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.showOnFirstRender) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowTooltip();
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Offset _getSlideOffset() {
    switch (widget.position) {
      case TooltipPosition.top:
        return const Offset(0, -0.3);
      case TooltipPosition.bottom:
        return const Offset(0, 0.3);
      case TooltipPosition.left:
        return const Offset(-0.3, 0);
      case TooltipPosition.right:
        return const Offset(0.3, 0);
      case TooltipPosition.center:
        return const Offset(0, 0.2);
    }
  }

  void _checkAndShowTooltip() {
    final hasBeenDismissed = ref.read(tooltipProvider(widget.tooltipId));
    
    if (!hasBeenDismissed && mounted) {
      final delay = widget.showDelay ?? const Duration(milliseconds: 500);
      Future.delayed(delay, () {
        if (mounted) {
          _showTooltip();
        }
      });
    }
  }

  void _showTooltip() {
    if (_isTooltipVisible) return;

    final renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildTooltipOverlay(offset, size),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isTooltipVisible = true;
    _animationController.forward();
  }

  void _hideTooltip({bool dismiss = false}) {
    if (!_isTooltipVisible) return;

    if (dismiss) {
      ref.read(appStateProvider.notifier).dismissTooltip(widget.tooltipId);
    }

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isTooltipVisible = false;
    });
  }

  Widget _buildTooltipOverlay(Offset childOffset, Size childSize) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => _hideTooltip(dismiss: true),
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.3),
          child: Stack(
            children: [
              // Spotlight effect on child widget
              Positioned(
                left: childOffset.dx - 8,
                top: childOffset.dy - 8,
                child: Container(
                  width: childSize.width + 16,
                  height: childSize.height + 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppColors.radius + 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Tooltip bubble
              _buildTooltipBubble(childOffset, childSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipBubble(Offset childOffset, Size childSize) {
    final bubblePosition = _calculateBubblePosition(childOffset, childSize);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: bubblePosition.dx,
          top: bubblePosition.dy,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTooltipContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _calculateBubblePosition(Offset childOffset, Size childSize) {
    const bubbleWidth = 280.0;
    const bubbleHeight = 120.0;
    const spacing = 20.0;

    final screenSize = MediaQuery.of(context).size;

    switch (widget.position) {
      case TooltipPosition.top:
        return Offset(
          (childOffset.dx + childSize.width / 2 - bubbleWidth / 2)
              .clamp(16.0, screenSize.width - bubbleWidth - 16),
          childOffset.dy - bubbleHeight - spacing,
        );
      case TooltipPosition.bottom:
        return Offset(
          (childOffset.dx + childSize.width / 2 - bubbleWidth / 2)
              .clamp(16.0, screenSize.width - bubbleWidth - 16),
          childOffset.dy + childSize.height + spacing,
        );
      case TooltipPosition.left:
        return Offset(
          childOffset.dx - bubbleWidth - spacing,
          (childOffset.dy + childSize.height / 2 - bubbleHeight / 2)
              .clamp(16.0, screenSize.height - bubbleHeight - 16),
        );
      case TooltipPosition.right:
        return Offset(
          childOffset.dx + childSize.width + spacing,
          (childOffset.dy + childSize.height / 2 - bubbleHeight / 2)
              .clamp(16.0, screenSize.height - bubbleHeight - 16),
        );
      case TooltipPosition.center:
        return Offset(
          screenSize.width / 2 - bubbleWidth / 2,
          screenSize.height / 2 - bubbleHeight / 2,
        );
    }
  }

  Widget _buildTooltipContent() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(AppColors.radius + 2),
        boxShadow: AppThemes.shadowLg,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Jakarta',
                    color: widget.textColor ?? AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _hideTooltip(dismiss: true),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.mutedForeground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            widget.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Inter',
              color: widget.textColor?.withOpacity(0.8) ?? AppColors.mutedForeground,
              height: 1.4,
            ),
          ),
          // Action button
          if (widget.onAction != null && widget.actionText != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PremiumButton.ghost(
                    text: 'Got it',
                    onPressed: () => _hideTooltip(dismiss: true),
                    size: PremiumButtonSize.sm,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PremiumButton.primary(
                    text: widget.actionText!,
                    onPressed: () {
                      _hideTooltip(dismiss: true);
                      widget.onAction?.call();
                    },
                    size: PremiumButtonSize.sm,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: PremiumButton.primary(
                text: 'Got it',
                onPressed: () => _hideTooltip(dismiss: true),
                size: PremiumButtonSize.sm,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _childKey,
      onTap: () {
        if (!_isTooltipVisible) {
          _checkAndShowTooltip();
        }
      },
      child: widget.child,
    );
  }
}

// Pre-built tooltip widgets for common use cases
class CreatePostTooltip extends ConsumerWidget {
  final Widget child;

  const CreatePostTooltip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextualTooltip(
      tooltipId: TooltipIds.createFirstPost,
      title: 'Post your first Chow! 🍜',
      message: 'Tap here to share your campus meal and start building the food community.',
      position: TooltipPosition.top,
      actionText: 'Create Post',
      onAction: () {
        // Navigate to create post
      },
      child: child,
    );
  }
}

class LikePostTooltip extends ConsumerWidget {
  final Widget child;

  const LikePostTooltip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextualTooltip(
      tooltipId: TooltipIds.doubleTapToLike,
      title: 'Show some love! ❤️',
      message: 'Tap the heart to like posts. Double-tap for quick likes on posts you love.',
      position: TooltipPosition.bottom,
      child: child,
    );
  }
}

class CommentTooltip extends ConsumerWidget {
  final Widget child;

  const CommentTooltip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextualTooltip(
      tooltipId: TooltipIds.tapToComment,
      title: 'Join the conversation 💬',
      message: 'Tap to comment on posts and share your thoughts about campus food.',
      position: TooltipPosition.bottom,
      child: child,
    );
  }
}

class RefreshTooltip extends ConsumerWidget {
  final Widget child;

  const RefreshTooltip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextualTooltip(
      tooltipId: TooltipIds.swipeToRefresh,
      title: 'Stay fresh! 🔄',
      message: 'Pull down on the feed to refresh and see the latest food posts.',
      position: TooltipPosition.center,
      showDelay: const Duration(seconds: 3),
      child: child,
    );
  }
}

class AnonymousTooltip extends ConsumerWidget {
  final Widget child;

  const AnonymousTooltip({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContextualTooltip(
      tooltipId: TooltipIds.anonymousPosting,
      title: 'Post anonymously 🎭',
      message: 'Toggle this to post without revealing your identity. Perfect for honest reviews!',
      position: TooltipPosition.bottom,
      backgroundColor: AppColors.anonymous.withOpacity(0.1),
      textColor: AppColors.anonymous,
      child: child,
    );
  }
}

// Tooltip manager for coordinating multiple tooltips
class TooltipManager {
  static void showWelcomeSequence(BuildContext context) {
    // Show a sequence of tooltips for new users
    Future.delayed(const Duration(milliseconds: 1000), () {
      _showSequentialTooltips(context, [
        TooltipIds.createFirstPost,
        TooltipIds.doubleTapToLike,
        TooltipIds.tapToComment,
      ]);
    });
  }

  static void _showSequentialTooltips(BuildContext context, List<String> tooltipIds) {
    // Implementation for showing tooltips in sequence
    // This would trigger each tooltip with a delay
  }

  static void resetAllTooltips(WidgetRef ref) {
    // Reset all tooltips (useful for testing or onboarding restart)
    final tooltips = [
      TooltipIds.createFirstPost,
      TooltipIds.doubleTapToLike,
      TooltipIds.tapToComment,
      TooltipIds.swipeToRefresh,
      TooltipIds.anonymousPosting,
    ];

    for (final tooltipId in tooltips) {
      // This would need to be implemented in the app state provider
      // ref.read(appStateProvider.notifier).resetTooltip(tooltipId);
    }
  }
}