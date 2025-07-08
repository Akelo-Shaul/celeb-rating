import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/video_player_widget.dart';
import 'feed_screen.dart';
import 'search_page.dart';
import 'celebrate_page.dart';
import 'flicks_page.dart';
import 'stream_page.dart';
import 'profile_page.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    FeedScreen(),
    SearchPage(),
    CelebratePage(),
    FlicksPage(),
    StreamPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  @override
  void dispose() {
    // Dispose of the current video controller when the entire MainNavigationShell is removed from the widget tree.
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.dispose();
  }

  void _onNavSelected(int index) {
    setState(() {
      if (_selectedIndex != index) {
        PostCardVideoPlaybackManager().pauseCurrent();
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavSelected,
      ),
    );
  }
}
