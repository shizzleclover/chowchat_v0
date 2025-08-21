import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class Helpers {
  // Format time ago
  static String formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en');
  }

  // Format rating display
  static String formatRating(double? rating) {
    if (rating == null) return 'No rating';
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  // Generate rating stars
  static List<Widget> generateStars(double? rating, {double size = 16}) {
    if (rating == null) return [];
    
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    
    // Full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star,
        size: size,
        color: Colors.amber,
      ));
    }
    
    // Half star
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half,
        size: size,
        color: Colors.amber,
      ));
    }
    
    // Empty stars
    int totalStars = hasHalfStar ? fullStars + 1 : fullStars;
    for (int i = totalStars; i < 5; i++) {
      stars.add(Icon(
        Icons.star_outline,
        size: size,
        color: Colors.grey[400],
      ));
    }
    
    return stars;
  }

  // Format counts (likes, comments)
  static String formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Safe back navigation: pop if possible, else go home
  static void safeBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Get file size in MB
  static double getFileSizeInMB(int sizeInBytes) {
    return sizeInBytes / (1024 * 1024);
  }

  // Check if file size is valid
  static bool isValidImageSize(int sizeInBytes) {
    return getFileSizeInMB(sizeInBytes) <= (10); // 10MB limit
  }

  static bool isValidVideoSize(int sizeInBytes) {
    return getFileSizeInMB(sizeInBytes) <= (50); // 50MB limit
  }

  // Generate anonymous username
  static String generateAnonymousUsername() {
    const adjectives = [
      'Hungry', 'Foodie', 'Tasty', 'Crispy', 'Spicy', 'Sweet', 'Savory',
      'Fresh', 'Yummy', 'Delicious', 'Crunchy', 'Juicy', 'Hot', 'Cold'
    ];
    
    const nouns = [
      'Eater', 'Reviewer', 'Student', 'Explorer', 'Critic', 'Fan',
      'Lover', 'Hunter', 'Seeker', 'Connoisseur'
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch;
    final adjective = adjectives[random % adjectives.length];
    final noun = nouns[(random ~/ 1000) % nouns.length];
    final number = random % 1000;
    
    return '$adjective$noun$number';
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Check if email is from valid campus domain
  static bool isValidCampusEmail(String email) {
    const validDomains = [
      '@student.university.edu',
      '@university.edu',
      // Add more domains as needed
    ];
    
    return validDomains.any((domain) => 
      email.toLowerCase().endsWith(domain.toLowerCase())
    );
  }

  // Extract campus from email
  static String extractCampusFromEmail(String email) {
    final domain = email.split('@').last;
    return domain.split('.').first;
  }
}