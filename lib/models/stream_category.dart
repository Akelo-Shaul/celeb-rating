class StreamCategory {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int streamCount;
  final int followerCount;
  final String coverUrl;
  final List<String> tags;

  StreamCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.streamCount,
    required this.followerCount,
    required this.coverUrl,
    required this.tags,
  });
}
