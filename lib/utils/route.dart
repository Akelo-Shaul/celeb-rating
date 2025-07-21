import 'package:celebrating/screens/auth_screen.dart';
import 'package:celebrating/screens/award_screen.dart';
import 'package:celebrating/screens/camera_screen.dart';
import 'package:celebrating/screens/hall_of_fame.dart';
import 'package:celebrating/screens/onboarding_screen.dart';
import 'package:celebrating/screens/verification_screen.dart';
import 'package:celebrating/screens/web_view_screen.dart';
import 'package:celebrating/widgets/flick_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/versus_user.dart';
import '../screens/celebrity_profile_create.dart';
import '../screens/head_to_head_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/uhondo_kona.dart';
import '../screens/versus_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/search_page.dart';
import '../screens/celebrate_page.dart';
import '../screens/flicks_page.dart';
import '../screens/stream_page.dart';
import '../screens/profile_page.dart';

import 'package:go_router/go_router.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/video_player_widget.dart';

// Route Constants
class AppRoutes {
  static const String splashScreen = '/';
  static const String authScreen = '/auth';
  static const String onboardingScreen = '/onboarding';
  static const String feedScreen = '/feed';
  static const String searchScreen = '/search';
  static const String postScreen = '/post';
  static const String reelsScreen = '/reels';
  static const String streamScreen = '/stream';
  static const String profileScreen = '/profile';
  static const String mainNavShell = '/mainNavigation';
  static const String flickScreen = '/flick';
  static const String cameraScreen = '/camera';
  static const String verificationScreen = '/verification';
  static const String celebrityProfileCreate = '/celebrity-profile-create';
  static const String hallOfFame = '/hall-of-fame';
  static const String versusScreen = '/versus';
  static const String awardScreen = '/award';
  static const String headToHeadScreen = '/head-to-head';
  static const String uhondoKona = '/uhondo-kona';
  static const String webView = '/webview';
}

// Custom Shell Widget that properly handles both tab and non-tab routes
class AppShell extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const AppShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int get _selectedIndex => _getTabIndexFromLocation(widget.state.matchedLocation);

  bool get _isTabRoute => _isMainTabRoute(widget.state.matchedLocation);

  @override
  void dispose() {
    // Dispose of the current video controller when the shell is removed from the widget tree.
    PostCardVideoPlaybackManager().disposeCurrentController();
    super.dispose();
  }

  void _onNavSelected(int index) {
    // Pause current video when switching tabs
    if (_selectedIndex != index && _isTabRoute) {
      PostCardVideoPlaybackManager().pauseCurrent();
    }
    // Navigate to corresponding route using go_router
    switch (index) {
      case 0:
        context.go(AppRoutes.feedScreen);
        break;
      case 1:
        context.go(AppRoutes.searchScreen);
        break;
      case 2:
        context.go(AppRoutes.postScreen);
        break;
      case 3:
        context.go(AppRoutes.reelsScreen);
        break;
      case 4:
        context.go(AppRoutes.streamScreen);
        break;
      case 5:
        context.go(AppRoutes.profileScreen);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        final String currentLocation = widget.state.matchedLocation;

        // If we're already on feed screen, allow app to close
        if (currentLocation == '/feed') {
          SystemNavigator.pop(); // Close the app
          return;
        }

        // If we're on any other screen, go to feed first
        context.go('/feed');
      },
      child: Scaffold(
        body: _isTabRoute
            ? IndexedStack(
          index: _selectedIndex,
          children: const [
            FeedScreen(),
            SearchPage(),
            CelebratePage(),
            FlicksPage(),
            StreamPage(),
            ProfilePage(),
          ],
        )
            : widget.child, // Show the actual page for non-tab routes
        bottomNavigationBar: BottomNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavSelected,
        ),
      ),
    );
  }
}

