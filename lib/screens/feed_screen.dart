import 'package:celebrating/l10n/app_localizations.dart';
import 'package:celebrating/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/post.dart';
import '../services/feed_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/post_card.dart';
import '../utils/route.dart';
import '../widgets/profile_avatar.dart';
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
      endDrawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                // You can set a background decoration for the entire header if needed
                decoration: BoxDecoration(
                  color: Color(0x93A3A3A3), // Example: a light background for the header area
                ),
                child: Align( // Use Align to position the profile picture within the header's default space
                  alignment: Alignment.center, // Typically aligns content to the left
                  child: GestureDetector(
                    onTap: () {
                      // Implement profile navigation
                      print('Profile picture tapped');
                      // Example: Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
                    },
                    child: const ProfileAvatar(
                      //TODO: Replace with real user profile photo
                      imageUrl: null,
                      radius: 60,
                      backgroundColor: const Color(0xFF9E9E9E), // Custom background color
                    ),
                  ),
                ),
              ),
              AppTransparentButton(
                text: 'Hall of Fame',
                icon: Icons.emoji_events,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Hall of Fame tapped');
                  context.goToHallOfFame();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Uhondo Kona',
                icon: Icons.coffee,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Uhondo Kona tapped');
                  context.goToUhondoKona();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Celebrity Ranks',
                icon: Icons.bar_chart_rounded,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Ranks tapped');
                  context.goToAward();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Versus: Head to Head',
                icon: Icons.compare_arrows,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Versus tapped');
                  context.goToVersus();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Awards',
                icon: Icons.military_tech,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Awards tapped');
                  context.goToAward();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Profile',
                icon: Icons.person_outline,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Profile button tapped');
                  context.goToProfile();
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Saved',
                icon: Icons.bookmark,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Saved tapped');
                  //TODO: Add navigation logic
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Notifications',
                icon: Icons.notifications,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Notifications tapped');
                  //TODO: Add navigation logic
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Settings',
                icon: Icons.settings,
                // iconColor: Colors.blueAccent, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Settings tapped');
                  //TODO: Add navigation logic
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
              AppTransparentButton(
                text: 'Logout',
                icon: Icons.logout,
                iconColor: Colors.red, // Custom icon color
                fontSize: 20,
                onPressed: () {
                  print('Logout tapped');
                  //TODO: Add navigation logic
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Custom padding
                borderRadius: BorderRadius.circular(25), // More rounded corners
              ),
            ],
          ),
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
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: 150, // Adjust width as needed for the dropdown
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              // Implement profile navigation
              print('Profile picture tapped');
              Scaffold.of(context).openEndDrawer();
            },
            child:const ProfileAvatar(
              //TODO: Replace with real user profile photo
              imageUrl: null,
              radius: 20,
              backgroundColor: const Color(0xFF9E9E9E), // Custom background color
            )
          ),
        ),
        const SizedBox(width: 8), // Some padding on the right edge
      ],
    );
  }
}