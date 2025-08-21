import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';

class FavoriteSpotsScreen extends StatefulWidget {
  const FavoriteSpotsScreen({super.key});

  @override
  State<FavoriteSpotsScreen> createState() => _FavoriteSpotsScreenState();
}

class _FavoriteSpotsScreenState extends State<FavoriteSpotsScreen> {
  // Mock favorites list
  final List<Map<String, dynamic>> _favorites = List.generate(8, (i) => {
        'name': 'Spot ${i + 1}',
        'subtitle': 'Popular on campus this week',
      });

  void _unlike(int index) {
    final removed = _favorites.removeAt(index);
    setState(() {});
    Helpers.showSnackBar(context, 'Removed ${removed['name']} from favorites');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Helpers.safeBack(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Favorite Spots',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Text(
                'No favorite spots yet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final item = _favorites[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
                              ),
                            ),
                            Text(
                              item['subtitle'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _unlike(i),
                        icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                        label: const Text('Unlike'),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _favorites.length,
            ),
    );
  }
}

