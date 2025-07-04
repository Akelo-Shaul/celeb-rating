import 'package:video_player/video_player.dart';

class FlickCardControllerManager {
  FlickCardControllerManager._private();
  static final FlickCardControllerManager instance = FlickCardControllerManager._private();

  final Map<String, VideoPlayerController> _controllers = {};

  void add(String id, VideoPlayerController controller) {
    _controllers[id] = controller;
  }

  void remove(String id) {
    _controllers.remove(id)?.dispose();
  }

  void disposeAll() {
    _controllers.forEach((_, controller) {
      controller.pause();
      controller.dispose();
    });
    _controllers.clear();
  }

  Map<String, VideoPlayerController> get allControllers => _controllers;
}
