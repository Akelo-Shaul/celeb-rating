import 'package:camera/camera.dart';
import 'package:celebrating/screens/auth_screen.dart';
import 'package:celebrating/screens/award_screen.dart';
import 'package:celebrating/screens/camera_screen.dart';
import 'package:celebrating/screens/celebrate_page.dart';
import 'package:celebrating/screens/celebrity_profile_create.dart';
import 'package:celebrating/screens/chat_screen.dart';
import 'package:celebrating/screens/chat_message_screen.dart';
import 'package:celebrating/screens/feed_screen.dart';
import 'package:celebrating/screens/flicks_page.dart';
import 'package:celebrating/screens/hall_of_fame.dart';
import 'package:celebrating/screens/head_to_head_screen.dart';
import 'package:celebrating/screens/live_stream_detail_page.dart';
import 'package:celebrating/screens/notification_screen.dart';
import 'package:celebrating/screens/onboarding_screen.dart';
import 'package:celebrating/screens/post_detail_screen.dart';
import 'package:celebrating/screens/profile_page.dart';
import 'package:celebrating/screens/search_page.dart';
import 'package:celebrating/screens/settings_screen.dart';
import 'package:celebrating/screens/splash_screen.dart';
import 'package:celebrating/screens/stream_page.dart';
import 'package:celebrating/screens/uhondo_kona.dart';
import 'package:celebrating/screens/verification_screen.dart';
import 'package:celebrating/screens/versus_screen.dart';
import 'package:celebrating/screens/view_profile_screen.dart';
import 'package:celebrating/screens/web_view_screen.dart'; // Correct import for WebViewScreen
import 'package:celebrating/screens/celebrity_rankings_screen.dart';
import 'package:celebrating/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../models/post.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // For StreamSubscription
import 'package:celebrating/services/user_service.dart';

import '../models/versus_user.dart'; // For fetching user
import 'package:celebrating/screens/interests_selection_screen.dart';

class AppRouter {
  final AuthService _authService;

  AppRouter(this._authService);

  // Global Key for the root Navigator
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
  GlobalKey<NavigatorState>();
  // Global Key for the ShellRoute's Navigator (for bottom nav)
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
  GlobalKey<NavigatorState>();

