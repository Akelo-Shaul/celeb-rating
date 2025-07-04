import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/live_stream.dart';
import '../utils/live_stream_video_manager.dart';

class LiveStreamDetailPage extends StatefulWidget {
  final LiveStream stream;
  const LiveStreamDetailPage({super.key, required this.stream});

  @override
  State<LiveStreamDetailPage> createState() => _LiveStreamDetailPageState();
}

class _LiveStreamDetailPageState extends State<LiveStreamDetailPage> {
  late VideoPlayerController _controller;
  final videoManager = LiveStreamVideoManager();

  @override
  void initState() {
    super.initState();
    _controller = videoManager.getController(widget.stream.streamUrl, widget.stream.id);
    _controller.addListener(_onControllerUpdate);
    _controller.initialize().then((_) {
      setState(() {});
      videoManager.unmute(widget.stream.id);
      _controller.play();
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    videoManager.mute(widget.stream.id); // Mute when leaving detail
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'live_stream_${widget.stream.id}',
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Add overlays/info as needed
        ],
      ),
    );
  }
}
