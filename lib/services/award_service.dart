class AwardWinner {
  final int rank;
  final String name;
  final String? imageUrl;
  final double score;
  AwardWinner({
    required this.rank,
    required this.name,
    this.imageUrl,
    required this.score,
  });
}

class AwardService {
  static List<AwardWinner> getDummyWinners() {
    return [
      AwardWinner(rank: 1, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 2, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 3, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 4, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 5, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 6, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 7, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 8, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 9, name: 'Brick Chuck', imageUrl: null, score: 4.3),
      AwardWinner(rank: 10, name: 'Brick Chuck', imageUrl: null, score: 4.3),
    ];
  }
}
