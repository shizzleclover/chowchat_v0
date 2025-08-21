import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../widgets/common/premium_input.dart';

import '../../widgets/common/enhanced_loading.dart';
import '../../widgets/empty_states/contextual_empty_states.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  final List<String> _categories = [
    'All',
    'Pizza', 
    'Burgers',
    'Asian',
    'Healthy',
    'Desserts',
    'Drinks',
  ];

  int _selectedCategoryIndex = 0;
  bool _isSearching = false;
  final List<String> _recentSearches = [
    'Jollof Rice',
    'Chicken Shawarma', 
    'Local Restaurant',
    'Cafeteria Food',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(),
                  _buildPeopleTab(),
                  _buildPlacesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          PremiumInput(
            controller: _searchController,
            placeholder: 'Search for food, places, or people...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                    ),
                  )
                : null,
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
            },
            variant: PremiumInputVariant.filled,
          ),
          
          const SizedBox(height: 16),
          
          // Category Filter
          if (!_isSearching) _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    : (isDark ? AppColors.darkSecondary : AppColors.lightSecondary),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 1,
                ),
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? (isDark ? AppColors.darkPrimaryForeground : AppColors.lightPrimaryForeground)
                      : (isDark ? AppColors.darkSecondaryForeground : AppColors.lightSecondaryForeground),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: TabBar(
        controller: _tabController,
        labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        unselectedLabelColor: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
        indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
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
          Tab(text: 'Posts'),
          Tab(text: 'People'),
          Tab(text: 'Places'),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isSearching && _searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }
    
    return _buildDiscoverContent();
  }

  Widget _buildPeopleTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Placeholder
      itemBuilder: (context, index) {
        return _buildPersonItem(index);
      },
    );
  }

  Widget _buildPlacesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Placeholder
      itemBuilder: (context, index) {
        return _buildPlaceItem(index);
      },
    );
  }

  Widget _buildSearchResults() {
    // Simulate search results
    return const Center(
      child: const EnhancedLoading(),
    );
  }

  Widget _buildDiscoverContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return _buildRecentSearchChip(search);
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Trending
          Text(
            'Trending Now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 12),
          _buildTrendingGrid(),
          
          const SizedBox(height: 24),
          
          // Popular Posts
          Text(
            'Popular This Week',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 12),
          // Placeholder for popular posts
          const ContextualEmptyStates(
            type: EmptyStateType.search,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String search) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 16,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
          const SizedBox(width: 6),
          Text(
            search,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildTrendingItem(index);
      },
    );
  }

  Widget _buildTrendingItem(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendingItems = [
      'Pizza Night',
      'Healthy Bowls',
      'Coffee & Chill',
      'Street Food',
      'Dessert Hunt',
      'Breakfast Club',
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [AppColors.darkPrimary, AppColors.darkAccent] : [AppColors.lightPrimary, AppColors.lightAccent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTrendingIcon(index),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trendingItems[index],
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTrendingIcon(int index) {
    final icons = [
      Icons.local_pizza_rounded,
      Icons.eco_rounded,
      Icons.coffee_rounded,
      Icons.local_dining_rounded,
      Icons.cake_rounded,
      Icons.breakfast_dining_rounded,
    ];
    return icons[index % icons.length];
  }

  Widget _buildPersonItem(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
            child: Icon(
              Icons.person_rounded,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User $index',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@user$index • ${index + 5} posts',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Follow',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceItem(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final places = [
      'Main Cafeteria',
      'Student Union Food Court',
      'Library Café',
      'Sports Center Grill',
      'Campus Pizza Corner',
      'Healthy Bites',
      'Quick Snacks',
      'Coffee House',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  places[index],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.ratingFilled,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.${5 + index % 4}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${20 + index * 5} reviews',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
          ),
        ],
      ),
    );
  }
}