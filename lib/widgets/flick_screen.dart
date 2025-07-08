import 'package:celebrating/models/flick.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/comment.dart';
import 'comments_modal.dart';

// --- FlickControllerManager: Only one controller active at a time ---
class FlickControllerManager {
  static VideoPlayerController? _activeController;

  static Future<VideoPlayerController> setActive(String url, {bool muted = true}) async {
    await _activeController?.pause();
    await _activeController?.dispose();
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(muted ? 0.0 : 1.0);
    controller.play();
    _activeController = controller;
    return controller;
  }

  static void disposeActive() {
    _activeController?.dispose();
    _activeController = null;
  }
}

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
    FlickControllerManager.disposeActive();
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
          return _FlickPlayer(flick: flick);
        },
      ),
    );
  }
}

class _FlickPlayer extends StatefulWidget {
  final Flick flick;
  const _FlickPlayer({required this.flick});
  @override
  State<_FlickPlayer> createState() => _FlickPlayerState();
}

class _FlickPlayerState extends State<_FlickPlayer> {
  VideoPlayerController? _controller;
  late Future<void> _initFuture;
  bool _muted = true;
  bool _showRatingSection = false;
  int _currentRating = 0;
  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _ratingKey = GlobalKey();
  bool _isRatingSectionActive = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _initController();
    _currentRating = 0;
  }

  Future<void> _initController() async {
    _controller = await FlickControllerManager.setActive(widget.flick.flickUrl, muted: _muted);
    if (mounted) setState(() {});
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller?.setVolume(_muted ? 0.0 : 1.0);
    });
  }

  void _showCommentsModal(BuildContext context, List<Comment> comments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: CommentsModal(
            comments: comments,
            postId: widget.flick.id,
          ),
        );
      },
    );
  }

  Widget _buildRatingSection() {
    // Show static stars if already rated by user, else allow rating
    // Replace with actual user id from auth/user provider in real app
    const String currentUserId = '1';
    final int? userRating = widget.flick.userRatings[currentUserId];
    final bool hasRated = userRating != null && userRating > 0;
    final int rating = hasRated ? userRating : _currentRating;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isRatingSectionActive = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isRatingSectionActive = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isRatingSectionActive = false;
        });
      },
      child: Opacity(
        opacity: _isRatingSectionActive ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isRated = rating >= (index + 1);
              final starColor = isRated ? Colors.orange : Colors.grey[400];
              if (hasRated) {
                return Icon(
                  Icons.star_rounded,
                  color: starColor,
                  size: 30,
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentRating = index + 1;
                      widget.flick.userRatings[currentUserId] = _currentRating;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You rated ${index + 1} stars!')),
                      );
                    });
                  },
                  child: Icon(
                    Icons.star_rounded,
                    color: starColor,
                    size: 30,
                  ),
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            if (snapshot.connectionState == ConnectionState.done && _controller != null) {
              return VideoPlayer(_controller!);
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
              _buildRatingSection(),
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
                // Removed rating section from here, only show thumb up icon
                _buildActionItem(
                  icon:  Icons.thumb_up_alt_outlined,
                  count: widget.flick.likes.length,
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
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 15,
          child: FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // While loading, show progress bar at 0
                return LinearProgressIndicator(
                  value: 0.0,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  minHeight: 4,
                );
              }
              // Only show progress bar when controller is ready
              return ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller!,
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
