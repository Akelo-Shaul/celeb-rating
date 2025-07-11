import 'package:celebrating/l10n/app_localizations.dart';
import 'package:celebrating/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/feed_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/post_card.dart';
import '../utils/route.dart';
import '../widgets/video_player_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> posts = [];
  bool isLoading = false;
  int _selectedIndex = 0;

  // Global mute state for feed videos
  static final ValueNotifier<bool> feedMuteNotifier = ValueNotifier<bool>(true); // true = muted by default

  // Fetch feed from FeedService and update posts
  Future<void> fetchFeed() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedPosts = await FeedService.getFeed({});
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Error fetching feed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    posts = FeedService.generateDummyPosts();
    isLoading = false;
  }

  //TODO: Video sound is still playing when I navigate to another page. Use widget lifecycle to fix this
  @override
  void deactivate() {
    // Pause and dispose video when this screen is deactivated (e.g., tab switch, navigation shell)
    PostCardVideoPlaybackManager().pauseCurrent();
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.deactivate();
  }

  @override
  void dispose() {
    // Clean up all video playback when leaving the feed screen
    PostCardVideoPlaybackManager().pauseCurrent();
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(AppLocalizations.of(context)!.drawerHeader, style: const TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.item1),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.item2),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Implement profile navigation
                      print('Profile picture tapped');
                    },
                    child: CircleAvatar(
                      radius: 30, // Adjust size
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5), // Placeholder color
                      // You would typically load an actual image here:
                      // backgroundImage: NetworkImage('your_profile_picture_url'),
                      child: const Icon(Icons.person, color: Colors.white), // Placeholder icon
                    ),
                  ),
                ),
            ),
            // In your widget tree
            AppTransparentButton(
              text: 'Profile',
              icon: Icons.person_outline,
              // iconColor: Colors.blueAccent, // Custom icon color
              onPressed: () {
                print('Profile button tapped');
                Navigator.pushReplacementNamed(context, profileScreen);
              },
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
              borderRadius: BorderRadius.circular(25), // More rounded corners
            )
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, i) => PostCard(
          post: posts[i],
          feedMuteNotifier: feedMuteNotifier,
          showFollowButton: true,
        ),
      ),
    );
  }

}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}

class _MyAppBarState extends State<MyAppBar> {
  String _currentFeedType = 'FEED'; // State for the selected feed type

  @override
  Widget build(BuildContext context) {
    // You might want to get theme colors dynamically here if needed for icons/text,
    // but default AppBar styling usually handles it well.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black; // Example for text color if needed

    return AppBar(
      backgroundColor: Colors.transparent, // Make AppBar transparent to show background if any
      elevation: 0, // No shadow
      leadingWidth: 60, // Adjust if needed
      leading: IconButton(
        icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color), // Hamburger icon
        onPressed: () {
          // Implement sidebar/drawer opening logic here
          Scaffold.of(context).openDrawer(); // Example: opens a Drawer
        },
      ),
      title: SizedBox(
        width: 120, // Adjust width as needed for the dropdown
        child: AppDropdown<String>(
          labelText: _currentFeedType,
          value: _currentFeedType,
          items: [
            // DropdownMenuItem(value: 'FEED', child: Text(AppLocalizations.of(context)!.feed)),
            // DropdownMenuItem(value: 'POPULAR', child: Text(AppLocalizations.of(context)!.popular)),
            // DropdownMenuItem(value: 'TRENDING', child: Text(AppLocalizations.of(context)!.trending)),
            DropdownMenuItem(value: 'FEED', child: Text('FEED')),
            DropdownMenuItem(value: 'POPULAR', child: Text('POPULAR')),
            DropdownMenuItem(value: 'TRENDING', child: Text('TRENDING')),
          ],
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null) {
                _currentFeedType = newValue;
                // Add logic to change your feed based on selection (e.g., call a BLoC/Provider method)
                print('Selected Feed Type: $_currentFeedType');
              }
            });
          },
          isFormField: false, // It's not a form field
          labelTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor, // Use the dynamically set text color
          ),
        ),
      ),
      // centerTitle: true, // Center the title (the FEED dropdown)
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color), // Search icon
          onPressed: () {
            // Implement search functionality
            print('Search tapped');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              // Implement profile navigation
              print('Profile picture tapped');
              Scaffold.of(context).openEndDrawer();
            },
            child: CircleAvatar(
              radius: 22, // Adjust size
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5), // Placeholder color
              // You would typically load an actual image here:
              // backgroundImage: NetworkImage('your_profile_picture_url'),
              child: const Icon(Icons.person, color: Colors.white), // Placeholder icon
            ),
          ),
        ),
        const SizedBox(width: 8), // Some padding on the right edge
      ],
    );
  }
}