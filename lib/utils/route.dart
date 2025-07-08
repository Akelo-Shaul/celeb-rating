import 'package:celebrating/screens/auth_screen.dart';
import 'package:celebrating/screens/camera_screen.dart';
import 'package:celebrating/screens/feed_screen.dart';
import 'package:celebrating/screens/onboarding_screen.dart';
import 'package:celebrating/screens/search_page.dart';
import 'package:celebrating/screens/celebrate_page.dart';
import 'package:celebrating/screens/flicks_page.dart';
import 'package:celebrating/screens/stream_page.dart';
import 'package:celebrating/screens/profile_page.dart';
import 'package:celebrating/screens/main_navigation_shell.dart';
import 'package:celebrating/screens/verification_screen.dart';
import 'package:celebrating/widgets/flick_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/celebrity_profile_create.dart';

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