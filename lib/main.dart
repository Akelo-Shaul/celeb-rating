import 'package:celebrating/services/auth_service.dart';
import 'package:celebrating/theme/app_theme.dart';
import 'package:celebrating/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:celebrating/l10n/app_localizations.dart';
import 'package:celebrating/l10n/supported_languages.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CelebratingApp(),
    ),
  );
}

class CelebratingApp extends StatefulWidget {
  const CelebratingApp({super.key});

  @override
  State<CelebratingApp> createState() => _CelebratingAppState();
}

class _CelebratingAppState extends State<CelebratingApp> {
  final _authService = AuthService.instance;
  late final _router = AppRouter(_authService);

  @override
  void initState() {
    super.initState();
    _authService.initialize();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp.router(
      title: 'Celebrating',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      routerConfig: _router.router,
      debugShowCheckedModeBanner: false,
      locale: appState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
