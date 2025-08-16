import 'package:flutter/material.dart';

class AppColors {
  // Modern Light Theme Colors - Clean and vibrant
  static const Color lightBackground = Color(0xFFFFFBF8); // Warm white
  static const Color lightForeground = Color(0xFF1A1A1A); // Rich black
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white
  static const Color lightCardForeground = Color(0xFF1A1A1A); // Rich black
  static const Color lightPopover = Color(0xFFFFFFFF); // Pure white
  static const Color lightPopoverForeground = Color(0xFF1A1A1A); // Rich black
  static const Color lightPrimary = Color(0xFFFF6B47); // Vibrant orange-red
  static const Color lightPrimaryForeground = Color(0xFFFFFFFF); // Pure white
  static const Color lightSecondary = Color(0xFFF8F9FA); // Light gray
  static const Color lightSecondaryForeground = Color(0xFF495057); // Dark gray
  static const Color lightMuted = Color(0xFFF1F3F4); // Very light gray
  static const Color lightMutedForeground = Color(0xFF6C757D); // Medium gray
  static const Color lightAccent = Color(0xFFFFB84D); // Golden orange
  static const Color lightAccentForeground = Color(0xFF1A1A1A); // Rich black
  static const Color lightDestructive = Color(0xFFDC3545); // Clean red
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF); // Pure white
  static const Color lightBorder = Color(0xFFE9ECEF); // Light border
  static const Color lightInput = Color(0xFFF8F9FA); // Input background
  static const Color lightRing = Color(0xFFFF6B47); // Focus ring
  static const Color lightSidebar = Color(0xFFFFF0EB); // rgb(255, 240, 235)
  static const Color lightSidebarForeground = Color(0xFF3D3436); // rgb(61, 52, 54)
  static const Color lightSidebarPrimary = Color(0xFFFF7E5F); // rgb(255, 126, 95)
  static const Color lightSidebarPrimaryForeground = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color lightSidebarAccent = Color(0xFFFEB47B); // rgb(254, 180, 123)
  static const Color lightSidebarAccentForeground = Color(0xFF3D3436); // rgb(61, 52, 54)
  static const Color lightSidebarBorder = Color(0xFFFFE0D6); // rgb(255, 224, 214)
  static const Color lightSidebarRing = Color(0xFFFF7E5F); // rgb(255, 126, 95)

  // Dark Theme Colors - Following strict design specification
  static const Color darkBackground = Color(0xFF2A2024); // rgb(42, 32, 36)
  static const Color darkForeground = Color(0xFFF2E9E4); // rgb(242, 233, 228)
  static const Color darkCard = Color(0xFF392F35); // rgb(57, 47, 53)
  static const Color darkCardForeground = Color(0xFFF2E9E4); // rgb(242, 233, 228)
  static const Color darkPopover = Color(0xFF392F35); // rgb(57, 47, 53)
  static const Color darkPopoverForeground = Color(0xFFF2E9E4); // rgb(242, 233, 228)
  static const Color darkPrimary = Color(0xFFFF7E5F); // rgb(255, 126, 95)
  static const Color darkPrimaryForeground = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color darkSecondary = Color(0xFF463A41); // rgb(70, 58, 65)
  static const Color darkSecondaryForeground = Color(0xFFF2E9E4); // rgb(242, 233, 228)
  static const Color darkMuted = Color(0xFF392F35); // rgb(57, 47, 53)
  static const Color darkMutedForeground = Color(0xFFD7C6BC); // rgb(215, 198, 188)
  static const Color darkAccent = Color(0xFFFEB47B); // rgb(254, 180, 123)
  static const Color darkAccentForeground = Color(0xFF2A2024); // rgb(42, 32, 36)
  static const Color darkDestructive = Color(0xFFE63946); // rgb(230, 57, 70)
  static const Color darkDestructiveForeground = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color darkBorder = Color(0xFF463A41); // rgb(70, 58, 65)
  static const Color darkInput = Color(0xFF463A41); // rgb(70, 58, 65)
  static const Color darkRing = Color(0xFFFF7E5F); // rgb(255, 126, 95)
  static const Color darkSidebar = Color(0xFF2A2024); // rgb(42, 32, 36)
  static const Color darkSidebarForeground = Color(0xFFF2E9E4); // rgb(242, 233, 228)
  static const Color darkSidebarPrimary = Color(0xFFFF7E5F); // rgb(255, 126, 95)
  static const Color darkSidebarPrimaryForeground = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color darkSidebarAccent = Color(0xFFFEB47B); // rgb(254, 180, 123)
  static const Color darkSidebarAccentForeground = Color(0xFF2A2024); // rgb(42, 32, 36)
  static const Color darkSidebarBorder = Color(0xFF463A41); // rgb(70, 58, 65)
  static const Color darkSidebarRing = Color(0xFFFF7E5F); // rgb(255, 126, 95)

  // Chart Colors (for future analytics features)
  static const Color chart1 = Color(0xFFFF7E5F); // rgb(255, 126, 95)
  static const Color chart2 = Color(0xFFFEB47B); // rgb(254, 180, 123)
  static const Color chart3 = Color(0xFFFFCAA7); // rgb(255, 202, 167)
  static const Color chart4 = Color(0xFFFFAD8F); // rgb(255, 173, 143)
  static const Color chart5 = Color(0xFFCE6A57); // rgb(206, 106, 87)

  // Current theme-aware colors (default to light)
  static const Color background = lightBackground;
  static const Color foreground = lightForeground;
  static const Color card = lightCard;
  static const Color cardForeground = lightCardForeground;
  static const Color popover = lightPopover;
  static const Color popoverForeground = lightPopoverForeground;
  static const Color primary = lightPrimary;
  static const Color primaryForeground = lightPrimaryForeground;
  static const Color secondary = lightSecondary;
  static const Color secondaryForeground = lightSecondaryForeground;
  static const Color muted = lightMuted;
  static const Color mutedForeground = lightMutedForeground;
  static const Color accent = lightAccent;
  static const Color accentForeground = lightAccentForeground;
  static const Color destructive = lightDestructive;
  static const Color destructiveForeground = lightDestructiveForeground;
  static const Color border = lightBorder;
  static const Color input = lightInput;
  static const Color ring = lightRing;
  static const Color sidebar = lightSidebar;
  static const Color sidebarForeground = lightSidebarForeground;
  static const Color sidebarPrimary = lightSidebarPrimary;
  static const Color sidebarPrimaryForeground = lightSidebarPrimaryForeground;
  static const Color sidebarAccent = lightSidebarAccent;
  static const Color sidebarAccentForeground = lightSidebarAccentForeground;
  static const Color sidebarBorder = lightSidebarBorder;
  static const Color sidebarRing = lightSidebarRing;

  // Legacy aliases for backward compatibility
  static const Color surface = card;
  static const Color surfaceVariant = muted;
  static const Color textPrimary = foreground;
  static const Color textSecondary = mutedForeground;
  static const Color textHint = mutedForeground;
  static const Color textOnPrimary = primaryForeground;
  static const Color error = destructive;
  static const Color success = Color(0xFF22C55E); // Green for success states
  static const Color warning = Color(0xFFF59E0B); // Amber for warnings
  static const Color info = Color(0xFF3B82F6); // Blue for info
  
  // Interactive Colors
  static const Color like = destructive; // Use destructive color for likes (heart)
  static const Color comment = mutedForeground; // Muted for comments
  static const Color share = accent; // Accent color for sharing
  
  // Rating Colors
  static const Color ratingFilled = Color(0xFFFBBF24); // Golden yellow for filled stars
  static const Color ratingEmpty = mutedForeground; // Muted for empty stars
  
  // Anonymous Mode
  static const Color anonymous = Color(0xFF8B5A3C); // Warm brown for anonymous posts
  
  // Divider
  static const Color divider = border;

  // Design System Values
  static const double radius = 10.0; // 0.625rem = 10px
  static const double spacing = 4.0; // 0.25rem = 4px
}