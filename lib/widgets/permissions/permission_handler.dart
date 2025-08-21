import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';
import '../common/premium_button.dart';
import '../common/premium_card.dart';

enum PermissionType {
  camera,
  photos,
  location,
  storage,
}

class PermissionData {
  final String title;
  final String description;
  final String rationale;
  final IconData icon;
  final Color color;

  const PermissionData({
    required this.title,
    required this.description,
    required this.rationale,
    required this.icon,
    required this.color,
  });
}

class PermissionHandler {
  static const Map<PermissionType, PermissionData> _permissionData = {
    PermissionType.camera: PermissionData(
      title: 'Camera Access',
      description: 'To add tasty pics to your posts',
      rationale: 'ChowChat needs camera access to let you capture and share photos of your meals directly from the app.',
      icon: Icons.camera_alt,
      color: AppColors.primary,
    ),
    PermissionType.photos: PermissionData(
      title: 'Photo Library Access',
      description: 'To add photos from your gallery',
      rationale: 'ChowChat needs photo library access to let you select and share existing photos of your meals.',
      icon: Icons.photo_library,
      color: AppColors.accent,
    ),
    PermissionType.location: PermissionData(
      title: 'Location Access',
      description: 'To auto-fill cafeteria location',
      rationale: 'ChowChat can auto-detect nearby cafeterias and dining spots. You can always enter location manually.',
      icon: Icons.location_on,
      color: AppColors.info,
    ),
    PermissionType.storage: PermissionData(
      title: 'Storage Access',
      description: 'To save and cache food photos',
      rationale: 'ChowChat needs storage access to save photos and cache content for offline viewing.',
      icon: Icons.storage,
      color: AppColors.secondary,
    ),
  };

  static Future<bool> requestPermission(
    BuildContext context,
    PermissionType permissionType, {
    bool showRationaleFirst = true,
  }) async {
    final permission = _getPermission(permissionType);
    final permissionData = _permissionData[permissionType]!;

    // Check current status
    final status = await permission.status;
    
    if (status.isGranted) {
      return true;
    }

    // Show rationale first if needed
    if (showRationaleFirst && status.isDenied) {
      final shouldProceed = await _showPermissionRationale(context, permissionData);
      if (!shouldProceed) {
        return false;
      }
    }

    // Request permission
    final result = await permission.request();
    
    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      // Show settings dialog
      await _showPermissionDeniedDialog(context, permissionData);
      return false;
    } else {
      // Show why permission is needed
      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          'Permission denied. ${permissionData.description}',
          isError: true,
        );
      }
      return false;
    }
  }

  static Permission _getPermission(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return Permission.camera;
      case PermissionType.photos:
        return Permission.photos;
      case PermissionType.location:
        return Permission.locationWhenInUse;
      case PermissionType.storage:
        return Permission.storage;
    }
  }

  static Future<bool> _showPermissionRationale(
    BuildContext context,
    PermissionData data,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionRationaleDialog(data: data),
    ) ?? false;
  }

  static Future<void> _showPermissionDeniedDialog(
    BuildContext context,
    PermissionData data,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(data: data),
    );
  }

  // Convenience methods for specific permissions
  static Future<bool> requestCameraPermission(BuildContext context) {
    return requestPermission(context, PermissionType.camera);
  }

  static Future<bool> requestPhotosPermission(BuildContext context) {
    return requestPermission(context, PermissionType.photos);
  }

  static Future<bool> requestLocationPermission(BuildContext context) {
    return requestPermission(context, PermissionType.location);
  }

  static Future<bool> requestStoragePermission(BuildContext context) {
    return requestPermission(context, PermissionType.storage);
  }

  // Check permission status without requesting
  static Future<bool> checkPermission(PermissionType type) async {
    final permission = _getPermission(type);
    final status = await permission.status;
    return status.isGranted;
  }

  // Request multiple permissions
  static Future<Map<PermissionType, bool>> requestMultiplePermissions(
    BuildContext context,
    List<PermissionType> permissions,
  ) async {
    final results = <PermissionType, bool>{};
    
    for (final permissionType in permissions) {
      final granted = await requestPermission(context, permissionType);
      results[permissionType] = granted;
      
      // If user denies, stop asking for more
      if (!granted) break;
    }
    
    return results;
  }
}

class PermissionRationaleDialog extends StatelessWidget {
  final PermissionData data;

  const PermissionRationaleDialog({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius + 4),
      ),
      child: PremiumCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                data.icon,
                size: 32,
                color: data.color,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              data.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Jakarta',
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              data.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Rationale
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.muted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppColors.radius),
              ),
              child: Text(
                data.rationale,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'Inter',
                  color: AppColors.mutedForeground,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: PremiumButton.outline(
                    text: 'Not Now',
                    onPressed: () => Navigator.of(context).pop(false),
                    size: PremiumButtonSize.lg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumButton.primary(
                    text: 'Allow',
                    onPressed: () => Navigator.of(context).pop(true),
                    size: PremiumButtonSize.lg,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionDeniedDialog extends StatelessWidget {
  final PermissionData data;

  const PermissionDeniedDialog({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radius + 4),
      ),
      child: PremiumCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.settings,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'Permission Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Jakarta',
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              'To use this feature, please enable ${data.title.toLowerCase()} in your device settings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: PremiumButton.outline(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    size: PremiumButtonSize.lg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumButton.primary(
                    text: 'Settings',
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                    size: PremiumButtonSize.lg,
                    icon: Icons.settings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Convenience widget for requesting permissions inline
class PermissionGate extends StatefulWidget {
  final PermissionType permission;
  final Widget child;
  final Widget? fallback;
  final bool autoRequest;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.autoRequest = false,
  });

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _hasPermission = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await PermissionHandler.checkPermission(widget.permission);
    
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isChecking = false;
      });
      
      if (!hasPermission && widget.autoRequest) {
        _requestPermission();
      }
    }
  }

  Future<void> _requestPermission() async {
    final granted = await PermissionHandler.requestPermission(context, widget.permission);
    
    if (mounted) {
      setState(() {
        _hasPermission = granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasPermission) {
      return widget.child;
    }

    return widget.fallback ?? _buildDefaultFallback();
  }

  Widget _buildDefaultFallback() {
    final data = PermissionHandler._permissionData[widget.permission]!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              size: 48,
              color: data.color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              data.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Jakarta',
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PremiumButton.primary(
              text: 'Grant Permission',
              onPressed: _requestPermission,
              icon: Icons.security,
            ),
          ],
        ),
      ),
    );
  }
}