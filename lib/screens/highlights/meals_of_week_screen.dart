import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_color.dart';
import '../../utils/helpers.dart';

class MealsOfWeekScreen extends StatefulWidget {
  const MealsOfWeekScreen({super.key});

  @override
  State<MealsOfWeekScreen> createState() => _MealsOfWeekScreenState();
}

class _MealsOfWeekScreenState extends State<MealsOfWeekScreen> {
  // Mock data for nominations and votes
  final List<Map<String, dynamic>> _nominations = [
    {
      'title': 'Jollof Rice + Chicken',
      'spot': 'Campus Grill',
      'votes': 42,
    },
    {
      'title': 'Shawarma',
      'spot': 'Auntie’s Kitchen',
      'votes': 35,
    },
    {
      'title': 'Spaghetti & Turkey',
      'spot': 'Chef’s Corner',
      'votes': 28,
    },
  ];

  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _spotController = TextEditingController();

  void _vote(int index) {
    setState(() {
      _nominations[index]['votes'] = (_nominations[index]['votes'] as int) + 1;
    });
  }

  void _addNomination() {
    final meal = _mealController.text.trim();
    final spot = _spotController.text.trim();
    if (meal.isEmpty || spot.isEmpty) return;

    setState(() {
      _nominations.add({'title': meal, 'spot': spot, 'votes': 1});
      _mealController.clear();
      _spotController.clear();
    });
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
        title: Text(
          'Meals of the Week',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkForeground : AppColors.lightForeground,
          ),
        ),
        leading: IconButton(
          onPressed: () => Helpers.safeBack(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWinners(),
            const SizedBox(height: 16),
            _buildNominationForm(),
            const SizedBox(height: 16),
            _buildNominationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWinners() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = [..._nominations]..sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
    final top = sorted.first;
    return Container(
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
            child: const Icon(Icons.emoji_events_rounded, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Leader', style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground)),
                Text(top['title'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.darkForeground : AppColors.lightForeground)),
                Text(top['spot'], style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground)),
              ],
            ),
          ),
          _voteChip(top['votes']),
        ],
      ),
    );
  }

  Widget _buildNominationForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nominate a Meal', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _mealController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.fastfood_outlined),
              hintText: 'Meal name (e.g., Jollof + Chicken)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _spotController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.storefront_outlined),
              hintText: 'Where? (e.g., Campus Grill)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNomination,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nominate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNominationsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = [..._nominations]..sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nominations', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate(sorted.length, (i) {
          final item = sorted[i];
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
                  child: const Icon(Icons.fastfood_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkForeground : AppColors.lightForeground)),
                      Text(item['spot'], style: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMutedForeground : AppColors.lightMutedForeground)),
                    ],
                  ),
                ),
                _voteChip(item['votes']),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _vote(_nominations.indexOf(item)),
                  child: const Text('Vote'),
                ),
              ],
            ),
          );
        }),
      ],
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
    _mealController.dispose();
    _spotController.dispose();
    super.dispose();
  }
}

