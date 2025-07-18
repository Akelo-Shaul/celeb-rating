class CelebRank {
  final int rank;
  final String name;
  final double score;
  final String? imageUrl;
  CelebRank({
    required this.rank,
    required this.name,
    required this.score,
    this.imageUrl,
  });
}