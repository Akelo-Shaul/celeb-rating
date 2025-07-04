import 'package:just_audio/just_audio.dart';

class AudioCardControllerManager {
  AudioCardControllerManager._private();
  static final AudioCardControllerManager instance = AudioCardControllerManager._private();

  final Map<String, AudioPlayer> _players = {};

  void add(String id, AudioPlayer player) {
    _players[id] = player;
  }

  void remove(String id) {
    _players.remove(id)?.dispose();
  }

  void disposeAll() {
    _players.forEach((_, player) {
      player.stop();
      player.dispose();
    });
    _players.clear();
  }

  Map<String, AudioPlayer> get allPlayers => _players;
}
