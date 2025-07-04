import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:celebrating/models/live_stream.dart';
import '../utils/live_stream_video_manager.dart';

import '../utils/constants.dart';

class LiveStreamCard extends StatefulWidget {
  final LiveStream stream;
  final bool isActive;
  final VoidCallback? onStreamerTap;
  final ValueChanged<String>? onCategoryTap;
  final ValueChanged<String>? onTagTap;
  final VoidCallback? onTap;

  const LiveStreamCard({
    super.key,
    required this.stream,
    this.isActive = false,
    this.onStreamerTap,
    this.onCategoryTap,
    this.onTagTap,
    this.onTap,
  });

  @override
  State<LiveStreamCard> createState() => _LiveStreamCardState();
}

class _LiveStreamCardState extends State<LiveStreamCard> {
  late VideoPlayerController _controller;
  final videoManager = LiveStreamVideoManager();

  @override
  void initState() {
    super.initState();
    _controller = videoManager.getController(widget.stream.streamUrl, widget.stream.id);
    _controller.addListener(_onControllerUpdate);

    _controller.initialize().then((_) {
      if (mounted) {
        // Add a listener specifically for the first frame/size availability
        // This ensures play is called only when the video is truly ready to render.
        _controller.addListener(_playWhenReady);
        setState(() {}); // Trigger a rebuild to reflect initialization state
      }
    });
  }

  // New method to handle playing the video only when it's ready (initialized and has size)
  void _playWhenReady() {
    // Check if the controller is initialized AND has valid dimensions
    if (_controller.value.isInitialized &&
        _controller.value.size.width > 0 &&
        _controller.value.size.height > 0) {
      if (widget.isActive) {
        videoManager.pauseAllExcept(widget.stream.id);
        _controller.play();
      } else {
        _controller.pause();
      }
      // Remove this listener once played to avoid redundant calls,
      // as didUpdateWidget will handle future active changes.
      _controller.removeListener(_playWhenReady);
    }
  }

  @override
  void didUpdateWidget(covariant LiveStreamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        // Only attempt to play if the controller is already ready.
        // Otherwise, add the _playWhenReady listener to wait for readiness.
        if (_controller.value.isInitialized &&
            _controller.value.size.width > 0 &&
            _controller.value.size.height > 0) {
          videoManager.pauseAllExcept(widget.stream.id);
          _controller.play();
        } else {
          _controller.addListener(_playWhenReady);
        }
      } else {
        _controller.pause();
        // If we pause, and a _playWhenReady listener was active, remove it.
        _controller.removeListener(_playWhenReady);
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.removeListener(_playWhenReady); // Ensure this listener is also removed
    super.dispose();
  }

  bool get _isActuallyPlaying {
    if (!_controller.value.isInitialized) return false;
    final value = _controller.value;
    return value.isPlaying && !value.isBuffering && !value.hasError;
  }

  @override
  Widget build(BuildContext context) {
    // Simplified showVideo condition to rely directly on controller's state
    final showVideo = _controller.value.isInitialized &&
        !_controller.value.hasError &&
        _controller.value.size.width > 0 &&
        _controller.value.size.height > 0;

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: showVideo
                    ? VideoPlayer(_controller)
                    : Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      _controller.value.hasError
                          ? 'Video error'
                          : 'Loading stream...',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              if (widget.stream.isLive)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        formatCount(widget.stream.viewerCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ProfileAvatar(
                imageUrl: widget.stream.streamer.profileImageUrl,
                radius: 20,
              ),
              const SizedBox(width: 5,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.stream.streamer.fullName),
                  Text(
                    widget.stream.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}