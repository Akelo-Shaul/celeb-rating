import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'feed_screen.dart';
import 'search_page.dart';
import 'post_page.dart';
import 'reels_page.dart';
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
    PostPage(),
    ReelsPage(),
    StreamPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  void _onNavSelected(int index) {
    setState(() {
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
