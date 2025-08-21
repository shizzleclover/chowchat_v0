import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_color.dart';

import '../../widgets/common/premium_button.dart';
import '../../widgets/common/premium_input.dart';
import '../../utils/image_utils.dart';
import '../../routes/app_router.dart';
import '../../providers/post_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _foodDescController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<File> _selectedImages = [];
  File? _selectedVideo;
  int _rating = 0;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _storeController.dispose();
    _foodDescController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ImageUtils.pickMultipleImages(maxImages: 5);
    setState(() {
      _selectedImages = images;
      _selectedVideo = null; // Clear video if images selected
    });
    // propagate to provider
    ref.read(postCreationProvider.notifier).setImages(images);
  }

  Future<void> _pickVideo() async {
    final video = await ImageUtils.pickVideoFromGallery();
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImages.clear(); // Clear images if video selected
      });
      // propagate to provider
      ref.read(postCreationProvider.notifier).setVideo(video);
    }
  }

  Future<void> _submitPost() async {
    final notifier = ref.read(postCreationProvider.notifier);
    notifier.updateContent(_contentController.text.trim());
    notifier.updateStoreName(_storeController.text.trim());
    notifier.updateLocation(_locationController.text.trim());
    notifier.updateFoodDescription(_foodDescController.text.trim());
    notifier.updateRating(_rating > 0 ? _rating.toDouble() : null);
    if (_selectedImages.isNotEmpty) notifier.setImages(_selectedImages);
    if (_selectedVideo != null) notifier.setVideo(_selectedVideo);
    if (_isAnonymous != ref.read(postCreationProvider).isAnonymous) {
      notifier.toggleAnonymous();
    }

    final post = await notifier.submitPost();
    if (post != null && mounted) {
      _showSnackBar('Post created successfully!');
      context.go(AppRoutes.home);
      _clearForm();
    } else {
      final error = ref.read(postCreationProvider).error ?? 'Failed to create post';
      _showSnackBar(error);
    }
  }

  void _clearForm() {
    _contentController.clear();
    _locationController.clear();
    _storeController.clear();
    _foodDescController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedVideo = null;
      _rating = 0;
      _isAnonymous = false;
    });
    ref.read(postCreationProvider.notifier).reset();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postCreationProvider);
    final isLoading = postState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(isLoading),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content Input
                    _buildContentInput(),
                    
                    const SizedBox(height: 20),
                    
                    // Store Name Input
                    _buildStoreInput(),

                    const SizedBox(height: 20),

                    // Media Section
                    _buildMediaSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Location Input
                    _buildLocationInput(),
                    
                    const SizedBox(height: 20),
                    
                    // Food Description
                    _buildFoodDescriptionInput(),

                    const SizedBox(height: 20),

                    // Rating Section
                    _buildRatingSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Anonymous Toggle
                    _buildAnonymousToggle(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Submit Button
            _buildSubmitButton(isLoading),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: isLoading ? null : () {
          // Safe back
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
        icon: const Icon(Icons.close_rounded),
      ),
      title: Text(
        'Create Post',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 0.5,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: PremiumInput(
        controller: _contentController,
        placeholder: "What's on your plate today? Share your food experience...",
        maxLines: 6,
        minLines: 4,
        variant: PremiumInputVariant.filled,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photos or Video',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_selectedImages.isEmpty && _selectedVideo == null)
          _buildMediaSelector()
        else
          _buildSelectedMedia(),
      ],
    );
  }

  Widget _buildMediaSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildMediaOption(
            icon: Icons.photo_library_rounded,
            label: 'Photos',
            onTap: _pickImages,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMediaOption(
            icon: Icons.videocam_rounded,
            label: 'Video',
            onTap: _pickVideo,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMedia() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          _buildImageGrid()
        else if (_selectedVideo != null)
          _buildVideoPreview(),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _selectedVideo = null;
                });
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remove'),
            ),
            const Spacer(),
            if (_selectedImages.isNotEmpty && _selectedImages.length < 5)
              TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Add More'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImages[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_rounded,
              size: 48,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            const SizedBox(height: 8),
            Text(
              'Video Selected',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 8),
        PremiumInput(
          controller: _locationController,
          placeholder: 'Where did you eat? (e.g., Main Cafeteria)',
          prefixIcon: const Icon(Icons.location_on_outlined),
          variant: PremiumInputVariant.filled,
        ),
      ],
    );
  }

  Widget _buildStoreInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store / Vendor Name',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 8),
        PremiumInput(
          controller: _storeController,
          placeholder: 'e.g., Campus Grill, Auntie’s Kitchen',
          prefixIcon: const Icon(Icons.storefront_outlined),
          variant: PremiumInputVariant.filled,
        ),
      ],
    );
  }

  Widget _buildFoodDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food Description',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 8),
        PremiumInput(
          controller: _foodDescController,
          placeholder: 'What did you order? (e.g., Jollof + chicken, 1.5k)',
          maxLines: 3,
          minLines: 2,
          prefixIcon: const Icon(Icons.restaurant_menu_outlined),
          variant: PremiumInputVariant.filled,
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Your Experience',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.lightForeground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Icon(
                index < _rating 
                    ? Icons.star_rounded 
                    : Icons.star_border_rounded,
                size: 32,
                color: index < _rating 
                    ? AppColors.ratingFilled 
                    : AppColors.lightMutedForeground,
              ),
            );
          }),
        ),
        if (_rating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getRatingText(_rating),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.lightMutedForeground,
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor - Not recommended';
      case 2: return 'Fair - Could be better';
      case 3: return 'Good - Worth trying';
      case 4: return 'Very Good - Highly recommended';
      case 5: return 'Excellent - Amazing experience!';
      default: return '';
    }
  }

  Widget _buildAnonymousToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.masks_rounded,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Anonymously',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                Text(
                  'Hide your identity for honest reviews',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
            activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: PremiumButton(
            onPressed: isLoading ? null : _submitPost,
            text: 'Share Post',
            isLoading: isLoading,
            variant: PremiumButtonVariant.primary,
            size: PremiumButtonSize.lg,
          ),
        ),
      ),
    );
  }
}