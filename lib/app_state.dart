import 'package:celebrating/web_storage_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;
  String? _jwtToken;
  String? _userId;
  String? _email;
  String? _refreshToken;
  String? get jwtToken => _jwtToken;
  String? get userId => _userId;
  String? get email => _email;
  String? get refreshToken => _refreshToken;
  // Add this getter to provide the user's avatar URL for UI
  String? get userAvatarUrl => _userAvatarUrl;
  String? _userAvatarUrl;

  Future<void> init() async {
    String? token;
    String? userId;
    String? email;
    String? refreshToken;
    if (kIsWeb) {
      try {
        token = getFromWebStorage('jwtToken');
        userId = getFromWebStorage('userId');
        email = getFromWebStorage('email');
        refreshToken = getFromWebStorage('refreshToken');
      } catch (e) {
        // ignore
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('jwtToken');
      userId = prefs.getString('userId');
      email = prefs.getString('email');
      refreshToken = prefs.getString('refreshToken');
    }
    if (token != null && token.isNotEmpty) {
      _jwtToken = token;
      _userId = userId;
      _email = email;
      _refreshToken = refreshToken;
      notifyListeners();
    }
  }

  set jwtToken(String? token) {
    _jwtToken = token;
    notifyListeners();
    // Persist token
    if (kIsWeb) {
      try {
        setToWebStorage('jwtToken', token);
      } catch (e) {
        // ignore
      }
    } else {
      _persistTokenMobile(token);
    }
  }

  set userId(String? id) {
    _userId = id;
    notifyListeners();
    if (kIsWeb) {
      try {
        setToWebStorage('userId', id);
      } catch (e) {
        // ignore
      }
    } else {
      _persistUserIdMobile(id);
    }
  }

  set email(String? emailVal) {
    _email = emailVal;
    notifyListeners();
    if (kIsWeb) {
      try {
        setToWebStorage('email', emailVal);
      } catch (e) {
        // ignore
      }
    } else {
      _persistEmailMobile(emailVal);
    }
  }

  set refreshToken(String? token) {
    _refreshToken = token;
    notifyListeners();
    if (kIsWeb) {
      try {
        setToWebStorage('refreshToken', token);
      } catch (e) {
        // ignore
      }
    } else {
      _persistRefreshTokenMobile(token);
    }
  }

  set userAvatarUrl(String? url) {
    _userAvatarUrl = url;
    notifyListeners();
    if (kIsWeb) {
      try {
        setToWebStorage('userAvatarUrl', url);
      } catch (e) {
        // ignore
      }
    } else {
      _persistUserAvatarUrlMobile(url);
    }
  }

  Future<void> _persistTokenMobile(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('jwtToken', token);
    } else {
      await prefs.remove('jwtToken');
    }
  }

  Future<void> _persistUserIdMobile(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString('userId', id);
    } else {
      await prefs.remove('userId');
    }
  }

  Future<void> _persistEmailMobile(String? emailVal) async {
    final prefs = await SharedPreferences.getInstance();
    if (emailVal != null) {
      await prefs.setString('email', emailVal);
    } else {
      await prefs.remove('email');
    }
  }

  Future<void> _persistRefreshTokenMobile(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('refreshToken', token);
    } else {
      await prefs.remove('refreshToken');
    }
  }

  Future<void> _persistUserAvatarUrlMobile(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      await prefs.setString('userAvatarUrl', url);
    } else {
      await prefs.remove('userAvatarUrl');
    }
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }
}
