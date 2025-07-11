import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/live_stream.dart';
import '../models/stream_category.dart';
import '../services/stream_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/live_stream_card.dart';
import '../widgets/stream_category_card.dart';
import 'live_stream_detail_page.dart';
import '../widgets/live_stream_overlay.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});
  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late final List<StreamCategory> _streamCategories;
  late TabController _tabController;
  List<LiveStream> _liveStreams = [];
  LiveStream? _expandedStream;
  String? _activeStreamId;
  bool _expandedStreamVisible = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLiveStreamsLoading = true;

  @override
  void initState() {
    super.initState();
    _streamCategories = StreamService.getCategories();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadLiveStreams();
    // Listen for tab changes to set the first live stream as active when the Live tab is selected
    _tabController.addListener(() {
      if (_tabController.index == 1 && _liveStreams.isNotEmpty) {
        setState(() {
          _activeStreamId = _liveStreams[0].id;
        });
      }
    });
    // Set the first video as active when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tabController.index == 1 && _liveStreams.isNotEmpty) {
        setState(() {
          _activeStreamId = _liveStreams[0].id;
        });
      }
    });
  }

  Future<void> _loadLiveStreams() async {
    setState(() {
      _isLiveStreamsLoading = true;
    });
    final streams = await Future.value(StreamService.getStreams());
    setState(() {
      _liveStreams = streams;
      _isLiveStreamsLoading = false;
      if (_tabController.index == 1 && _liveStreams.isNotEmpty) {
        _activeStreamId = _liveStreams[0].id;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_expandedStreamVisible) return;
    final itemHeight = 240.0; // Approximate height of each LiveStreamCard
    final offset = _scrollController.offset;
    final topIndex = (offset / itemHeight).round().clamp(0, _liveStreams.length - 1);
    final topStreamId = _liveStreams[topIndex].id;
    if (_activeStreamId != topStreamId) {
      setState(() {
        _activeStreamId = topStreamId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSearchBar(
                  controller: _searchController,
                  hintText: localizations.searchHint,
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
                _buildTabBar(isDark),
                _buildTabs()
              ],
            ),
            if (_expandedStream != null)
              LiveStreamOverlay(
                stream: _expandedStream!,
                onClose: () {
                  setState(() {
                    _expandedStream = null;
                    _expandedStreamVisible = false;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final localizations = AppLocalizations.of(context)!;
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
      tabs: [
        Tab(text: localizations.tabCategories),
        Tab(text: localizations.liveTab),
        Tab(text: localizations.recordedTab),
      ],
    );
  }

  Widget _buildTabs(){
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(),
          _buildLiveStreamTab(),
          _buildRecordedTab()
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(){
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _streamCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final category = _streamCategories[index];
          return StreamCategoryCard(category: category);
        },
      ),
    );
  }

  Widget _buildLiveStreamTab() {
    final localizations = AppLocalizations.of(context)!;
    if (_isLiveStreamsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_liveStreams.isEmpty) {
      return Center(child: Text(localizations.noLiveStreams));
    }
    // Show the list immediately, each LiveStreamCard should handle its own thumbnail/video logic
    return ListView.builder(
      controller: _scrollController,
      itemCount: _liveStreams.length,
      itemBuilder: (context, index) {
        final stream = _liveStreams[index];
        // Pass a thumbnailUrl (could be stream.thumbnailUrl or stream.lastFrameUrl)
        return LiveStreamCard(
          stream: stream,
          isActive: _activeStreamId == stream.id && _expandedStream == null,
          onStreamerTap: () {},
          onCategoryTap: (cat) {},
          onTagTap: (tag) {},
          onTap: () {
            setState(() {
              _expandedStream = stream;
              _expandedStreamVisible = true;
            });
          },
          // Add this prop if not present in your LiveStreamCard:
          // thumbnailUrl: stream.thumbnailUrl ?? stream.lastFrameUrl,
        );
      },
    );
  }

  Widget _buildRecordedTab(){
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Text(localizations.recordedTab),
    );
  }
}
