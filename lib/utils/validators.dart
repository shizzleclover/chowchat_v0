import '../config/app_constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Campus email validation
  static String? validateCampusEmail(String? value) {
    final emailError = validateEmail(value);
    if (emailError != null) return emailError;
    
    // Check if email domain is in valid campus domains
    final isValidDomain = AppConstants.validCampusDomains.any(
      (domain) => value!.toLowerCase().endsWith(domain.toLowerCase()),
    );
    
    if (!isValidDomain) {
      return 'Please use your university email address';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > AppConstants.maxUsernameLength) {
      return 'Username must be less than ${AppConstants.maxUsernameLength} characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  // Display name validation
  static String? validateDisplayName(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > AppConstants.maxDisplayNameLength) {
        return 'Display name must be less than ${AppConstants.maxDisplayNameLength} characters';
      }
    }
    return null;
  }

  // Bio validation
  static String? validateBio(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > AppConstants.maxBioLength) {
        return 'Bio must be less than ${AppConstants.maxBioLength} characters';
      }
    }
    return null;
  }

  // Post content validation
  static String? validatePostContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Post content is required';
    }
    
    if (value.length > AppConstants.maxPostContentLength) {
      return 'Post content must be less than ${AppConstants.maxPostContentLength} characters';
    }
    
    return null;
  }

  // Store name validation
  static String? validateStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Store name is required';
    }
    
    if (value.length > AppConstants.maxStoreNameLength) {
      return 'Store name must be less than ${AppConstants.maxStoreNameLength} characters';
    }
    
    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.length > AppConstants.maxLocationLength) {
      return 'Location must be less than ${AppConstants.maxLocationLength} characters';
    }
    
    return null;
  }

  // Food description validation
  static String? validateFoodDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Food description is required';
    }
    
    if (value.length > AppConstants.maxFoodDescriptionLength) {
      return 'Food description must be less than ${AppConstants.maxFoodDescriptionLength} characters';
    }
    
    return null;
  }

  // Comment validation
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment cannot be empty';
    }
    
    if (value.length > AppConstants.maxCommentLength) {
      return 'Comment must be less than ${AppConstants.maxCommentLength} characters';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return null; // Rating is optional
    }
    
    if (value < AppConstants.minRating || value > AppConstants.maxRating) {
      return 'Rating must be between ${AppConstants.minRating} and ${AppConstants.maxRating}';
    }
    
    return null;
  }
}