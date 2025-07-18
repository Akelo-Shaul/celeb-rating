import '../models/hall_of_famer.dart';

class HallOfFameService {
  // Dummy data for demonstration
  static final List<HallOfFamer> _dummyHallOfFamers = [
    HallOfFamer(1, 'serenawilliams', 'USA', '23 Grand Slam singles titles', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQLX0NcLkX6ADRGuCdfQyBdBCCm4ELeycMoHXeCWyak9O4lnneoP7BVYuOLNQ0CepgWzJBQTAcjI2imezZIJzKRpg'),
    HallOfFamer(2, 'eliudkipchoge', 'Kenya', 'Marathon World Record Holder', 'https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcQ4MEZucViQZ6OFSth0WdlyLYSPcmiJ41INdRu06FJuUpEVqlL0RlSl3ATM1WpDntyyxi2wDART5z7XgsgWQlWZFdRqwLOWtynxZJd33JdO5zqsecre69PCNs1-omiGtnlqTb-ZrkWYBG0'),
    HallOfFamer(3, 'usainbolt', 'Jamaica', 'Fastest 100m sprinter', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Usain_Bolt_after_4_%C3%97_100_m_Rio_2016.jpg/500px-Usain_Bolt_after_4_%C3%97_100_m_Rio_2016.jpg'),
    HallOfFamer(4, 'simonebiles', 'USA', 'Most decorated gymnast', 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTU2dRHW-nt780mdwitzGH0IQjyn3dyiF03NzRF1uWN-6CBQj1CLxSc_MelMmtNhsLpftip5gL3B0OEeEMR7AKdHny367uJCgDOZD1uKhqQGEcucuMzA83GxTYjyR9igR6BnxsWymOOgMgw'),
    HallOfFamer(5, 'cristianoronaldo', 'Portugal', 'All-time top scorer in UEFA Champions League', 'https://upload.wikimedia.org/wikipedia/commons/8/8c/Cristiano_Ronaldo_2018.jpg'),
  ];

  Future<List<HallOfFamer>> fetchHallOfFamers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyHallOfFamers;
  }
}
