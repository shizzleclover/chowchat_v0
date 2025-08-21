import 'package:flutter/material.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';

enum PremiumCardVariant {
  default_,
  elevated,
  outline,
  ghost,
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final PremiumCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool showBorder;
  final Color? backgroundColor;
  final List<BoxShadow>? customShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.variant = PremiumCardVariant.default_,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
    this.backgroundColor,
    this.customShadow,
  });

  const PremiumCard.elevated({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.customShadow,
  }) : variant = PremiumCardVariant.elevated,
       showBorder = false;

  const PremiumCard.outline({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
  }) : variant = PremiumCardVariant.outline,
       showBorder = true,
       customShadow = null;

  const PremiumCard.ghost({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
  }) : variant = PremiumCardVariant.ghost,
       showBorder = false,
       customShadow = null;

  @override
  Widget build(BuildContext context) {
    final decoration = _getDecoration();
    
    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: card,
        ),
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    Color background;
    List<BoxShadow>? shadows;
    Border? border;

    switch (variant) {
      case PremiumCardVariant.default_:
        background = backgroundColor ?? AppColors.card;
        if (showBorder) {
          border = Border.all(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          );
        }
        break;

      case PremiumCardVariant.elevated:
        background = backgroundColor ?? AppColors.card;
        shadows = customShadow ?? AppThemes.shadowMd;
        break;

      case PremiumCardVariant.outline:
        background = backgroundColor ?? Colors.transparent;
        border = Border.all(
          color: AppColors.border,
          width: 1.5,
        );
        break;

      case PremiumCardVariant.ghost:
        background = backgroundColor ?? AppColors.muted.withOpacity(0.3);
        break;
    }

    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppColors.radius),
      border: border,
      boxShadow: shadows,
    );
  }
}

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double opacity;
  final double blur;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.opacity = 0.1,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(opacity),
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppColors.radius),
          child: card,
        ),
      );
    }

    return card;
  }
}

class PremiumInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final PremiumCardVariant variant;
  final Color? color;

  const PremiumInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.variant = PremiumCardVariant.default_,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: variant,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color ?? AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class PremiumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? trend;
  final bool isPositiveTrend;

  const PremiumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      variant: PremiumCardVariant.elevated,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositiveTrend ? AppColors.success : AppColors.destructive,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPositiveTrend ? AppColors.success : AppColors.destructive,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}