import 'package:celebrating/models/user.dart';

import 'comment.dart';
import 'like.dart';

class Flick{
  final String id;
  final String thumbnail;
  final String flickUrl;
  final String title;
  final User creator;
  final DateTime timestamp;
  final int views;
  final Duration duration;
  final List<Like> likes; // List of users who liked the post
  final List<Comment> comments;
  final List<String> categories;
  final List<String> hashtags;
  final String location;
  final Map<String, int> userRatings; // userId -> rating

  Flick({
    required this.likes,
    required this.comments,
    required this.categories,
    required this.timestamp,
    required this.hashtags,
    required this.id,
    required this.thumbnail,
    required this.flickUrl,
    required this.title,
    required this.creator,
    required this.views,
    required this.duration,
    required this.location,
    this.userRatings = const {},
  });

}