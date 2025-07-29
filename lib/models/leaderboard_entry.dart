class LeaderboardEntry {
  final String name;
  final String category;
  final String country;
  final String followers;
  final int score;
  final String trend; // 'up', 'down', 'neutral'
  final String image;

  LeaderboardEntry({
    required this.name,
    required this.category,
    required this.country,
    required this.followers,
    required this.score,
    required this.trend,
    required this.image,
  });
} 