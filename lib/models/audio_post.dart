import 'package:celebrating/models/user.dart';

class AudioMedia {
  final String url;
  final String type; // e.g. 'mp3', 'aac', etc.
  final Duration? duration;

  AudioMedia({required this.url, required this.type, this.duration});
}

class AudioPost {
  final String id;
  final String title;
  final String description;
  final AudioMedia audio;
  final String thumbnailUrl;
  final User from;
  final DateTime timestamp;
  final int initialRating;
  final List<String> categories;
  final List<String> hashtags;
  final List likes;
  final List comments;
  final String location;

  AudioPost({
    required this.id,
    required this.title,
    required this.description,
    required this.audio,
    required this.thumbnailUrl,
    required this.from,
    required this.timestamp,
    this.initialRating = 0,
    required this.categories,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.location,
  });
}
