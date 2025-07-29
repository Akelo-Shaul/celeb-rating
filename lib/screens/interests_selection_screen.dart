import 'package:flutter/material.dart';
import '../widgets/app_search_bar.dart';
import '../services/search_service.dart';
import '../models/user.dart';

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
  PageController? _celebrityPageController;
  int _celebrityIndex = 0;
  List<User> _celebrities = [];
  Map<int, bool> _following = {};
  bool _loadingCelebs = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _celebrityPageController = PageController();
    _fetchCelebrities();
  }

  Future<void> _fetchCelebrities() async {
    // Simulate fetching celebrities from SearchService
    final all = SearchService.dummyUsers.where((u) => u.role == 'Celebrity').toList();
    setState(() {
      _celebrities = all;
      _loadingCelebs = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _celebrityPageController?.dispose();
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

  void _onCelebrityPageChanged(int idx) {
    setState(() {
      _celebrityIndex = idx;
    });
  }

  void _toggleFollow(int? id) {
    if (id == null) return;
    setState(() {
      _following[id] = !(_following[id] ?? false);
    });
    // Dummy follow function
    // In real app, call API here
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < tabTitles.length; i++)
              GestureDetector(
                onTap: () => _onTabChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _tabIndex == i ? selectedColor : Colors.transparent,
                  ),
                  child: Text(
                    tabTitles[i],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _tabIndex == i ? Colors.black : (isDark ? Colors.white : Colors.black54),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Positional indicator (like onboarding)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
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
              Expanded(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    // Interests Tab
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Tell us what interests you for better experience and recommendations',
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
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
                          const Spacer(),
                          if (_showSearch)
                            AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.only(bottom: _keyboardHeight > 0 ? _keyboardHeight : 0),
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
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    // Celebrities Tab
                    _loadingCelebs
                        ? const Center(child: CircularProgressIndicator())
                        : _celebrities.isEmpty
                            ? Center(child: Text('No celebrities found', style: TextStyle(color: isDark ? Colors.white : Colors.black)))
                            : Column(
                                children: [
                                  Expanded(
                                    child: PageView.builder(
                                      controller: _celebrityPageController,
                                      itemCount: _celebrities.length,
                                      onPageChanged: _onCelebrityPageChanged,
                                      itemBuilder: (context, idx) {
                                        final celeb = _celebrities[idx];
                                        final isFollowing = _following[celeb.id ?? 0] ?? false;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(24),
                                                  child: celeb.profileImageUrl != null
                                                      ? Image.network(
                                                          celeb.profileImageUrl!,
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Container(
                                                          color: Colors.grey.shade300,
                                                          child: const Icon(Icons.person, size: 120),
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    celeb.fullName,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(Icons.verified, color: selectedColor, size: 22),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '@${celeb.username}',
                                                style: TextStyle(color: Colors.white70, fontSize: 16),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                (celeb is CelebrityUser ? '${celeb.followers} followers' : ''),
                                                style: TextStyle(color: Colors.white70, fontSize: 16),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                (celeb is CelebrityUser ? celeb.bio : ''),
                                                style: TextStyle(color: Colors.white, fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isFollowing ? Colors.grey : selectedColor,
                                                  foregroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                                ),
                                                onPressed: () => _toggleFollow(celeb.id),
                                                child: Text(isFollowing ? 'Following' : 'Follow'),
                                              ),
                                              const SizedBox(height: 18),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.thumb_down_alt_rounded, color: Colors.blue.shade200, size: 36),
                                                    onPressed: () {},
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.thumb_up_alt_rounded, color: Colors.pinkAccent.shade100, size: 36),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Page indicator for celebrities
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(_celebrities.length, (idx) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          height: 8,
                                          width: _celebrityIndex == idx ? 28 : 14,
                                          decoration: BoxDecoration(
                                            color: _celebrityIndex == idx ? selectedColor : unselectedColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                  ],
                ),
              ),
            ],
          ),
          // Floating search button (only on interests tab)
          if (_tabIndex == 0)
            Positioned(
              bottom: _showSearch ? (_keyboardHeight > 0 ? _keyboardHeight + 16 : 16) : 16,
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
                    }
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
} 