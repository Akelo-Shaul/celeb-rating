// Only imported on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AppStateWeb {
  static String? localStorageGet(String key) {
    return html.window.localStorage[key];
  }

  static void localStorageSet(String key, String value) {
    html.window.localStorage[key] = value;
  }
} 