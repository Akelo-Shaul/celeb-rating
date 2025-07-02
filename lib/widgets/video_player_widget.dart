import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Global manager for video playback in post cards (feed)
class PostCardVideoPlaybackManager {
  static final PostCardVideoPlaybackManager _instance = PostCardVideoPlaybackManager._internal();
  factory PostCardVideoPlaybackManager() => _instance;
  PostCardVideoPlaybackManager._internal();

  VideoPlayerController? _currentController;

  void play(VideoPlayerController controller) {
    if (_currentController != null && _currentController != controller) {
      _currentController!.pause();
    }
    _currentController = controller;
    controller.play();
  }

  void pauseCurrent() {
    _currentController?.pause();
  }

  void disposeCurrent(VideoPlayerController controller) {
    if (_currentController == controller) {
      _currentController = null;
    }
    controller.dispose();
  }

  void disposeCurrentController() {
    if (_currentController != null) {
      _currentController!.pause();
      _currentController!.dispose();
      _currentController = null;
    }
  }
}

/// Video playback mode for AppVideoPlayerWidget
enum VideoPlaybackMode {
  globalSingle, // Only one video at a time (feed screen)
  independent,  // Multiple videos can play (search, stream, etc.)
}

/// Reusable video player widget for all screens
class AppVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoplay;
  final bool looping;
  final double? aspectRatio;
  final VideoPlaybackMode playbackMode;
  final bool muted;
  final PostCardVideoPlaybackManager? customManager;
  final bool showMuteButton;
  final VoidCallback? onMuteToggle;

  const AppVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoplay = false,
    this.looping = true,
    this.aspectRatio,
    this.playbackMode = VideoPlaybackMode.globalSingle, // default for feed
    this.muted = false,
    this.customManager,
    this.showMuteButton = false,
    this.onMuteToggle,
  });

  @override
  State<AppVideoPlayerWidget> createState() => _AppVideoPlayerWidgetState();
}

class _AppVideoPlayerWidgetState extends State<AppVideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeFuture;
  late bool _muted;
  ValueNotifier<bool>? _externalMuteNotifier;

  @override
  void initState() {
    super.initState();
    _muted = widget.muted;
    _externalMuteNotifier = widget.onMuteToggle != null ? null : null; // placeholder for future
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeFuture = _controller.initialize().then((_) {
      _controller.setLooping(widget.looping);
      _controller.setVolume(_muted ? 0.0 : 1.0);
      if (widget.autoplay) {
        if (widget.playbackMode == VideoPlaybackMode.globalSingle && widget.customManager != null) {
          widget.customManager!.play(_controller);
        } else if (widget.playbackMode == VideoPlaybackMode.globalSingle) {
          _controller.play();
        } else {
          _controller.play();
        }
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.muted != oldWidget.muted) {
      setState(() {
        _muted = widget.muted;
        _controller.setVolume(_muted ? 0.0 : 1.0);
      });
    }
  }

  void _toggleMute() {
    if (widget.onMuteToggle != null) {
      widget.onMuteToggle!();
    } else {
      setState(() {
        _muted = !_muted;
        _controller.setVolume(_muted ? 0.0 : 1.0);
      });
    }
  }

  @override
  void dispose() {
    if (widget.playbackMode == VideoPlaybackMode.globalSingle && widget.customManager != null) {
      widget.customManager!.disposeCurrent(_controller);
    } else {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onPlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        if (widget.playbackMode == VideoPlaybackMode.globalSingle && widget.customManager != null) {
          widget.customManager!.play(_controller);
        } else {
          _controller.play();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: _onPlayPause,
            child: AspectRatio(
              aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  if (!_controller.value.isPlaying)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 70),
                      ),
                    ),
                  if (widget.showMuteButton)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading video: \n${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
