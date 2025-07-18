import 'package:flutter/material.dart';

import '../models/celeb_rank.dart';

class CelebRanksService {
  static List<CelebRank> getDummyRanks() {
    return [
      CelebRank(rank: 1, name: 'Taylor Swift', score: 4.5, imageUrl: 'https://randomuser.me/api/portraits/women/1.jpg'),
      CelebRank(rank: 2, name: 'Lionel Messi', score: 4.5, imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg'),
      CelebRank(rank: 3, name: 'Zendaya', score: 4.4, imageUrl: 'https://randomuser.me/api/portraits/women/3.jpg'),
      CelebRank(rank: 4, name: 'Beyoncé', score: 4.4, imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg'),
      CelebRank(rank: 5, name: 'Cristiano Ronaldo', score: 4.4, imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg'),
      CelebRank(rank: 6, name: 'Billie Eilish', score: 4.3, imageUrl: 'https://randomuser.me/api/portraits/women/6.jpg'),
      CelebRank(rank: 7, name: 'Dwayne Johnson', score: 4.3, imageUrl: 'https://randomuser.me/api/portraits/men/7.jpg'),
      CelebRank(rank: 8, name: 'Ariana Grande', score: 4.4, imageUrl: 'https://randomuser.me/api/portraits/women/8.jpg'),
      CelebRank(rank: 9, name: 'LeBron James', score: 4.2, imageUrl: 'https://randomuser.me/api/portraits/men/9.jpg'),
      CelebRank(rank: 10, name: 'Rihanna', score: 3.9, imageUrl: 'https://randomuser.me/api/portraits/women/10.jpg'),
    ];
  }
}
