import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:celebrating/models/live_stream.dart';
import '../services/live_stream_video_manager.dart';

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
  bool _initialized = false;
  final videoManager = LiveStreamVideoManager();

  @override
  void initState() {
    super.initState();
    _controller = videoManager.getController(widget.stream.streamUrl, widget.stream.id);
    _controller.addListener(_onControllerUpdate);
    _controller.initialize().then((_) {
      setState(() {
        _initialized = true;
      });
      if (widget.isActive) {
        videoManager.pauseAllExcept(widget.stream.id);
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant LiveStreamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        videoManager.pauseAllExcept(widget.stream.id);
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                aspectRatio: _initialized ? _controller.value.aspectRatio : 16 / 9,
                child: Hero(
                  tag: 'live_stream_${widget.stream.id}',
                  child: VideoPlayer(_controller),
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
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 12),
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
              if (!_initialized)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
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
                    widget.stream.description, // The text content goes here
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis, // Corrected enum value
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
