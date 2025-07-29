import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_card_swiper/src/enums.dart'; // Keep this for CardSwiperDirection
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_search_bar.dart';
import '../services/search_service.dart';
import '../models/user.dart';
import 'feed_screen.dart';

class InterestsSelectionScreen extends StatefulWidget {
  const InterestsSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestsSelectionScreen> createState() => _InterestsSelectionScreenState();
}

class _InterestsSelectionScreenState extends State<InterestsSelectionScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final List<String> _allCategories = [
    'Art', 'Music', 'Sports', 'Fashion', 'Tech', 'Science', 'Travel', 'Food', 'Movies', 'Books', 'Gaming', 'Fitness', 'Nature', 'History', 'Photography', 'Business', 'Comedy', 'Health', 'Education', 'Politics',
  ];
  final Set<String> _selectedCategories = {'Music', 'Fashion'};
  String _search = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  double _keyboardHeight = 0;

  int _tabIndex = 0;
  late CardSwiperController _cardController;
  List<User> _celebrities = [];
  Map<int, bool> _following = {};
  bool _loadingCelebs = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cardController = CardSwiperController();
    _fetchCelebrities();
  }

  Future<void> _fetchCelebrities() async {
    final all = SearchService.dummyUsers
        .where((u) => u.role == 'Celebrity' && u is CelebrityUser)
        .toList();
    setState(() {
      _celebrities = all;
      _loadingCelebs = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _keyboardHeight = bottomInset;
    });
  }

  List<String> get _filteredCategories {
    if (_search.isEmpty) return _allCategories;
    return _allCategories.where((c) => c.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  void _onTabChanged(int idx) {
    setState(() {
      _tabIndex = idx;
    });
  }

  Future<bool> _handleSwipe(int index, int? previousIndex, CardSwiperDirection direction) {
    // This callback is triggered when a card is swiped away by the user or programmatically.
    // `previousIndex` is the index of the card that was *just swiped*.
    // We can use this to perform actions related to that card before it's gone.

    // If you need to log or perform an action based on *which* card was swiped,
    // and what the intent was (e.g., if a right swipe explicitly means "like"),
    // you would do that here using `_celebrities[previousIndex]`.
    // However, the current request is for *any* swipe to just advance.
    // So, no specific action based on direction here, just letting the card disappear.

    // The core logic for navigating to FeedScreen when all cards are gone:
    // When a card is swiped, `cardsCount` in `CardSwiper` automatically decreases.
    // The `_celebrities` list is also being managed by _toggleFollow.
    // A more robust check for the "last card" scenario is to check the *next* current index.
    // If the next index is the same as the total count of cards (meaning no more cards),
    // then navigate.
    if (index == _celebrities.length -1 && previousIndex == _celebrities.length -1 ) {
      // This means the last available card (previousIndex) was just swiped,
      // and now the 'current' index would technically point beyond the list.
      // We navigate if there are no more celebrities *after* this swipe.
      if (_celebrities.isEmpty || (previousIndex != null && previousIndex == _celebrities.length -1 && index >= _celebrities.length - 1)) {
        // Delay to allow swipe animation to finish
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FeedScreen()),
            );
          }
        });
        return Future.value(true);
      }
    }
    // Simplest way: if the list becomes empty after a swipe, navigate.
    // This assumes _toggleFollow or other logic correctly removes items from _celebrities.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _celebrities.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FeedScreen()),
        );
      }
    });

    return Future.value(true); // Always allow the swipe to complete
  }


  void _toggleFollow(int? id) {
    if (id == null) return;
    setState(() {
      _following[id] = true;
      // Remove followed celebrity from the list to update the card stack
      // This will cause `cardsCount` in CardSwiper to decrease.
      _celebrities.removeWhere((celeb) => celeb.id == id);
    });
  }

  // Button actions now solely trigger a swipe, and handle their specific logic.
  // The 'last card' navigation is handled by `_handleSwipe` after the programmatic swipe.

  void _onFollow(int index) {
    // Explicitly follow the user
    if (index < _celebrities.length) { // Ensure index is valid before accessing
      _toggleFollow(_celebrities[index].id);
    }
    // Then simulate a swipe to remove the card and advance
    _cardController.swipe(CardSwiperDirection.right); // Simulate a right swipe for follow
  }

  void _onLike(int index) {
    // Implement like logic here
    print('User liked celebrity: ${_celebrities[index].fullName}');
    _cardController.swipe(CardSwiperDirection.top); // Simulate a swipe up for like/dismiss
  }

  void _onDislike(int index) {
    // Implement dislike logic here
    print('User disliked celebrity: ${_celebrities[index].fullName}');
    _cardController.swipe(CardSwiperDirection.bottom); // Simulate a swipe down for dislike/dismiss
  }

  void _onSkipCelebritiesTab() {
    context.goNamed('feed');
  }

  void _onSkipInterestsTab() {
    setState(() {
      _tabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? Colors.amber.shade700 : Colors.amber;
    final unselectedColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final selectedTextColor = isDark ? Colors.black : Colors.black;
    final unselectedTextColor = isDark ? Colors.white : Colors.black;
    final tabTitles = ['Interests', 'Celebrities'];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      // Interests Tab
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8,),
                            Center(
                              child: Text(
                                'Choose Your Interests',
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tell us what interests you for better experience and recommendations',
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _filteredCategories.map((cat) {
                                    final selected = _selectedCategories.contains(cat);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selected) {
                                            _selectedCategories.remove(cat);
                                          } else {
                                            _selectedCategories.add(cat);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected ? selectedColor : unselectedColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: selected ? selectedColor : unselectedColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (selected)
                                              Icon(Icons.check_circle, color: selectedColor == Colors.amber ? Colors.orange : selectedColor, size: 20),
                                            if (selected) const SizedBox(width: 4),
                                            Text(
                                              cat,
                                              style: TextStyle(
                                                color: selected ? selectedTextColor : unselectedTextColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_showSearch)
                              AnimatedPadding(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.only(bottom: _keyboardHeight > 0 ? _keyboardHeight : 140,),
                                child: AppSearchBar(
                                  controller: _searchController,
                                  hintText: 'Search...',
                                  showFilterButton: false,
                                  onChanged: (val) {
                                    setState(() {
                                      _search = val;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Celebrities Tab
                      _loadingCelebs
                          ? const Center(child: CircularProgressIndicator())
                          : _celebrities.isEmpty
                          ? Center(child: Text('No celebrities found', style: TextStyle(color: isDark ? Colors.white : Colors.black)))
                          : Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Recommended Celebrities',
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(height: 8,),
                            Expanded(
                              child: CardSwiper(
                                controller: _cardController,
                                cardsCount: _celebrities.length,
                                onSwipe: (index, previousIndex, direction) {
                                  return _handleSwipe(index, previousIndex, direction);
                                },
                                numberOfCardsDisplayed: 3,
                                backCardOffset: const Offset(10, -50),
                                isLoop: false,
                                allowedSwipeDirection: const AllowedSwipeDirection.all(), // Any swipe advances
                                threshold: 20,
                                // Removed `swipeNextOnSwipeCurrent` and `undoLastSwipeEnabled`
                                // as per previous errors and the request to remove undo.
                                padding: const EdgeInsets.only(top: 10, bottom: 80),
                                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                  if (index >= _celebrities.length) {
                                    return Container();
                                  }

                                  final user = _celebrities[index];
                                  if (user is! CelebrityUser) {
                                    return Center(
                                      child: Container(
                                        height: 300,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          child: Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    );
                                  }
                                  final celeb = user;
                                  final isFollowing = _following[celeb.id ?? 0] ?? false;

                                  final tags = <Widget>[];
                                  if (celeb.occupation.isNotEmpty) tags.add(_buildTag(Icons.work, celeb.occupation));
                                  if (celeb.nationality.isNotEmpty) tags.add(_buildTag(Icons.flag, celeb.nationality));
                                  if (celeb.involvedCauses.isNotEmpty) {
                                    for (var cause in celeb.involvedCauses) {
                                      tags.add(_buildTag(Icons.volunteer_activism, cause['cause'] ?? ''));
                                    }
                                  }
                                  if (celeb.hobbies.isNotEmpty) {
                                    for (var hobby in celeb.hobbies) {
                                      tags.add(_buildTag(Icons.sports_esports, hobby['name'] ?? ''));
                                    }
                                  }

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        celeb.profileImageUrl != null
                                            ? Image.network(
                                          celeb.profileImageUrl!,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.person, size: 120, color: Colors.black54),
                                          ),
                                        )
                                            : Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.person, size: 120),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          height: 220,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black87,
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 80,
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      celeb.fullName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.white,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Icon(Icons.verified, color: selectedColor, size: 22),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: tags,
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    IconButton(onPressed: () => _onLike(index), icon: Icon(Icons.thumb_up_alt_rounded), color: Colors.green,),
                                                    _buildActionButton(
                                                      icon: Icons.person_add_rounded,
                                                      label: isFollowing ? 'Following' : 'Follow',
                                                      color: isFollowing ? Colors.grey : Colors.amber,
                                                      onTap: () => _onFollow(index),
                                                    ),
                                                    IconButton(onPressed:  () => _onDislike(index), icon: Icon(Icons.thumb_down_alt_rounded), color: Colors.pink,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_tabIndex == 0) ...[
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.orange.shade200,
                  child: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _search = '';
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      } else {
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    });
                  },
                ),
              ),
            ],
            Positioned(
              bottom: 40,
              right: 10,
              left: 10,
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 8,
                      width: _tabIndex == index ? 28 : 14,
                      decoration: BoxDecoration(
                        color: _tabIndex == index ? selectedColor : unselectedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: AppTextButton(
                text: AppLocalizations.of(context)!.skip,
                onPressed: _tabIndex == 0 ? _onSkipInterestsTab : _onSkipCelebritiesTab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}