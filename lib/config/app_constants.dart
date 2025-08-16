class AppConstants {
  // App Info
  static const String appName = 'ChowChat';
  static const String appTagline = 'Where Campus Eats Talk 🍜💬';
  
  // Campus Email Domains (for validation)
  static const List<String> validCampusDomains = [
    '@student.university.edu',
    '@university.edu',
    // Add more university domains as needed
  ];
  
  // Feed Configuration
  static const int feedPageSize = 20;
  static const int maxImageUploads = 5;
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  
  // Rating Configuration
  static const double minRating = 1.0;
  static const double maxRating = 5.0;
  
  // Text Limits
  static const int maxPostContentLength = 500;
  static const int maxCommentLength = 200;
  static const int maxUsernameLength = 30;
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 150;
  static const int maxStoreNameLength = 100;
  static const int maxLocationLength = 100;
  static const int maxFoodDescriptionLength = 200;
}