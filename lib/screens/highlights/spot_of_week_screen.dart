import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';

class SpotOfWeekScreen extends StatefulWidget {
  const SpotOfWeekScreen({super.key});

  @override
  State<SpotOfWeekScreen> createState() => _SpotOfWeekScreenState();
}

class _SpotOfWeekScreenState extends State<SpotOfWeekScreen> {
  final List<Map<String, dynamic>> _spots = [
    {'name': 'Campus Grill', 'rating': 4.7, 'votes': 60},
    {'name': 'Auntie’s Kitchen', 'rating': 4.5, 'votes': 48},
    {'name': 'Chef’s Corner', 'rating': 4.3, 'votes': 37},
  ];

  final TextEditingController _nameController = TextEditingController();

  void _vote(int index) {
    setState(() {
      _spots[index]['votes'] = (_spots[index]['votes'] as int) + 1;
    });
  }

  void _addSpot() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _spots.add({'name': name, 'rating': 4.0, 'votes': 1});
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._spots]..sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
    final winner = sorted.first;
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
          'Spot of the Week',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Winner card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.store_mall_directory_rounded, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Leader', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground)),
                        Text(winner['name'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkForeground : AppColors.lightForeground)),
                        Row(children: const [Icon(Icons.star_rounded, color: Colors.amber, size: 16), SizedBox(width: 4), Text('4.7')]),
                      ],
                    ),
                  ),
                  _voteChip(winner['votes']),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Nomination form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nominate a Spot', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.storefront_outlined),
                      hintText: 'Spot name (e.g., Campus Grill)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addSpot,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nominate'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Spots list
            Column(
              children: List.generate(sorted.length, (i) {
                final s = sorted[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.place_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['name'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkForeground : AppColors.lightForeground)),
                            Row(children: const [Icon(Icons.star_rounded, size: 14, color: Colors.amber), SizedBox(width: 4), Text('4.5')]),
                          ],
                        ),
                      ),
                      _voteChip(s['votes']),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _vote(_spots.indexOf(s)),
                        child: const Text('Vote'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _voteChip(int votes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.how_to_vote_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 6),
          Text('$votes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

