import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/celeb_rank.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_search_bar.dart';
import '../services/award_service.dart';
import '../widgets/profile_avatar.dart';
import '../services/celeb_ranks_service.dart';

class AwardScreen extends StatefulWidget {
  const AwardScreen({super.key});

  @override
  State<AwardScreen> createState() => _AwardScreenState();
}

class _AwardScreenState extends State<AwardScreen> {
  late final List<CelebRank> _ranks;
  String _selectedCategory = 'General';
  final List<String> _categories = [
    'General',
    'Music',
    'Sports',
    'Film',
    'Fashion',
    'Business',
    'Other',
  ];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _ranks = CelebRanksService.getDummyRanks();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Celebrity Rankings"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context)!.searchHint,
              onChanged: (value) {
                // _performSearch(value);
              },
              onSearchPressed: () {
                // _performSearch(_searchController.text);
                FocusScope.of(context).unfocus();
              },
              onFilterPressed: () {
                print('Filter button pressed');
              },
              showSearchButton: true,
              showFilterButton: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 130,
                  child: AppDropdown<String>(
                    labelText: 'Category',
                    value: _selectedCategory,
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                        // TODO: Filter your data by category
                      }
                    },
                    isFormField: false,
                  ),
                ),
              ),
            ),

            // Podium and ranking table
            const SizedBox(height: 12),
            // Podium for top 3
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_ranks.length > 1)
                    _PodiumPlace(
                      place: 2,
                      name: _ranks[1].name,
                      icon: Icons.emoji_events,
                      iconColor: Color(0xFFB0B0B0),
                      iconSize: 28,
                      offsetY: 32,
                      imageUrl: _ranks[1].imageUrl,
                      fadedCircleSize: 70,
                      iconAbove: false,
                    ),
                  if (_ranks.isNotEmpty)
                    _PodiumPlace(
                      place: 1,
                      name: _ranks[0].name,
                      icon: Icons.emoji_events,
                      iconColor: Color(0xFFFFC107),
                      iconSize: 36,
                      offsetY: 0,
                      imageUrl: _ranks[0].imageUrl,
                      fadedCircleSize: 100,
                      iconAbove: true,
                    ),
                  if (_ranks.length > 2)
                    _PodiumPlace(
                      place: 3,
                      name: _ranks[2].name,
                      icon: Icons.emoji_events,
                      iconColor: Color(0xFFCD7F32),
                      iconSize: 28,
                      offsetY: 48,
                      imageUrl: _ranks[2].imageUrl,
                      fadedCircleSize: 60,
                      iconAbove: false,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  SizedBox(width: 40, child: Text('')), // For rank
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Celeb Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Ranking',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            // Table rows
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                itemCount: _ranks.length - 3,
                itemBuilder: (context, i) {
                  final rank = _ranks[i + 3];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.grey.withOpacity(0.08) : Colors.grey.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${rank.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          backgroundImage: rank.imageUrl != null ? NetworkImage(rank.imageUrl!) : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            rank.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            rank.score.toStringAsFixed(1),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 8,),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}


class _PodiumPlace extends StatelessWidget {
  final int place;
  final String name;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double offsetY;
  final String? imageUrl;
  final double fadedCircleSize;
  final bool iconAbove;
  const _PodiumPlace({
    required this.place,
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.offsetY,
    this.imageUrl,
    this.fadedCircleSize = 80,
    this.iconAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: offsetY),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: fadedCircleSize,
                height: fadedCircleSize,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
              ProfileAvatar(
                radius: fadedCircleSize / 2.5,
                imageUrl: imageUrl != null ? imageUrl! : null,
                backgroundColor: const Color(0xFF9E9E9E),
              ),
              // Icon placement for 1st, 2nd, 3rd
              if (place == 1)
                Positioned(
                  top: -fadedCircleSize * 0.20,
                  right: -fadedCircleSize * 0.10,
                  child: Icon(icon, color: Colors.amber, size: fadedCircleSize / 2.2),
                ),
              if (place == 2)
                Positioned(
                  bottom: -fadedCircleSize * 0.12,
                  right: -fadedCircleSize * 0.10,
                  child: Icon(icon, color: iconColor, size: fadedCircleSize / 2.5),
                ),
              if (place == 3)
                Positioned(
                  bottom: -fadedCircleSize * 0.10,
                  right: -fadedCircleSize * 0.10,
                  child: Icon(icon, color: iconColor, size: fadedCircleSize / 2.5),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}