// web_storage_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getFromWebStorage(String key) => html.window.localStorage[key];
void setToWebStorage(String key, String? value) {
  if (value == null) {
    html.window.localStorage.remove(key);
  } else {
    html.window.localStorage[key] = value;
  }
}
