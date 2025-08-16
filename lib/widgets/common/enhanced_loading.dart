import 'package:flutter/material.dart';
import '../../config/app_color.dart';

// Convenience alias
class EnhancedLoading extends EnhancedLoadingWidget {
  const EnhancedLoading({super.key}) : super();
}

class EnhancedLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;
  final LoadingStyle style;

  const EnhancedLoadingWidget({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.style = LoadingStyle.circular,
  });

  const EnhancedLoadingWidget.dots({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  }) : style = LoadingStyle.dots;

  const EnhancedLoadingWidget.pulse({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  }) : style = LoadingStyle.pulse;

  const EnhancedLoadingWidget.skeleton({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  }) : style = LoadingStyle.skeleton;

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    switch (widget.style) {
      case LoadingStyle.dots:
        _animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      case LoadingStyle.pulse:
        _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
        break;
      default:
        _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    }

    _animationController.repeat(reverse: widget.style == LoadingStyle.pulse);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoadingIndicator(),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final color = widget.color ?? AppColors.primary;

    switch (widget.style) {
      case LoadingStyle.circular:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 3,
          ),
        );

      case LoadingStyle.dots:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final progress = (_animation.value + delay) % 1.0;
                final opacity = (Curves.easeInOut.transform(progress) * 0.8) + 0.2;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        );

      case LoadingStyle.pulse:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );

      case LoadingStyle.skeleton:
        return _buildSkeletonLoader();
    }
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        _buildSkeletonLine(width: 200, height: 20),
        const SizedBox(height: 8),
        _buildSkeletonLine(width: 150, height: 16),
        const SizedBox(height: 8),
        _buildSkeletonLine(width: 180, height: 16),
      ],
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [
                AppColors.muted,
                AppColors.muted.withOpacity(0.5),
                AppColors.muted,
              ],
              stops: [
                0.0,
                _animationController.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

enum LoadingStyle {
  circular,
  dots,
  pulse,
  skeleton,
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingStyle style;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.style = LoadingStyle.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.background.withOpacity(0.8),
            child: EnhancedLoadingWidget(
              message: message,
              style: style,
            ),
          ),
      ],
    );
  }
}

class PullToRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: AppColors.card,
      strokeWidth: 3,
      displacement: 60,
      child: child,
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor ?? AppColors.muted,
                widget.highlightColor ?? AppColors.card,
                widget.baseColor ?? AppColors.muted,
              ],
              stops: [
                0.0,
                _animationController.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}