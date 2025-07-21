import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoCache {
  static final VideoCache _instance = VideoCache._internal();
  factory VideoCache() => _instance;
  VideoCache._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, Future<void>> _initFutures = {};
  final int _maxCacheSize = 10; // Adjust based on memory constraints

  VideoPlayerController? getController(String url) {
    return _controllers[url];
  }

  Future<VideoPlayerController> getOrCreateController(String url) async {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    }

    // Remove oldest controller if cache is full
    if (_controllers.length >= _maxCacheSize) {
      final oldestKey = _controllers.keys.first;
      _controllers[oldestKey]?.dispose();
      _controllers.remove(oldestKey);
      _initFutures.remove(oldestKey);
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[url] = controller;

    // Cache the initialization future
    _initFutures[url] = controller.initialize().then((_) {
      controller.setLooping(true);
      controller.setVolume(0.0);
    });

    await _initFutures[url];
    return controller;
  }

  Future<void>? getInitFuture(String url) {
    return _initFutures[url];
  }

  void preloadVideos(List<String> urls) {
    for (String url in urls) {
      if (!_controllers.containsKey(url) && _controllers.length < _maxCacheSize) {
        getOrCreateController(url).catchError((e) {
          print('Preload failed for $url: $e');
        });
      }
    }
  }

  bool isInitialized(String url) {
    return _controllers.containsKey(url) &&
        _controllers[url]!.value.isInitialized;
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initFutures.clear();
  }
}