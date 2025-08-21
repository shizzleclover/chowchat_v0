import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../routes/app_router.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../utils/image_utils.dart';
import '../../widgets/common/premium_input.dart';
import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_card.dart';
import '../../widgets/common/enhanced_loading.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  
  File? _avatarFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimationController.forward();
    _initializeUserData();
  }

  void _initializeUserData() {
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      // Pre-fill display name from email if available
      final emailName = currentUser.email?.split('@').first;
      if (emailName != null) {
        _displayNameController.text = emailName
            .split('.')
            .map((part) => part.substring(0, 1).toUpperCase() + part.substring(1))
            .join(' ');
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LoadingOverlay(
              isLoading: _isUploading,
              message: 'Setting up your profile...',
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: 32),
                          _buildProfileForm(),
                          const SizedBox(height: 32),
                          _buildCampusInfo(),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text('🎉', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            'Welcome to ChowChat!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Jakarta',
              color: AppColors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          PremiumButton.ghost(
            text: 'Skip for now',
            size: PremiumButtonSize.sm,
            onPressed: _skipSetup,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let\'s set up your profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'Jakarta',
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Add a photo and tell us a bit about yourself. This helps other students connect with you in the food community.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'Inter',
            color: AppColors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return PremiumCard.elevated(
      padding: const EdgeInsets.all(24),
      customShadow: AppThemes.shadowLg,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar picker
            _buildAvatarPicker(),
            const SizedBox(height: 32),
            // Display name
            PremiumInput.filled(
              label: 'Display Name',
              placeholder: 'How should others see you?',
              controller: _displayNameController,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Display name is required';
                if (value!.length < 2) return 'Name must be at least 2 characters';
                return null;
              },
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppColors.primary.withOpacity(0.7),
              ),
              maxLength: 50,
              showCounter: true,
            ),
            const SizedBox(height: 24),
            // Bio (optional)
            PremiumInput.filled(
              label: 'Bio (Optional)',
              placeholder: 'Tell us about your food journey...',
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
              showCounter: true,
              prefixIcon: Icon(
                Icons.description_outlined,
                color: AppColors.primary.withOpacity(0.7),
              ),
              helperText: 'Share your favorite cuisines or food interests',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showAvatarOptions,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: AppThemes.shadowMd,
            ),
            child: _avatarFile != null
                ? ClipOval(
                    child: Image.file(
                      _avatarFile!,
                      width: 94,
                      height: 94,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _avatarFile != null ? 'Tap to change photo' : 'Add profile photo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Inter',
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCampusInfo() {
    final currentUser = ref.read(authProvider).user;
    final campus = currentUser?.email?.split('@').last.split('.').first ?? 'University';

    return PremiumCard.ghost(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school,
              color: AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus: ${campus.substring(0, 1).toUpperCase() + campus.substring(1)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Jakarta',
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified through your student email',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PremiumButton.primary(
          text: 'Complete Setup',
          onPressed: _canSubmit() ? _completeSetup : null,
          isFullWidth: true,
          size: PremiumButtonSize.lg,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),
        Text(
          'You can always update your profile later in settings',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'Inter',
            color: AppColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _displayNameController.text.trim().isNotEmpty;
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.radius + 4),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Profile Photo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Jakarta',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PremiumButton.outline(
                    text: 'Camera',
                    icon: Icons.camera_alt,
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    size: PremiumButtonSize.lg,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PremiumButton.outline(
                    text: 'Gallery',
                    icon: Icons.photo_library,
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    size: PremiumButtonSize.lg,
                  ),
                ),
              ],
            ),
            if (_avatarFile != null) ...[
              const SizedBox(height: 16),
              PremiumButton.ghost(
                text: 'Remove Photo',
                icon: Icons.delete_outline,
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _avatarFile = null;
                  });
                },
                size: PremiumButtonSize.md,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImageUtils.pickImage(source);
      if (pickedFile != null) {
        // Compress the image
        final compressedFile = await ImageUtils.compressImage(File(pickedFile.path));
        setState(() {
          _avatarFile = compressedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to pick image: $e', isError: true);
      }
    }
  }

  Future<void> _completeSetup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? avatarUrl;
      
      // Upload avatar if selected
      if (_avatarFile != null) {
        avatarUrl = await ref.read(authProvider.notifier).uploadAvatar(_avatarFile!);
      }

      // Update user profile
      await ref.read(authProvider.notifier).updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        avatarUrl: avatarUrl,
      );

      // Mark profile setup as completed
      await ref.read(appStateProvider.notifier).markProfileSetupCompleted();

      if (mounted) {
        Helpers.showSnackBar(context, 'Profile setup completed! Welcome to ChowChat! 🎉');
        AppNavigation.goToHome(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to complete setup: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _skipSetup() async {
    // Mark profile setup as completed even if skipped
    await ref.read(appStateProvider.notifier).markProfileSetupCompleted();
    
    if (mounted) {
      AppNavigation.goToHome(context);
    }
  }
}