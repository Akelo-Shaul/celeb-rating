import 'package:celebrating/screens/auth_screen.dart';
import 'package:celebrating/screens/feed_screen.dart';
import 'package:celebrating/screens/onboarding_screen.dart';
import 'package:celebrating/screens/search_page.dart';
import 'package:celebrating/screens/post_page.dart';
import 'package:celebrating/screens/reels_page.dart';
import 'package:celebrating/screens/stream_page.dart';
import 'package:celebrating/screens/profile_page.dart';
import 'package:celebrating/screens/main_navigation_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String authScreen = '/auth';
const String onboardingScreen = '/onboarding';
const String feedScreen = '/feed';
const String searchScreen = '/search';
const String postScreen = '/post';
const String reelsScreen = '/reels';
const String streamScreen = '/stream';
const String profileScreen = '/profile';
const String mainNavShell = '/';

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