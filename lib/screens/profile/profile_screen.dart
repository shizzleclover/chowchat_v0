import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_color.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/post/enhanced_post_card.dart';
import '../../widgets/empty_states/contextual_empty_states.dart';
import '../../widgets/common/premium_button.dart';
import '../../routes/app_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  bool _isOwnProfile = true;
  bool _isFollowing = false;

  // Mock user data
  final Map<String, dynamic> _userStats = {
    'posts': 24,
    'followers': 156,
    'following': 89,
    'likes': 342,
  };

  final List<String> _userPosts = List.generate(12, (index) => 'post_$index');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkIfOwnProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfOwnProfile() {
    final currentUser = ref.read(authProvider).user;
    _isOwnProfile = widget.userId == null || widget.userId == currentUser?.id;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Profile Header
          _buildSliverAppBar(user),
          
          // Profile Info
          _buildProfileInfo(user),
          
          // Stats
          _buildStatsSection(),
          
          // Action Buttons
          _buildActionButtons(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Content
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic user) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: _isOwnProfile 
          ? null 
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
      title: Text(
        _isOwnProfile ? 'Profile' : user.displayName ?? 'User',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
        ),
      ),
      actions: [
        if (_isOwnProfile)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded),
                    SizedBox(width: 12),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(ref.watch(themeProvider) == AppThemeMode.dark
                        ? Icons.light_mode_rounded 
                        : Icons.dark_mode_rounded),
                    const SizedBox(width: 12),
                    Text(ref.watch(themeProvider) == AppThemeMode.dark
                        ? 'Light Mode' 
                        : 'Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          )
        else
          IconButton(
            onPressed: () {
              // Share profile functionality
            },
            icon: const Icon(Icons.share_rounded),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 0.5,
          color: AppColors.lightBorder,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(dynamic user) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.lightCard,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.lightPrimary, AppColors.lightAccent],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: user.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.lightPrimaryForeground,
                        ),
                ),
                if (_isOwnProfile)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.lightCard,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.lightPrimaryForeground,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Name and Username
            Text(
              user.displayName ?? 'User',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username ?? 'username'}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightMutedForeground,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bio
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              Text(
                user.bio!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.lightForeground,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            
            // Join Date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.lightMutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  'Joined March 2024',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.lightCard,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Posts', _userStats['posts']),
            _buildStatItem('Followers', _userStats['followers']),
            _buildStatItem('Following', _userStats['following']),
            _buildStatItem('Likes', _userStats['likes']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return GestureDetector(
      onTap: () {
        // Navigate to relevant screen (followers, following, etc.)
      },
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.lightCard,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          children: [
            if (_isOwnProfile) ...[
              Expanded(
                child: PremiumButton(
                  onPressed: () {
                    context.push('${AppRoutes.home}/profile/edit');
                  },
                  text: 'Edit Profile',
                  variant: PremiumButtonVariant.outline,
                  size: PremiumButtonSize.md,
                ),
              ),
              const SizedBox(width: 12),
              PremiumButton(
                onPressed: () {
                  // Share profile
                },
                child: const Icon(Icons.share_rounded),
                variant: PremiumButtonVariant.outline,
                size: PremiumButtonSize.icon,
              ),
            ] else ...[
              Expanded(
                child: PremiumButton(
                  onPressed: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                    });
                  },
                  text: _isFollowing ? 'Following' : 'Follow',
                  variant: _isFollowing 
                      ? PremiumButtonVariant.outline 
                      : PremiumButtonVariant.primary,
                  size: PremiumButtonSize.md,
                ),
              ),
              const SizedBox(width: 12),
              PremiumButton(
                onPressed: () {
                  // Message user
                },
                child: const Icon(Icons.message_rounded),
                variant: PremiumButtonVariant.outline,
                size: PremiumButtonSize.icon,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppColors.lightPrimary,
          unselectedLabelColor: AppColors.lightMutedForeground,
          indicatorColor: AppColors.lightPrimary,
          indicatorWeight: 2,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.grid_on_rounded),
              text: 'Posts',
            ),
            Tab(
              icon: Icon(Icons.favorite_rounded),
              text: 'Liked',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsGrid(),
          _buildLikedPosts(),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_userPosts.isEmpty) {
      return const ContextualEmptyStates(
        type: EmptyStateType.profile,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        return _buildPostThumbnail(index);
      },
    );
  }

  Widget _buildPostThumbnail(int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to post detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            // Placeholder for post image
            Center(
              child: Icon(
                Icons.restaurant_rounded,
                color: AppColors.lightMutedForeground,
                size: 32,
              ),
            ),
            
            // Post stats overlay
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${12 + index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedPosts() {
    return const Center(
      child: Text(
        'Liked posts will appear here',
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        context.push('${AppRoutes.home}/profile/edit');
        break;
      case 'theme':
        ref.read(themeProvider.notifier).toggleTheme();
        break;
      case 'settings':
        // Navigate to settings
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.lightCard,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}