import 'dart:ui';

import 'package:celebrating/models/post.dart';
import 'package:celebrating/widgets/app_buttons.dart';
import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../l10n/app_localizations.dart';

import '../models/comment.dart';
import 'comments_modal.dart';
import 'video_player_widget.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final ValueNotifier<bool>? feedMuteNotifier; // Add this for feed mute state
  final bool showFollowButton;
  const PostCard({super.key, required this.post, this.feedMuteNotifier, this.showFollowButton = true});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _currentRating;
  late int _currentPage;
  late PageController _pageController;
  late bool _isContentExpanded;  //For text expansion in view more
  late bool _isRatingSectionActive;
  ValueNotifier<bool>? _muteNotifier;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.post.initialRating;
    _currentPage = 0;
    _pageController = PageController();
    _isContentExpanded = false;
    _isRatingSectionActive = false;
    _muteNotifier = widget.feedMuteNotifier;
    _muteNotifier?.addListener(_onMuteChanged);
  }

  void _onMuteChanged() {
    setState(() {}); // Rebuild to update mute state in video widgets
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
            postId: widget.post.id,
          ),
        );
      },
    );
  }


  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.post.id != widget.post.id){
      _currentRating = widget.post.initialRating;
      _currentPage = 0;
      _pageController = PageController(); // Re-initialize page controller for new post
      _isContentExpanded = false; // Reset expansion for new post
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _muteNotifier?.removeListener(_onMuteChanged);
    // Only pause (do not dispose) the current video when this post card is disposed
    PostCardVideoPlaybackManager().pauseCurrent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildPostContent(),
          _buildMediaSection(), // Add media section with safe video player usage
          _buildBottomActions()
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          radius: 20, // Consistent size for post author avatar
          imageUrl: widget.post.from.profileImageUrl,
        ),
        const SizedBox(width: 12,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.from.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),),
                  const SizedBox(width: 4,),
                  const Icon(Icons.verified, color: Color(0xFFD6AF0C), size: 16,)
                ],
              ),
              Text(
                widget.post.from.username,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14),)
            ],
          )
        ),
        if (widget.showFollowButton)
          AppTextButton(
            text: AppLocalizations.of(context)!.follow,
            onPressed: () {
              print('${AppLocalizations.of(context)!.follow} button pressed!');
              // Add your follow logic here
            },
          ),
      ],
    );
  }

  Widget _buildPostContent() {
    final maxLines = 3;
    final content = widget.post.content;
    final textStyle = const TextStyle(fontSize: 14);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moreColor = Colors.grey[600];
    final localizations = AppLocalizations.of(context)!;
    final span = TextSpan(text: content, style: textStyle);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 70);

    final bool isOverflow = tp.didExceedMaxLines;
    String visibleText = content;
    if (!_isContentExpanded && isOverflow) {
      int endIndex = tp.getPositionForOffset(Offset(tp.width, tp.height)).offset;
      if (endIndex < content.length) {
        int lastSpace = content.lastIndexOf(' ', endIndex);
        if (lastSpace > 0) endIndex = lastSpace;
      }
      visibleText = content.substring(0, endIndex).trim();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.timeAgo,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        if (!_isContentExpanded && isOverflow)
          GestureDetector(
            onTap: () {
              setState(() {
                _isContentExpanded = true;
              });
            },
            child: RichText(
              text: TextSpan(
                style: textStyle.copyWith(color: isDark ? Colors.white : Colors.black),
                children: [
                  TextSpan(text: visibleText),
                  TextSpan(
                    text: '       ${localizations.more}',
                    style: textStyle.copyWith(
                      color: moreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          GestureDetector(
            onTap: () {
              if (isOverflow) {
                setState(() {
                  _isContentExpanded = false;
                });
              }
            },
            child: RichText(
              text: TextSpan(
                style: textStyle.copyWith(color: isDark ? Colors.white : Colors.black),
                children: [
                  TextSpan(text: content),
                  if (isOverflow)
                    TextSpan(
                      text: '  ${localizations.showLess}',
                      style: textStyle.copyWith(
                        color: moreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaSection() {
    if (widget.post.media.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(0.0),
      child: AspectRatio(
        aspectRatio: 16/12,
        child: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                itemCount: widget.post.media.length, // Prevent scrolling past media count
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, i){
                  final mediaItem = widget.post.media[i];
                  if(mediaItem.type == 'image'){
                    return Image.network(
                      mediaItem.url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress){
                        if(loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  } else if (mediaItem.type == 'video'){
                    return AppVideoPlayerWidget(
                      videoUrl: mediaItem.url,
                      autoplay: true,
                      looping: true,
                      playbackMode: VideoPlaybackMode.globalSingle,
                      customManager: PostCardVideoPlaybackManager(),
                      showMuteButton: true,
                      muted: _muteNotifier?.value ?? true,
                      onMuteToggle: () {
                        if (_muteNotifier != null) {
                          _muteNotifier!.value = !_muteNotifier!.value;
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }
            ),
            if(widget.post.media.isNotEmpty && widget.post.media.length > 1)
              Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      '${_currentPage + 1}/${widget.post.media.length}',
                      style: TextStyle(color: Colors.white, fontSize: 13,fontWeight: FontWeight.bold),),)),
            Positioned(bottom: 10, left: 10, child: _buildRatingSection(),)

          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    // If the user has already rated, show static stars and do not allow further rating
    final bool hasRated = widget.post.initialRating > 0;
    final int rating = hasRated ? widget.post.initialRating : _currentRating;
    final localizations = AppLocalizations.of(context)!;
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
              borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isRated = rating >= (index + 1);
              final starColor = isRated ? Color(0xFFD6AF0C) : Colors.grey[400];
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
                      print('${localizations.youRated} ${index + 1} ${localizations.stars}!');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.youRatedStars(index + 1))),
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

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            PostActionButton(
              icon: Icons.thumb_up_alt_outlined, // Outlined icon for non-selected state
              text: '${widget.post.likes.length}',
              onPressed: () {
                //TODO: Add liking functionality
                print('Like toggled for Post ${widget.post.id}. Current likes: ${widget.post.likes.length}');
              },
            ),
            // Comment Button
            PostActionButton(
              icon: Icons.comment_outlined,
              text: '${widget.post.comments.length}',
              onPressed: () {
                _showCommentsModal(context, widget.post.comments);
              },
            ),
          ],
        ),
        // Repost Button
        Row(
          children: [
            PostActionButton(
              icon: Icons.repeat_outlined,
              onPressed: () {
                print('Repost Post ${widget.post.id}');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post Reposted!')));
              },
            ),
            // Send Button
            PostActionButton(
              icon: Icons.send_outlined,
              onPressed: () {
                print('Send Post ${widget.post.id}');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post Sent!')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
