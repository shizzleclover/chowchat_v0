import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

class AppThemes {
  // Design system shadows matching the JSON specification
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.09),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.accent,
      onSecondary: AppColors.accentForeground,
      tertiary: AppColors.secondary,
      onTertiary: AppColors.secondaryForeground,
      surface: AppColors.card,
      onSurface: AppColors.cardForeground,
      background: AppColors.background,
      onBackground: AppColors.foreground,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      surfaceVariant: AppColors.muted,
      onSurfaceVariant: AppColors.mutedForeground,
    ),
    
    // App Bar Theme - Clean and minimal
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.cardForeground,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
        size: 24,
      ),
    ),
    
    // Bottom Navigation Bar Theme - Modern glass effect
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mutedForeground,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Card Theme - Elegant with subtle shadows
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        side: BorderSide(
          color: AppColors.border.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    
    // Input Decoration Theme - Modern and clean
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.muted,
      hintStyle: TextStyle(
        color: AppColors.mutedForeground.withOpacity(0.6),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: AppColors.foreground,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: BorderSide(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: BorderSide(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: const BorderSide(
          color: AppColors.ring,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: const BorderSide(
          color: AppColors.destructive,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: const BorderSide(
          color: AppColors.destructive,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Elevated Button Theme - Premium feel
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(
          AppColors.primaryForeground.withOpacity(0.1),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radius),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.mutedForeground,
      size: 24,
    ),
    
    // Text Theme - Modern typography with Google Fonts
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.foreground,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
        letterSpacing: 0.2,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
        letterSpacing: 0.3,
        height: 1.4,
      ),
    ),
    
    // Floating Action Button Theme - Modern and bold
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.primaryForeground,
      elevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondary,
      labelStyle: const TextStyle(
        color: AppColors.secondaryForeground,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius + 4),
        side: BorderSide(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
        height: 1.5,
      ),
    ),
    
    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: GoogleFonts.inter(
        color: AppColors.cardForeground,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        side: BorderSide(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
  );

  // Dark theme (placeholder for future implementation)
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    // TODO: Implement full dark theme with dark colors
  );
}