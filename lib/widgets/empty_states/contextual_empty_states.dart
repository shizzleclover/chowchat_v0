import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../config/app_themes.dart';
import '../../routes/app_router.dart';
import '../common/premium_button.dart';
import '../common/premium_card.dart';

// Empty state types enum
enum EmptyStateType {
  feed,
  profile,
  search,
  notifications,
}

// Main contextual empty states widget
class ContextualEmptyStates extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;
  
  const ContextualEmptyStates({
    super.key,
    required this.type,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case EmptyStateType.feed:
        return EmptyFeedState(onCreatePost: onAction);
      case EmptyStateType.profile:
        return EmptyProfileState(onCreatePost: onAction);
      case EmptyStateType.search:
        return EmptySearchState();
      case EmptyStateType.notifications:
        return EmptyNotificationsState();
    }
  }
}

// Empty states specifically for ChowChat features
class EmptyFeedState extends ConsumerWidget {
  final bool isFirstTime;
  final VoidCallback? onCreatePost;

  const EmptyFeedState({
    super.key,
    this.isFirstTime = false,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildIllustration(),
          const SizedBox(height: 32),
          _buildContent(context),
          const SizedBox(height: 32),
          _buildActions(context),
          if (isFirstTime) ...[
            const SizedBox(height: 40),
            _buildTipsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main illustration
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🍽️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Icon(
                  Icons.add_circle_outline,
                  size: 32,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          // Floating food emojis
          Positioned(
            top: 20,
            left: 30,
            child: _buildFloatingFood('🍕', 0.0),
          ),
          Positioned(
            top: 30,
            right: 25,
            child: _buildFloatingFood('🍔', 0.5),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: _buildFloatingFood('🌮', 1.0),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: _buildFloatingFood('🍜', 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingFood(String emoji, double delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 2000 + (delay * 500).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -10 + (10 * (0.5 + 0.5 * (value % 1.0)))),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemes.shadowSm,
            ),
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Text(
          isFirstTime ? 'Welcome to ChowChat!' : 'No posts yet today',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'Jakarta',
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            isFirstTime 
                ? 'Be the first to share what you\'re eating on campus. Start the conversation and help build our food community!'
                : 'Your campus food community is quiet today. Share what you\'re eating to get the conversation started!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Inter',
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        PremiumButton.primary(
          text: 'Share Your First Meal',
          icon: Icons.add_circle,
          onPressed: onCreatePost ?? () => AppNavigation.goToCreatePost(context),
          size: PremiumButtonSize.lg,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PremiumButton.ghost(
              text: 'Refresh Feed',
              icon: Icons.refresh,
              onPressed: () {
                // Refresh logic
              },
              size: PremiumButtonSize.md,
            ),
            const SizedBox(width: 16),
            PremiumButton.ghost(
              text: 'Invite Friends',
              icon: Icons.person_add,
              onPressed: () {
                // Share app logic
              },
              size: PremiumButtonSize.md,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return PremiumCard.ghost(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Getting Started Tips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTip('📸', 'Take photos of your meals', 'Visual posts get more engagement'),
          const SizedBox(height: 12),
          _buildTip('📍', 'Tag the location', 'Help others find great spots'),
          const SizedBox(height: 12),
          _buildTip('⭐', 'Rate honestly', 'Your reviews help the community'),
          const SizedBox(height: 12),
          _buildTip('🎭', 'Use anonymous mode', 'For honest feedback without judgment'),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyProfileState extends ConsumerWidget {
  final bool isOwnProfile;
  final String? userName;
  final VoidCallback? onCreatePost;

  const EmptyProfileState({
    super.key,
    this.isOwnProfile = true,
    this.userName,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildIllustration(),
          const SizedBox(height: 32),
          _buildContent(context),
          const SizedBox(height: 32),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text('📖', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final title = isOwnProfile 
        ? 'Your food diary starts here'
        : '${userName ?? 'This user'} hasn\'t posted yet';
    
    final subtitle = isOwnProfile
        ? 'Share your campus food experiences and build your culinary profile!'
        : 'Follow them to see their future food adventures.';

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: 'Jakarta',
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Inter',
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (isOwnProfile) {
      return Column(
        children: [
          PremiumButton.primary(
            text: 'Create Your First Post',
            icon: Icons.add_photo_alternate,
            onPressed: () => AppNavigation.goToCreatePost(context),
            size: PremiumButtonSize.lg,
          ),
          const SizedBox(height: 16),
          PremiumButton.outline(
            text: 'Edit Profile',
            icon: Icons.edit,
            onPressed: () => AppNavigation.goToEditProfile(context),
            size: PremiumButtonSize.md,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PremiumButton.primary(
            text: 'Follow',
            icon: Icons.person_add,
            onPressed: () {
              // Follow user logic
            },
            size: PremiumButtonSize.md,
          ),
          const SizedBox(width: 16),
          PremiumButton.outline(
            text: 'Message',
            icon: Icons.message,
            onPressed: () {
              // Message user logic
            },
            size: PremiumButtonSize.md,
          ),
        ],
      );
    }
  }
}

class EmptySearchState extends ConsumerWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuery = searchQuery?.isNotEmpty == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildIllustration(hasQuery),
          const SizedBox(height: 32),
          _buildContent(context, hasQuery),
          const SizedBox(height: 32),
          _buildSuggestions(context),
        ],
      ),
    );
  }

  Widget _buildIllustration(bool hasQuery) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.mutedForeground.withValues(alpha: 0.1),
            AppColors.mutedForeground.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mutedForeground.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              hasQuery ? Icons.search_off : Icons.search,
              size: 48,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasQuery) {
    final title = hasQuery 
        ? 'No results found'
        : 'Start searching';
    
    final subtitle = hasQuery
        ? 'Try different keywords or browse suggested searches below.'
        : 'Search for dishes, cafeterias, or food types to discover campus eats.';

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: 'Jakarta',
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Inter',
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (hasQuery && onClearSearch != null) ...[
          const SizedBox(height: 20),
          PremiumButton.outline(
            text: 'Clear Search',
            icon: Icons.clear,
            onPressed: onClearSearch,
            size: PremiumButtonSize.md,
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestions = [
      {'emoji': '🍕', 'text': 'Pizza', 'tag': 'pizza'},
      {'emoji': '🍔', 'text': 'Burgers', 'tag': 'burger'},
      {'emoji': '🌮', 'text': 'Tacos', 'tag': 'taco'},
      {'emoji': '🍜', 'text': 'Noodles', 'tag': 'noodles'},
      {'emoji': '🥗', 'text': 'Salads', 'tag': 'salad'},
      {'emoji': '☕', 'text': 'Coffee', 'tag': 'coffee'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Jakarta',
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                // Perform search with suggestion
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggestion['emoji']!,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion['text']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class EmptyCommentsState extends ConsumerWidget {
  const EmptyCommentsState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No comments yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Jakarta',
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              'Be the first to share your thoughts about this delicious post!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Inter',
                color: AppColors.mutedForeground,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}



// Empty Notifications State
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.lightMutedForeground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When people interact with your posts,\nyou\'ll see notifications here.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.lightMutedForeground.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}