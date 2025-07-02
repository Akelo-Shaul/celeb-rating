import 'package:celebrating/models/flick.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FlickCard extends StatefulWidget {
  final Flick flick;
  final Function(Flick) onTap;
  final bool isActive;

  const FlickCard({super.key, required this.flick, required this.onTap, this.isActive = false});

  @override
  State<FlickCard> createState() => _FlickCardState();
}

class _FlickCardState extends State<FlickCard> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.flick.flickUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.setVolume(0.0);
      if (widget.isActive) {
        _controller.play();
      } else {
        _controller.pause();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant FlickCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(widget.flick),
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
                bottom: 3,
                right: 3,
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white, size: 18),
                    Text(widget.flick.views.toString(), style: TextStyle(color: Colors.white)),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
