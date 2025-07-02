import 'package:celebrating/models/flick.dart';
import 'package:celebrating/screens/post_detail_screen.dart';
import 'package:celebrating/utils/route.dart';
import 'package:celebrating/widgets/stream_category_card.dart';
import 'package:flutter/material.dart';

import '../models/audio_post.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/search_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/audio_card.dart';
import '../widgets/flick_card.dart';
import '../widgets/search_user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class IndexPair {
  final int row;
  final int col;
  IndexPair(this.row, this.col);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexPair && runtimeType == other.runtimeType && row == other.row && col == other.col;
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin{
  late TextEditingController _searchController;
  List<User> _searchUserResults = [];
  List<Flick> _searchFlickResults = [];
  List<dynamic> _searchLocationResults = [];
  List<AudioPost> _searchAudioPosts = [];
  bool _isLoading = false;
  bool _isSearchResults = false;
  late TabController _tabController;
  final ScrollController _flicksScrollController = ScrollController();
  final ValueNotifier<int> _activeFlickIndex = ValueNotifier<int>(0);
  final ValueNotifier<IndexPair> _activeFlickCell = ValueNotifier<IndexPair>(IndexPair(0, 0));

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _isSearchResults = true;
    });
    dynamic results;

    switch (_tabController.index) {
      case 0:
        results = await SearchService.searchUsers(query);
        setState(() {
          _searchUserResults = results;
          _isLoading = false;
        });
        break;
      case 1:
        results = await SearchService.searchFlicks(query);
        setState(() {
          _searchFlickResults = results;
          _isLoading = false;
        });
        break;
      case 2:
        results = await SearchService.searchPostsByLocation(query);
        setState(() {
          _searchLocationResults = results;
          _isLoading = false;
        });
      case 3:
        results = await SearchService.searchAudio(query);
        setState(() {
          _searchAudioPosts = results;
          _isLoading = false;
        });
      default:
        setState(() {
          _searchUserResults = [];
          _searchFlickResults = [];
          _isLoading = false;
        });
    }
  }

  void onFlickTap(Flick flick){
    final index = _searchFlickResults.indexOf(flick);
    Navigator.pushNamed(
      context,
      flickScreen,
      arguments: {
        'flicks': _searchFlickResults,
        'initialIndex': index,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      // Only perform search if the tab changed
      _performSearch(_searchController.text);
    });
    _performSearch('');
  }


  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _flicksScrollController.dispose();
    _activeFlickIndex.dispose();
    _activeFlickCell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "Search",
            ),
            const SizedBox(height: 5,),
            AppSearchBar(
              controller: _searchController,
              hintText: 'Search...',
              onChanged: (value) {
                _performSearch(value);
              },
              onSearchPressed: () {
                _performSearch(_searchController.text);
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
            if(!_isSearchResults)...[
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _searchUserResults.length,
                  itemBuilder: (context, i) =>
                      SearchUserCard(user: _searchUserResults[i]),
                ),
              ),
            ] else ...[
              _buildTabBar(isDark),
              _buildTabs(),
            ]
          ],
        ),
      ),
    );
  }


  Widget _buildTabBar(bool isDark) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF6F00),
      unselectedLabelColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF6F00),
        ),
        insets: EdgeInsets.zero,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      tabs: const [
        Tab(text: 'People'),
        Tab(text: 'Flicks'),
        Tab(text: 'Places'),
        Tab(text: 'Audio'),
        Tab(text: 'Categories'),
        Tab(text: 'Rooms'),
        Tab(text: 'Stream'),
        Tab(text: 'Uhondo'),
      ],
    );
  }

  Widget _buildTabs(){
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPeopleTab(),
          _buildFlicksTab(),
          _buildPlaceTab(),
          _buildAudioTab(),
          _buildCategoriesTab(),
          _buildRoomTab(),
          _buildStreamTab(),
          // _buildUhondoTab(),
        ],
      ),
    );
  }

  Widget _buildPeopleTab(){
    if(_searchUserResults.isEmpty){
      return Center(child: Text("Nothing to display"),);
    }
    return ListView.builder(
      itemCount: _searchUserResults.length,
      itemBuilder: (context, i) =>
          SearchUserCard(user: _searchUserResults[i]),
    );
  }
  
  Widget _buildFlicksTab(){
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if(_searchFlickResults.isEmpty){
      return const Center(child: Text("Nothing to display"));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification || notification is ScrollEndNotification) {
          final gridWidth = MediaQuery.of(context).size.width;
          final itemWidth = (gridWidth - 3.0) / 2; // 2 columns, spacing
          final itemHeight = itemWidth / 0.6 + 3.0; // childAspectRatio and spacing
          final scrollOffset = _flicksScrollController.offset;
          final firstVisibleRow = (scrollOffset / itemHeight).floor();
          final rowOffset = scrollOffset - (firstVisibleRow * itemHeight);
          // If scrolled less than an eight the row, play col 0, else col 1
          final col = rowOffset < itemHeight / 8 ? 0 : 1;
          _activeFlickCell.value = IndexPair(firstVisibleRow, col);
        }
        return false;
      },
      child: ValueListenableBuilder<IndexPair>(
        valueListenable: _activeFlickCell,
        builder: (context, activeCell, _) {
          return GridView.builder(
            controller: _flicksScrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              childAspectRatio: 0.6,
            ),
            itemCount: _searchFlickResults.length,
            itemBuilder: (context, index){
              final row = index ~/ 2;
              final col = index % 2;
              return FlickCard(
                flick: _searchFlickResults[index],
                isActive: activeCell.row == row && activeCell.col == col,
                onTap: (flick) {
                  onFlickTap(flick);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchLocationResults.isEmpty) {
      return const Center(child: Text("Nothing to display"));
    }
    // 3-column grid logic
    final ScrollController _placeScrollController = ScrollController();
    final ValueNotifier<IndexPair> _activePlaceCell = ValueNotifier<IndexPair>(IndexPair(0, 0));
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification || notification is ScrollEndNotification) {
          final gridWidth = MediaQuery.of(context).size.width;
          final itemWidth = (gridWidth - 6.0) / 3; // 3 columns, spacing
          final itemHeight = itemWidth / 0.6 + 3.0; // childAspectRatio and spacing
          final scrollOffset = _placeScrollController.offset;
          final firstVisibleRow = (scrollOffset / itemHeight).floor();
          final rowOffset = scrollOffset - (firstVisibleRow * itemHeight);
          // If scrolled less than a third the row, play col 0, else col 1 or 2
          int col = 0;
          if (rowOffset > itemHeight * 2 / 8) {
            col = 2;
          } else if (rowOffset > itemHeight / 8) {
            col = 1;
          }
          _activePlaceCell.value = IndexPair(firstVisibleRow, col);
        }
        return false;
      },
      child: ValueListenableBuilder<IndexPair>(
        valueListenable: _activePlaceCell,
        builder: (context, activeCell, _) {
          return GridView.builder(
            controller: _placeScrollController,
            itemCount: _searchLocationResults.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, index) {
              final item = _searchLocationResults[index];
              final row = index ~/ 3;
              final col = index % 3;
              if (item is Map<String, dynamic>) {
                if (item['type'] == 'flick') {
                  return FlickCard(
                    flick: item['data'] as Flick,
                    isActive: activeCell.row == row && activeCell.col == col,
                    onTap: (flick) {
                      onFlickTap(flick);
                    },
                  );
                } else if (item['type'] == 'post') {
                  final post = item['data'] as Post;
                  return GestureDetector(
                    onTap: () {
                      // Open post detail screen with suggestions
                      final List<Post> suggestions = _searchLocationResults
                        .where((e) => e is Map<String, dynamic> && e['type'] == 'post' && e['data'] != post)
                        .map<Post>((e) => e['data'] as Post)
                        .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post, suggestedPosts: suggestions),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.black,
                      child: Image.network(
                        post.mediaLink,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
              } else if (item is Post) {
                // fallback for legacy data: treat as post
                return GestureDetector(
                  onTap: () {
                    final List<Post> suggestions = _searchLocationResults
                      .where((e) => (e is Map<String, dynamic> && e['type'] == 'post' && e['data'] != item))
                      .map<Post>((e) => e['data'] as Post)
                      .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: item, suggestedPosts: suggestions),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.black,
                    child: Image.network(
                      item.mediaLink,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildAudioTab(){
    return ListView.builder(
      itemCount: _searchAudioPosts.length,
      itemBuilder: (context, i) => AudioCard(audioPost: _searchAudioPosts[i]),
    );
  }

  Widget _buildCategoriesTab(){
    return Center(child: Text('Categories Tab'),);
  }

  Widget _buildRoomTab(){
    return Center(child: Text('Room Tab'),);
  }

  Widget _buildStreamTab(){
    return Center(child: Text('Stream Tab'),);
  }
}

