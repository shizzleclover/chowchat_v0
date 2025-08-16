import 'package:flutter/material.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';

enum PremiumButtonVariant {
  primary,
  secondary,
  accent,
  destructive,
  outline,
  ghost,
  link,
}

enum PremiumButtonSize {
  sm,
  md,
  lg,
  xl,
  icon,
}

class PremiumButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final PremiumButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? rightIcon;
  final bool disabled;
  final String? tooltip;

  const PremiumButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  const PremiumButton.primary({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : variant = PremiumButtonVariant.primary;

  const PremiumButton.secondary({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : variant = PremiumButtonVariant.secondary;

  const PremiumButton.outline({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : variant = PremiumButtonVariant.outline;

  const PremiumButton.ghost({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : variant = PremiumButtonVariant.ghost;

  const PremiumButton.destructive({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.size = PremiumButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.rightIcon,
    this.disabled = false,
    this.tooltip,
  }) : variant = PremiumButtonVariant.destructive;

  const PremiumButton.icon({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.variant = PremiumButtonVariant.ghost,
    this.isLoading = false,
    this.disabled = false,
    this.tooltip,
  }) : text = null,
       child = null,
       size = PremiumButtonSize.icon,
       isFullWidth = false,
       rightIcon = null;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final padding = _getPadding();
    final height = _getHeight();
    final isEnabled = !widget.disabled && !widget.isLoading && widget.onPressed != null;

    Widget button = GestureDetector(
      onTapDown: isEnabled ? (_) => _onTapDown() : null,
      onTapUp: isEnabled ? (_) => _onTapUp() : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.size == PremiumButtonSize.icon ? height : null,
              width: widget.isFullWidth ? double.infinity : 
                     widget.size == PremiumButtonSize.icon ? height : null,
              padding: padding,
              decoration: buttonStyle,
              child: _buildContent(textStyle, isEnabled),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent(TextStyle textStyle, bool isEnabled) {
    if (widget.isLoading) {
      return _buildLoadingContent(textStyle);
    }

    if (widget.size == PremiumButtonSize.icon) {
      return Icon(
        widget.icon,
        size: _getIconSize(),
        color: textStyle.color?.withOpacity(isEnabled ? 1.0 : 0.5),
      );
    }

    List<Widget> children = [];

    if (widget.icon != null) {
      children.add(Icon(
        widget.icon,
        size: _getIconSize(),
        color: textStyle.color?.withOpacity(isEnabled ? 1.0 : 0.5),
      ));
      if (widget.text != null || widget.child != null) {
        children.add(SizedBox(width: _getSpacing()));
      }
    }

    if (widget.child != null) {
      children.add(DefaultTextStyle(
        style: textStyle.copyWith(
          color: textStyle.color?.withOpacity(isEnabled ? 1.0 : 0.5),
        ),
        child: widget.child!,
      ));
    } else if (widget.text != null) {
      children.add(Text(
        widget.text!,
        style: textStyle.copyWith(
          color: textStyle.color?.withOpacity(isEnabled ? 1.0 : 0.5),
        ),
      ));
    }

    if (widget.rightIcon != null) {
      if (widget.text != null || widget.child != null) {
        children.add(SizedBox(width: _getSpacing()));
      }
      children.add(Icon(
        widget.rightIcon,
        size: _getIconSize(),
        color: textStyle.color?.withOpacity(isEnabled ? 1.0 : 0.5),
      ));
    }

    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildLoadingContent(TextStyle textStyle) {
    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              textStyle.color ?? AppColors.primaryForeground,
            ),
          ),
        ),
        if (widget.text != null) ...[
          SizedBox(width: _getSpacing()),
          Text(
            widget.text!,
            style: textStyle,
          ),
        ],
      ],
    );
  }

  BoxDecoration _getButtonStyle() {
    Color backgroundColor;
    Color? borderColor;
    List<BoxShadow>? shadows;
    
    final isEnabled = !widget.disabled && !widget.isLoading && widget.onPressed != null;
    final opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        backgroundColor = AppColors.primary.withOpacity(opacity);
        shadows = isEnabled ? AppThemes.shadowSm : null;
        break;
      case PremiumButtonVariant.secondary:
        backgroundColor = AppColors.secondary.withOpacity(opacity);
        break;
      case PremiumButtonVariant.accent:
        backgroundColor = AppColors.accent.withOpacity(opacity);
        break;
      case PremiumButtonVariant.destructive:
        backgroundColor = AppColors.destructive.withOpacity(opacity);
        shadows = isEnabled ? AppThemes.shadowSm : null;
        break;
      case PremiumButtonVariant.outline:
        backgroundColor = Colors.transparent;
        borderColor = AppColors.border.withOpacity(opacity);
        break;
      case PremiumButtonVariant.ghost:
        backgroundColor = _isPressed 
            ? AppColors.muted.withOpacity(0.5)
            : Colors.transparent;
        break;
      case PremiumButtonVariant.link:
        backgroundColor = Colors.transparent;
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppColors.radius),
      border: borderColor != null 
          ? Border.all(color: borderColor, width: 1)
          : null,
      boxShadow: shadows,
    );
  }

  TextStyle _getTextStyle() {
    Color textColor;
    FontWeight fontWeight;
    double fontSize;

    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        textColor = AppColors.primaryForeground;
        break;
      case PremiumButtonVariant.secondary:
        textColor = AppColors.secondaryForeground;
        break;
      case PremiumButtonVariant.accent:
        textColor = AppColors.accentForeground;
        break;
      case PremiumButtonVariant.destructive:
        textColor = AppColors.destructiveForeground;
        break;
      case PremiumButtonVariant.outline:
      case PremiumButtonVariant.ghost:
        textColor = AppColors.foreground;
        break;
      case PremiumButtonVariant.link:
        textColor = AppColors.primary;
        break;
    }

    switch (widget.size) {
      case PremiumButtonSize.sm:
        fontSize = 12;
        fontWeight = FontWeight.w500;
        break;
      case PremiumButtonSize.md:
        fontSize = 14;
        fontWeight = FontWeight.w600;
        break;
      case PremiumButtonSize.lg:
        fontSize = 16;
        fontWeight = FontWeight.w600;
        break;
      case PremiumButtonSize.xl:
        fontSize = 18;
        fontWeight = FontWeight.w600;
        break;
      case PremiumButtonSize.icon:
        fontSize = 14;
        fontWeight = FontWeight.w500;
        break;
    }

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.1,
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case PremiumButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case PremiumButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case PremiumButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      case PremiumButtonSize.xl:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
      case PremiumButtonSize.icon:
        return const EdgeInsets.all(8);
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case PremiumButtonSize.sm:
        return 32;
      case PremiumButtonSize.md:
        return 40;
      case PremiumButtonSize.lg:
        return 48;
      case PremiumButtonSize.xl:
        return 56;
      case PremiumButtonSize.icon:
        return 40;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case PremiumButtonSize.sm:
        return 14;
      case PremiumButtonSize.md:
        return 16;
      case PremiumButtonSize.lg:
        return 18;
      case PremiumButtonSize.xl:
        return 20;
      case PremiumButtonSize.icon:
        return 18;
    }
  }

  double _getSpacing() {
    switch (widget.size) {
      case PremiumButtonSize.sm:
        return 6;
      case PremiumButtonSize.md:
      case PremiumButtonSize.lg:
      case PremiumButtonSize.xl:
        return 8;
      case PremiumButtonSize.icon:
        return 0;
    }
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _onTapUp() {
    _animationController.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    _animationController.reverse();
    setState(() {
      _isPressed = false;
    });
  }
}