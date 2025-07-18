import 'package:celebrating/screens/auth_screen.dart';
import 'package:celebrating/screens/award_screen.dart';
import 'package:celebrating/screens/camera_screen.dart';
import 'package:celebrating/screens/feed_screen.dart';
import 'package:celebrating/screens/hall_of_fame.dart';
import 'package:celebrating/screens/onboarding_screen.dart';
import 'package:celebrating/screens/search_page.dart';
import 'package:celebrating/screens/celebrate_page.dart';
import 'package:celebrating/screens/flicks_page.dart';
import 'package:celebrating/screens/stream_page.dart';
import 'package:celebrating/screens/profile_page.dart';
import 'package:celebrating/screens/main_navigation_shell.dart';
import 'package:celebrating/screens/verification_screen.dart';
import 'package:celebrating/screens/web_view_screen.dart';
import 'package:celebrating/widgets/flick_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/versus_user.dart';
import '../screens/celebrity_profile_create.dart';
import '../screens/head_to_head_screen.dart';
import '../screens/uhondo_kona.dart';
import '../screens/versus_screen.dart';

const String authScreen = '/auth';
const String onboardingScreen = '/onboarding';
const String feedScreen = '/feed';
const String searchScreen = '/search';
const String postScreen = '/post';
const String reelsScreen = '/reels';
const String streamScreen = '/stream';
const String profileScreen = '/profile';
const String mainNavShell = '/';
const String flickScreen = '/flick';
const String cameraScreen = 'camera';
const String verificationScreen = '/verificationScreen';
const String celebrityProfileCreate = '/celebrityProfileCreate';
const String hallOfFame = '/hallOfFame';
const String versusScreen = '/versusScreen';
const String awardScreen = '/awardScreen';
const String headToHeadScreen = '/headToHead';
const String uhondoKona = '/uhondoKona';
const String webView = '/webView';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case authScreen:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case feedScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 0));
      case searchScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 1));
      case postScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 2));
      case reelsScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 3));
      case streamScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 4));
      case profileScreen:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell(initialTab: 5));
      case mainNavShell:
        return MaterialPageRoute(builder: (_) => const MainNavigationShell());
      case cameraScreen:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      case verificationScreen:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case celebrityProfileCreate:
        return MaterialPageRoute(builder: (_) => const CelebrityProfileCreate());
      case flickScreen:
        if (settings.arguments is Map) {
          final args = settings.arguments as Map;
          final flicks = args['flicks'] as List?;
          final initialIndex = args['initialIndex'] as int? ?? 0;
          if (flicks != null) {
            return MaterialPageRoute(
              builder: (_) => FlickScreen(
                flicks: List.castFrom(flicks),
                initialIndex: initialIndex,
              ),
            );
          }
        }
        return MaterialPageRoute(builder: (_) => const FlickScreen(flicks: [], initialIndex: 0));
      case hallOfFame:
        return MaterialPageRoute(builder: (_) => const HallOfFame());
      case versusScreen:
        return MaterialPageRoute(builder: (_) => const VersusScreen());
      case awardScreen:
        return MaterialPageRoute(builder: (_) => const AwardScreen());
      case headToHeadScreen:
        if (settings.arguments is Map) {
          final args = settings.arguments as Map;
          final user1 = args['user1'];
          final user2 = args['user2'];
          if (user1 != null && user2 != null) {
            return MaterialPageRoute(
              builder: (_) => HeadToHead(user1: user1, user2: user2),
            );
          }
        }
        return MaterialPageRoute(builder: (_) => const HeadToHead(user1: VersusUser(id: '', name: '', imageUrl: ''), user2: VersusUser(id: '', name: '', imageUrl: '')));
      case uhondoKona:
        return MaterialPageRoute(builder: (_) => const UhondoKona());
      case webView:
        String? urlArg;
        if (settings.arguments is Map) {
          final args = settings.arguments as Map;
          urlArg = args['url'] as String?;
        } else if (settings.arguments is String) {
          urlArg = settings.arguments as String?;
        }
        if (urlArg != null && urlArg.isNotEmpty) {
          return MaterialPageRoute(builder: (_) => WebView(url: urlArg!));
        }
        return MaterialPageRoute(builder: (_) => const WebView(url: ''));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}