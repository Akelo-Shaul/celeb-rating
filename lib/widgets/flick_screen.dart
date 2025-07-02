import 'package:celebrating/models/flick.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/comment.dart';
import 'comments_modal.dart';

class FlickScreen extends StatefulWidget {
  final List<Flick> flicks;
  final int initialIndex;
  const FlickScreen({super.key, required this.flicks, this.initialIndex = 0});

  @override
  State<FlickScreen> createState() => _FlickScreenState();
}

class _FlickScreenState extends State<FlickScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.flicks.length,
        itemBuilder: (context, index) {
          final flick = widget.flicks[index];
          return _FlickReelPlayer(flick: flick);
        },
      ),
    );
  }
}

class _FlickReelPlayer extends StatefulWidget {
  final Flick flick;
  const _FlickReelPlayer({required this.flick});
  @override
  State<_FlickReelPlayer> createState() => _FlickReelPlayerState();
}

class _FlickReelPlayerState extends State<_FlickReelPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initFuture;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.flick.flickUrl));
    _initFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.setVolume(_muted ? 0.0 : 1.0);
      _controller.play();
      setState(() {});
    });
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller.setVolume(_muted ? 0.0 : 1.0);
    });
  }

  void _showCommentsModal(BuildContext context, List<Comment> comments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85, // Adjust this to control how much screen height the modal takes
          child: CommentsModal(
            comments: comments,
            postId: widget.flick.id,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return VideoPlayer(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned(
          bottom: 32,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.flick.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('by ${widget.flick.creator.username}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(widget.flick.views.toString(), style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionItem(
                  icon: Icons.star_border_outlined,
                  count: widget.flick.likes.length,
                  onTap: (){},
                ),
                const SizedBox(height: 24),
                _buildActionItem(
                  icon: Icons.chat_bubble_outline,
                  count: widget.flick.comments.length,
                  onTap: (){
                    _showCommentsModal(context, widget.flick.comments);
                  },
                ),
                const SizedBox(height: 24),
                _buildActionItem(
                  icon: Icons.send_outlined,
                  count: 0, // Replace with actual share count if available
                  onTap: (){},
                ),
                const SizedBox(height: 24),
                _buildActionItem(
                  icon: Icons.bookmark_border_outlined,
                  count: 0, // Replace with actual save count if available
                  onTap: () {
                    print('Save');
                  },
                ),
                const SizedBox(height: 24),
                _buildActionItem(
                  icon: _muted ? Icons.volume_off : Icons.volume_up,
                  count: null,
                  onTap: _toggleMute,
                ),
                const SizedBox(height: 48), // Space for bottom navigation if any
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 15,
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final progress = value.duration.inMilliseconds > 0
                  ? value.position.inMilliseconds / value.duration.inMilliseconds
                  : 0.0;
              return LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                minHeight: 4,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    int? count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        print('tapped');
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          if (count != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
