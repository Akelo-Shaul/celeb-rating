import 'package:flutter/material.dart';
import 'package:celebrating/models/audio_post.dart';
import 'package:celebrating/widgets/profile_avatar.dart';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

import 'app_buttons.dart';

class AudioCard extends StatefulWidget {
  final AudioPost audioPost;
  const AudioCard({super.key, required this.audioPost});

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  double _playbackSpeed = 1.0;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  late bool _isContentExpanded;
  List<double> _waveHeights = List.generate(30, (i) => Random().nextDouble() * 20 + 10);
  late AudioPlayer _audioPlayer;
  late int _currentRating;
  late bool _isRatingSectionActive;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentRating = widget.audioPost.initialRating;
    _isContentExpanded = false;
    _isRatingSectionActive = false;
    _initAudio();
  }

  @override
  void didUpdateWidget(covariant AudioCard oldWidget) {
    if(oldWidget.audioPost.id != widget.audioPost.id) {
      _currentRating = widget.audioPost.initialRating;
      _isContentExpanded = false; // Reset expansion for new post
    }
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioPost.audio.url);
      _audioDuration = _audioPlayer.duration ?? Duration.zero;
      setState(() {});
      _audioPlayer.positionStream.listen((pos) {
        setState(() {
          _currentPosition = pos;
        });
      });
      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      // Handle error
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSpeed(_playbackSpeed);
      await _audioPlayer.play();
    }
  }

  void _changeSpeed() async {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    await _audioPlayer.setSpeed(_playbackSpeed);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          radius: 20,
          imageUrl: widget.audioPost.from.profileImageUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.audioPost.from.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.audioPost.from.username, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
        AppTextButton(
          text: 'Follow',
          onPressed: () {
            print('Follow button pressed!');
            // Add your follow logic here
          },
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    final maxLines = 3;
    final content = widget.audioPost.description;
    final textStyle = const TextStyle(fontSize: 14);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moreColor = Colors.grey[600];
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
          widget.audioPost.timestamp.toString(),
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
                    text: '       ... more',
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
                      text: '  show less',
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

  Widget _buildWaveformProgress() {
    final progress = _audioDuration.inSeconds == 0 ? 0 : _currentPosition.inSeconds / _audioDuration.inSeconds;
    final activeBars = (progress * _waveHeights.length).clamp(0, _waveHeights.length).toInt();
    return SizedBox(
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_waveHeights.length, (i) {
          Color barColor;
          if (i < activeBars) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.white24;
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 5,
            height: _waveHeights[i],
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(0.0),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                widget.audioPost.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              ),
              Positioned(bottom: 10, left: 10, child: _buildRatingSection(),)
            ],
          ),
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 32),
                  onPressed: _togglePlay,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWaveformProgress(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_currentPosition), style: const TextStyle(fontSize: 12)),
                          Text(_formatDuration(_audioDuration), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.speed, size: 22),
                      onPressed: _changeSpeed,
                    ),
                    Text('${_playbackSpeed}x', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // You can add the _buildRatingSection here if you want to reuse rating logic
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.thumb_up_alt_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.repeat_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    // If the user has already rated, show static stars and do not allow further rating
    final bool hasRated = widget.audioPost.initialRating > 0;
    final int rating = hasRated ? widget.audioPost.initialRating : _currentRating;
    return GestureDetector(
      onTapDown: (_) { // When the finger goes down
        setState(() {
          _isRatingSectionActive = true;
        });
      },
      onTapUp: (_) { // When the finger comes up
        setState(() {
          _isRatingSectionActive = false;
        });
      },
      onTapCancel: () { // If the tap is cancelled (e.g., finger slides off)
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
              final starColor = isRated ? Colors.orange : Colors.grey[400];
              if (hasRated) {
                // Show static stars if already rated
                return Icon(
                  Icons.star_rounded,
                  color: starColor,
                  size: 30,
                );
              } else {
                // Allow rating if not rated yet
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentRating = index + 1;
                      // You can add logic here to send the rating to your backend
                      print('User rated: $_currentRating stars for post ID: ${widget.audioPost.id}');
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildPostContent(),
          _buildMediaSection(),
          _buildBottomActions(),
        ],
      ),
    );
  }
}
