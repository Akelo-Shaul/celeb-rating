import 'package:celebrating/models/flick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

import '../models/comment.dart';
import '../models/like.dart';
import '../services/user_service.dart';
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
  late bool _isLiked;
  bool _isBookmarked = false; // Add bookmark state

  @override
  void initState() {
    super.initState();
    _initFuture = _initController();
    _currentRating = 0;
    _initLikeState();
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

  void _initLikeState() {
    final String userId = UserService.currentUserId.toString();
    _isLiked = widget.flick.likes.any((like) => like.userId == userId);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              crossAxisAlignment: CrossAxisAlignment.center, // Aligns content of this Column horizontally
              children: [
                // Like/Salute Button
                GestureDetector(
                  onTap: () async {
                    final String userId = UserService.currentUserId.toString();
                    setState(() {
                      if (_isLiked) {
                        widget.flick.likes.removeWhere((like) => like.userId == userId);
                      } else {
                        widget.flick.likes.add(Like(
                          userId: userId,
                          likedAt: DateTime.now(),
                        ));
                      }
                      _isLiked = !_isLiked;
                    });
                    // Here you would typically update the like in your backend
                    print('Like toggled for Flick ${widget.flick.id}. New likes count: ${widget.flick.likes.length}');
                  },
                  child: Column( // This Column aligns the icon and text vertically
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _isLiked ? 'assets/icons/saluted.png' : 'assets/icons/salute.png',
                        width: 30,
                        height: 30,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image assets are missing
                          return Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.white,
                            size: 24,
                          );
                        },
                      ),
                      // Conditionally show text based on count
                      if (widget.flick.likes.isNotEmpty) ...[
                        const SizedBox(height: 6), // Vertical spacing between icon and text
                        Text(
                          widget.flick.likes.length.toString(),
                          style: const TextStyle(
                            color: Color(0xFFBDBCBA),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Space between button sections

                // Comments Button
                GestureDetector(
                  onTap: () {
                    //TODO: Implement add comment functionality
                  },
                  child: Column( // This Column aligns the icon and text vertically
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/message.svg', // Replace with your icon's path
                        height: 28,
                        width: 28,
                        colorFilter: const ColorFilter.mode(Color(0xFFBDBCBA), BlendMode.srcIn), // You can easily change colors
                      ),
                      // Conditionally show text based on count
                      if (widget.flick.comments.isNotEmpty) ...[
                        const SizedBox(height: 6), // Vertical spacing between icon and text
                        Text(
                          widget.flick.comments.length.toString(),
                          style: TextStyle(
                              color: Color(0xFFBDBCBA), // Assuming `isDark` is defined in the parent scope
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Space between button sections

                // Share Button
                GestureDetector(
                  onTap: (){
                    //TODO: Show share functionality and modal
                  },
                  child: SvgPicture.asset(
                    'assets/icons/share.svg', // Replace with your icon's path
                    height: 28,
                    width: 28,
                    colorFilter: const ColorFilter.mode(Color(0xFFBDBCBA), BlendMode.srcIn), // You can easily change colors
                  ),
                ),
                const SizedBox(height: 24), // Space between button sections

                // Bookmark Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                      // TODO: Add backend integration for bookmark
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  child: SvgPicture.asset(
                    _isBookmarked ? 'assets/icons/bookmark.svg' : 'assets/icons/bookmark_outlined.svg',
                    height: 28,
                    width: 28,
                    colorFilter: const ColorFilter.mode(Color(0xFFBDBCBA), BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 24), // Space between button sections

                // Mute Button
                GestureDetector(
                  onTap: _toggleMute,  // Fixed: Now properly calls the method
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Color(0xFFBDBCBA), size: 30,)
                  ),
                ),
                const SizedBox(height: 48), // Bottom padding
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