// Go Router Configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashScreen,
  errorBuilder: (context, state) => _ErrorScreen(error: state.error.toString()),
  routes: [
    // Routes without bottom navigation (pre-home screens)
    GoRoute(
      path: AppRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.authScreen,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingScreen,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.verificationScreen,
      builder: (context, state) => const VerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.celebrityProfileCreate,
      builder: (context, state) => const CelebrityProfileCreate(),
    ),

    // Camera screen without bottom navigation
    GoRoute(
      path: AppRoutes.cameraScreen,
      builder: (context, state) => const CameraScreen(returnRoute: '',),
    ),

    // Flick screen with arguments (without bottom navigation)
    GoRoute(
      path: AppRoutes.flickScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra != null) {
          final flicks = extra['flicks'] as List?;
          final initialIndex = extra['initialIndex'] as int? ?? 0;
          if (flicks != null) {
            return FlickScreen(
              flicks: List.castFrom(flicks),
              initialIndex: initialIndex,
            );
          }
        }
        return const FlickScreen(flicks: [], initialIndex: 0);
      },
    ),

    // Head to Head screen with arguments (without bottom navigation)
    GoRoute(
      path: AppRoutes.headToHeadScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra != null) {
          final user1 = extra['user1'];
          final user2 = extra['user2'];
          if (user1 != null && user2 != null) {
            return HeadToHead(user1: user1, user2: user2);
          }
        }
        return const HeadToHead(
          user1: VersusUser(id: '', name: '', imageUrl: ''),
          user2: VersusUser(id: '', name: '', imageUrl: ''),
        );
      },
    ),

    // WebView screen with URL parameter (without bottom navigation)
    GoRoute(
      path: '${AppRoutes.webView}/:url',
      builder: (context, state) {
        final url = state.pathParameters['url'] ?? '';
        return WebView(url: Uri.decodeComponent(url));
      },
    ),
    // WebView without parameter (for backward compatibility)
    GoRoute(
      path: AppRoutes.webView,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final url = extra?['url'] as String? ?? '';
        return WebView(url: url);
      },
    ),

    // Shell Route with Bottom Navigation
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          state: state,
          child: child,
        );
      },
      routes: [
        // Main navigation tabs
        GoRoute(
          path: AppRoutes.mainNavShell,
          redirect: (context, state) => AppRoutes.feedScreen, // Redirect root to feed
        ),
        GoRoute(
          path: AppRoutes.feedScreen,
          builder: (context, state) => const FeedScreen(),
        ),
        GoRoute(
          path: AppRoutes.searchScreen,
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: AppRoutes.postScreen,
          builder: (context, state) => const CelebratePage(),
        ),
        GoRoute(
          path: AppRoutes.reelsScreen,
          builder: (context, state) => const FlicksPage(),
        ),
        GoRoute(
          path: AppRoutes.streamScreen,
          builder: (context, state) => const StreamPage(),
        ),
        GoRoute(
          path: AppRoutes.profileScreen,
          builder: (context, state) => const ProfilePage(),
        ),

        // Other screens that should have bottom navigation
        GoRoute(
          path: AppRoutes.hallOfFame,
          builder: (context, state) => const HallOfFame(),
        ),
        GoRoute(
          path: AppRoutes.versusScreen,
          builder: (context, state) => const VersusScreen(),
        ),
        GoRoute(
          path: AppRoutes.awardScreen,
          builder: (context, state) => const AwardScreen(),
        ),
        GoRoute(
          path: AppRoutes.uhondoKona,
          builder: (context, state) => const UhondoKona(),
        ),
      ],
    ),
  ],
);

// Helper function to check if the route is a main tab route
bool _isMainTabRoute(String location) {
  String path = location.split('?').first;
  return [
    AppRoutes.feedScreen,
    AppRoutes.searchScreen,
    AppRoutes.postScreen,
    AppRoutes.reelsScreen,
    AppRoutes.streamScreen,
    AppRoutes.profileScreen,
    AppRoutes.mainNavShell,
  ].contains(path);
}

// Helper function to map routes to tab indices
int _getTabIndexFromLocation(String location) {
  String path = location.split('?').first;

  switch (path) {
    case AppRoutes.feedScreen:
    case AppRoutes.mainNavShell:
      return 0;
    case AppRoutes.searchScreen:
      return 1;
    case AppRoutes.postScreen:
      return 2;
    case AppRoutes.reelsScreen:
      return 3;
    case AppRoutes.streamScreen:
      return 4;
    case AppRoutes.profileScreen:
      return 5;
    default:
      return 0; // Default to feed for non-tab routes like hall-of-fame, versus, etc.
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ERROR'),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.feedScreen),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

extension AppNavigation on BuildContext {
  // Main navigation
  void goToFeed() => go(AppRoutes.feedScreen);
  void goToSearch() => go(AppRoutes.searchScreen);
  void goToPost() => go(AppRoutes.postScreen);
  void goToReels() => go(AppRoutes.reelsScreen);
  void goToStream() => go(AppRoutes.streamScreen);
  void goToProfile() => go(AppRoutes.profileScreen);

  // Auth flow
  void goToAuth() => go(AppRoutes.authScreen);
  void goToOnboarding() => go(AppRoutes.onboardingScreen);
  void goToVerification() => go(AppRoutes.verificationScreen);
  void goToCelebrityProfileCreate() => go(AppRoutes.celebrityProfileCreate);

  // Modal screens (without bottom nav)
  void pushCamera() => push(AppRoutes.cameraScreen);

  // Screens with arguments (without bottom nav)
  void pushFlick({required List flicks, int initialIndex = 0}) {
    push(AppRoutes.flickScreen, extra: {
      'flicks': flicks,
      'initialIndex': initialIndex,
    });
  }

  void pushHeadToHead({required dynamic user1, required dynamic user2}) {
    push(AppRoutes.headToHeadScreen, extra: {
      'user1': user1,
      'user2': user2,
    });
  }

  void pushWebView({required String url}) {
    push('${AppRoutes.webView}/${Uri.encodeComponent(url)}');
  }

  // Shell routes (with bottom navigation) - use go() instead of push()
  void goToHallOfFame() => go(AppRoutes.hallOfFame);
  void goToVersus() => go(AppRoutes.versusScreen);
  void goToAward() => go(AppRoutes.awardScreen);
  void goToUhondoKona() => go(AppRoutes.uhondoKona);
}