  late final router = GoRouter(
    navigatorKey: _rootNavigatorKey, // Assign root navigator key
    initialLocation: '/splash',
    refreshListenable: RouteRefreshStream(_authService.authStateChanges),
    redirect: _guardRoutes,
    routes: [
      // Public Routes (No Auth Required)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) {
          // Check if 'extra' contains 'selectedImage'
          final XFile? selectedImage = state.extra is Map<String, dynamic>
              ? (state.extra as Map<String, dynamic>)['selectedImage'] as XFile?
              : null;

          if (selectedImage != null) {
            // Here you can handle the returned XFile
            print('Received image from camera: ${selectedImage.path}');
          }

          // Return the actual AuthPage widget
          return const AuthScreen(); // Make sure AuthPage exists
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/verification',
        name: 'verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/create-celebrity-profile',
        name: 'createCelebrityProfile',
        builder: (context, state) => const CelebrityProfileCreate(),
      ),
      GoRoute(
          path: '/camera',
          name: 'camera',
          builder: (context, state) {
            final returnRoute = state.uri.queryParameters['returnRoute'] ?? '/auth';
            return CameraScreen(returnRoute: returnRoute);
          }
      ),
      GoRoute(
        path: '/interests-selection',
        name: 'interestsSelection',
        builder: (context, state) => const InterestsSelectionScreen(),
      ),

      // Auth Required Routes (without bottom nav)
      // These routes are outside the ShellRoute, so they won't have the bottom navigation.
      // They will generally pop back to the previous route in the root stack.
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        name: 'chatMessage',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final otherUser = state.extra as User;
          return ChatMessageScreen(chatId: chatId, otherUser: otherUser);
        },
      ),
      GoRoute(
        path: '/webview',
        name: 'webview',
        builder: (context, state) {
          final url = state.uri.queryParameters['url'] ?? '';
          return WebView(url: url);
        },
      ),

      // Main Navigation Shell (Auth Required, with Bottom Nav)
      // All routes within this ShellRoute will display the ScaffoldWithBottomNav.
      ShellRoute(
        navigatorKey: _shellNavigatorKey, // Assign shell navigator key
        builder: (context, state, child) =>
            ScaffoldWithBottomNav(child: child),
        routes: [
          // Feed Section - Root of main application flow
          GoRoute(
            path: '/feed',
            name: 'feed',
            builder: (context, state) => const FeedScreen(),
            routes: [
              // // Post Detail (pops back to Feed)
              // GoRoute(
              //   path: 'post/:postId',
              //   name: 'postDetail',
              //   builder: (context, state) {
              //     final postId = state.pathParameters['postId']!;
              //     final Post? postFromExtra = state.extra as Post?;
              //
              //     // If post object is passed via extra, use it.
              //     if (postFromExtra != null) {
              //       return PostDetailScreen(
              //           post: postFromExtra, suggestedPosts: []);
              //     }
              //
              //     // Otherwise, fetch the post using postId.
              //     return FutureBuilder<Post>(
              //       future: UserService.fetchPost(postId), // Use your actual PostService
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const Scaffold(
              //               body: Center(child: CircularProgressIndicator()));
              //         } else if (snapshot.hasError) {
              //           return Scaffold(
              //               appBar: AppBar(title: const Text('Error')),
              //               body: Center(
              //                   child: Text('Error loading post: ${snapshot.error}')));
              //         } else if (snapshot.hasData) {
              //           return PostDetailScreen(
              //               post: snapshot.data!, suggestedPosts: []);
              //         }
              //         return const Scaffold(
              //             body: Center(child: Text('Post not found')));
              //       },
              //     );
              //   },
              // ),
              // Routes from End Drawer (these will have bottom nav and pop back to Feed)
              GoRoute(
                path: 'versus',
                name: 'versus',
                builder: (context, state) => const VersusScreen(),
              ),
              GoRoute(
                path: 'head-to-head',
                name: 'headToHead',
                builder: (context, state) {
                  // Since user1 and user2 are required, we must provide them.
                  // For demonstration, using dummy data. In a real app, you'd fetch them
                  // based on IDs passed via pathParameters or queryParameters.
                  final VersusUser dummyUser1 = VersusUser(
                      name: 'User One',
                      imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=U1',
                      extraAttributes: {'age': '30', 'profession': 'Artist'}, id: '');
                  final VersusUser dummyUser2 = VersusUser(
                      name: 'User Two',
                      imageUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=U2',
                      extraAttributes: {'age': '32', 'profession': 'Musician'}, id: '');

                  return HeadToHead(user1: dummyUser1, user2: dummyUser2);
                },
              ),
              GoRoute(
                path: 'hall-of-fame',
                name: 'hallOfFame',
                builder: (context, state) => const HallOfFame(),
              ),
              GoRoute(
                path: 'uhondo-kona',
                name: 'uhondoKona',
                builder: (context, state) => const UhondoKona(),
              ),
              GoRoute(
                path: 'award', // Updated path to be relative to /feed
                name: 'award',
                builder: (context, state) => const AwardScreen(),
              ),
              GoRoute(
                path: 'celebrity-rankings',
                name: 'celebrityRankings',
                builder: (context, state) => const CelebrityRankingsScreen(),
              ),
            ],
          ),

          // Search Section - Main Bottom Nav Tab
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
            routes: [
              // View Profile from Search (pops back to Search, then Search to Feed)
              GoRoute(
                path: 'view-profile/:userId',
                name: 'viewProfile',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  // If user object is passed, use it, otherwise fetch
                  final User? user = state.extra as User?;
                  if (user != null) {
                    return ViewProfilePage(user: user);
                  }
                  // If user is not passed, fetch it.
                  // You might want to show a loading indicator here or handle error.
                  return FutureBuilder<User>(
                    future: UserService.fetchUser(userId, isCelebrity: false), // Adjust isCelebrity based on your logic
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading user: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return ViewProfilePage(user: snapshot.data!);
                      }
                      return const Center(child: Text('User not found'));
                    },
                  );
                },
              ),
              // Add other sub-routes for Search here (e.g., search results detail)
              // GoRoute(
              //   path: 'post/:postId',
              //   name: 'postDetail',
              //   builder: (context, state) {
              //     final postId = state.pathParameters['postId']!;
              //     // Expect a map in `extra` to get both post and suggestedPosts
              //     final Map<String, dynamic>? extraData = state.extra as Map<String, dynamic>?;
              //
              //     final Post? postFromExtra = extraData?['post'] as Post?;
              //     // Ensure suggestedPosts is always a List<Post>, default to empty if not provided
              //     final List<Post> suggestedPostsFromExtra = (extraData?['suggestedPosts'] as List<dynamic>?)
              //         ?.whereType<Post>()
              //         .toList() ?? [];
              //
              //     // If post object is passed via extra, use it.
              //     if (postFromExtra != null) {
              //       return PostDetailScreen(
              //           post: postFromExtra, suggestedPosts: suggestedPostsFromExtra);
              //     }
              //
              //     // Otherwise, fetch the post using postId.
              //     // suggestedPostsFromExtra will still be passed from extra, even if post is fetched.
              //     return FutureBuilder<Post>(
              //       future: PostService.fetchPost(postId), // Use your actual PostService
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const Scaffold(
              //               body: Center(child: CircularProgressIndicator()));
              //         } else if (snapshot.hasError) {
              //           return Scaffold(
              //               appBar: AppBar(title: const Text('Error')),
              //               body: Center(
              //                   child: Text('Error loading post: ${snapshot.error}')));
              //         } else if (snapshot.hasData) {
              //           return PostDetailScreen(
              //               post: snapshot.data!, suggestedPosts: suggestedPostsFromExtra);
              //         }
              //         return const Scaffold(body: Center(child: Text('Post not found')));
              //       },
              //     );
              //   },
              // ),
              GoRoute(
                path: 'search-results',
                name: 'searchResults',
                builder: (context, state) => const Text('Search Results Page'),
              ),
            ],
          ),

          // Celebrate Section - Main Bottom Nav Tab
          GoRoute(
            path: '/celebrate',
            name: 'celebrate',
            builder: (context, state) => const CelebratePage(),
            routes: [
              // No sub-routes listed here from your updated code.
              // If you add sub-routes here, they will pop back to '/celebrate'.
            ],
          ),

          // Flicks Section - Main Bottom Nav Tab
          GoRoute(
            path: '/flicks',
            name: 'flicks',
            builder: (context, state) => const FlicksPage(),
            routes: [
              // Any sub-routes for flicks
            ],
          ),

          // Stream Section - Main Bottom Nav Tab
          GoRoute(
            path: '/stream',
            name: 'stream',
            builder: (context, state) => const StreamPage(),
            routes: [
              // Live Stream Detail (pops back to Stream)
              // GoRoute(
              //   path: ':streamId', // Path is relative to /stream
              //   name: 'streamDetail',
              //   builder: (context, state) {
              //     final streamId = state.pathParameters['streamId']!;
              //     return LiveStreamDetailPage(streamId: streamId);
              //   },
              // ),
            ],
          ),

          // Profile Section - Main Bottom Nav Tab (own profile)
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              // Any sub-routes for profile (e.g., Edit Profile, Settings - though settings is top-level)
            ],
          ),
        ],
      ),
    ],
  );

  String? _guardRoutes(BuildContext context, GoRouterState state) {
    final isAuth = _authService.currentState.status == AuthStatus.authenticated;
    final isSplash = state.matchedLocation == '/splash';
    final isAuthScreen = state.matchedLocation == '/auth';
    final isOnboarding = state.matchedLocation == '/onboarding';
    final isVerification = state.matchedLocation == '/verification';
    final isCamera = state.matchedLocation == '/camera';
    final isCreateCelebrityProfile =
        state.matchedLocation == '/create-celebrity-profile';

    // List of public routes that don't require authentication
    final publicRoutes = [
      '/splash',
      '/auth',
      '/onboarding',
      '/verification',
      '/create-celebrity-profile', // This is part of registration flow
      '/camera',
      '/interests-selection'
    ];
    final isGoingToPublicRoute = publicRoutes.contains(state.matchedLocation);

    // If on splash screen, allow.
    if (isSplash) return null;

    // If not authenticated:
    //  - If going to a public route, allow.
    //  - Otherwise, redirect to auth.
    if (!isAuth) {
      return isGoingToPublicRoute ? null : '/auth';
    }

    // If authenticated:
    //  - If trying to go to auth, onboarding, verification, or create celebrity profile, redirect to feed.
    //    (Assuming these are part of the initial flow and shouldn't be accessible post-login)
    if (isAuth &&
        (isAuthScreen || isOnboarding || isVerification || isCreateCelebrityProfile)) {
      return '/feed';
    }

    // Otherwise, allow the navigation.
    return null;
  }
}

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/celebrate')) return 2;
    if (location.startsWith('/flicks')) return 3;
    if (location.startsWith('/stream')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0; // Default to Feed if no match
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/celebrate');
        break;
      case 3:
        context.go('/flicks');
        break;
      case 4:
        context.go('/stream');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }

  // Helper to check if the current location is a main tab root
  bool _isMainTabRoot(String location) {
    return location == '/feed' ||
        location == '/search' ||
        location == '/celebrate' ||
        location == '/flicks' ||
        location == '/stream' ||
        location == '/profile';
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current route is one that should NOT show the bottom nav.
    // Based on your requirements, only camera, webview should not have it.
    final currentRoutePath = GoRouterState.of(context).matchedLocation;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color indicatorColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    final Color selectedIconColor = Theme.of(context).colorScheme.primary;
    final Color unselectedIconColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color selectedLabelColor = isDark ? Colors.white : Colors.black;
    final Color unselectedLabelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final bool showBottomNav =
    !['/camera', '/webview'].contains(currentRoutePath);

    // Define selectedIndex and onDestinationSelected locally within build
    final int selectedIndex = _calculateSelectedIndex(context);
    void onDestinationSelected(int index) {
      _onItemTapped(index, context);
    }

    return PopScope(
      canPop: false, // We'll handle popping manually
      onPopInvoked: (didPop) async {
        if (didPop) return; // If system already popped, do nothing.

        final GoRouter router = GoRouter.of(context);
        final String currentLocation =
            router.routerDelegate.currentConfiguration.uri.path;

        // 1. Try to pop the current branch's navigator (e.g., from /search/view-profile to /search)
        if (didPop) return; // If system already popped, do nothing.

        // 1. Try to pop the current branch's navigator (e.g., from /search/view-profile to /search)
        if (router.canPop()) {
          router.pop();
        }
        // 2. If at a root bottom nav tab (e.g., /search, /celebrate) AND not /feed, go to /feed
        else
        if (_isMainTabRoot(currentLocation) && currentLocation != '/feed') {
          router.go('/feed');
        }
        // 3. If at /feed (and nothing more to pop), show exit dialog
        else if (currentLocation == '/feed') {
          bool shouldExit = await _showExitDialog(context);
          if (shouldExit && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: showBottomNav
            ? NavigationBar(
          height: 64,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: indicatorColor, // Direct property instead of theme
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.home, color: selectedIconColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.search, color: selectedIconColor),
              label: 'Celebrities',
            ),
            NavigationDestination(
              icon: Icon(Icons.celebration_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.celebration, color: selectedIconColor),
              label: 'Celebrate',
            ),
            NavigationDestination(
              icon: Icon(Icons.movie_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.movie, color: selectedIconColor),
              label: 'Flick',
            ),
            NavigationDestination(
              icon: Icon(Icons.live_tv_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.live_tv, color: selectedIconColor),
              label: 'Stream',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: unselectedIconColor),
              selectedIcon: Icon(Icons.person, color: selectedIconColor),
              label: 'Profile',
            ),
          ],
        )
            : null, // Hide bottom nav for specific routes
      ),
    );
  }
}

class RouteRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  RouteRefreshStream(Stream<AuthState> stream) {
    notifyListeners(); // Notify initially to get current state
    _subscription = stream.listen(
          (state) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}