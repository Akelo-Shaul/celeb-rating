import 'stream_category.dart';
import 'user.dart';

class LiveStream {
  final String id;
  final String title;
  final String description;
  final User streamer;
  final String streamUrl;
  final String thumbnailUrl;
  final int viewerCount;
  final bool isLive;
  final DateTime startedAt;
  final List<StreamCategory> categories;
  final List<String> tags;
  final String language;
  final String location;

  LiveStream({
    required this.id,
    required this.title,
    required this.description,
    required this.streamer,
    required this.streamUrl,
    required this.thumbnailUrl,
    required this.viewerCount,
    required this.isLive,
    required this.startedAt,
    required this.categories,
    required this.tags,
    required this.language,
    required this.location,
  });
}
