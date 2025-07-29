import '../models/hall_of_famer.dart';

class HallOfFameService {
  // Dummy data for demonstration
  static final List<HallOfFamer> _dummyHallOfFamers = [
    HallOfFamer(1, 'serenawilliams', 'USA', '23 Grand Slam singles titles', 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQLX0NcLkX6ADRGuCdfQyBdBCCm4ELeycMoHXeCWyak9O4lnneoP7BVYuOLNQ0CepgWzJBQTAcjI2imezZIJzKRpg', 'Sports'),
    HallOfFamer(2, 'eliudkipchoge', 'Kenya', 'Marathon World Record Holder', 'https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcQ4MEZucViQZ6OFSth0WdlyLYSPcmiJ41INdRu06FJuUpEVqlL0RlSl3ATM1WpDntyyxi2wDART5z7XgsgWQlWZFdRqwLOWtynxZJd33JdO5zqsecre69PCNs1-omiGtnlqTb-ZrkWYBG0', 'Sports'),
    HallOfFamer(3, 'usainbolt', 'Jamaica', 'Fastest 100m sprinter', 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Usain_Bolt_after_4_%C3%97_100_m_Rio_2016.jpg/500px-Usain_Bolt_after_4_%C3%97_100_m_Rio_2016.jpg', 'Sports'),
    HallOfFamer(4, 'simonebiles', 'USA', 'Most decorated gymnast', 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTU2dRHW-nt780mdwitzGH0IQjyn3dyiF03NzRF1uWN-6CBQj1CLxSc_MelMmtNhsLpftip5gL3B0OEeEMR7AKdHny367uJCgDOZD1uKhqQGEcucuMzA83GxTYjyR9igR6BnxsWymOOgMgw', 'Sports'),
    HallOfFamer(5, 'cristianoronaldo', 'Portugal', 'All-time top scorer in UEFA Champions League', 'https://upload.wikimedia.org/wikipedia/commons/8/8c/Cristiano_Ronaldo_2018.jpg', 'Sports'),
    HallOfFamer(6, 'taylorswift', 'USA', 'Most awarded female artist in history', 'https://upload.wikimedia.org/wikipedia/commons/f/fb/Taylor_Swift_2_-_2019_by_Glenn_Francis_%28cropped%29.jpg', 'Music'),
    HallOfFamer(7, 'beyonce', 'USA', 'Most Grammy Awards won by a female artist', 'https://upload.wikimedia.org/wikipedia/commons/1/17/Beyonc%C3%A9_at_The_Lion_King_European_Premiere_2019.png', 'Music'),
    HallOfFamer(8, 'bobmarley', 'Jamaica', 'Reggae music legend and cultural icon', 'https://upload.wikimedia.org/wikipedia/commons/3/3c/Bob-Marley-in-Concert_1980.jpg', 'Music'),
    HallOfFamer(9, 'madonna', 'USA', 'Queen of Pop with most chart-topping hits', 'https://upload.wikimedia.org/wikipedia/commons/d/df/Madonna_Rebel_Heart_Tour_2015_-_Stockholm_%2823051478443%29_%28cropped%29.jpg', 'Music'),
    HallOfFamer(10, 'michaeljackson', 'USA', 'King of Pop and most influential entertainer', 'https://upload.wikimedia.org/wikipedia/commons/3/31/Michael_Jackson_in_1988.jpg', 'Music'),
    HallOfFamer(11, 'leonardodavinci', 'Italy', 'Renaissance polymath and artistic genius', 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Leonardo_da_Vinci_-_Mona_Lisa.jpg', 'Art'),
    HallOfFamer(12, 'pablopicasso', 'Spain', 'Cubism pioneer and modern art master', 'https://upload.wikimedia.org/wikipedia/commons/9/98/Pablo_picasso_1.jpg', 'Art'),
    HallOfFamer(13, 'vincentvangogh', 'Netherlands', 'Post-impressionist master painter', 'https://upload.wikimedia.org/wikipedia/commons/4/4c/Vincent_van_Gogh_-_Self-Portrait_-_Google_Art_Project_%28454045%29.jpg', 'Art'),
    HallOfFamer(14, 'einstein', 'Germany', 'Theory of Relativity and Nobel Prize winner', 'https://upload.wikimedia.org/wikipedia/commons/3/3e/Einstein_1921_by_F_Schmutzer_-_restoration.jpg', 'Science'),
    HallOfFamer(15, 'mariecurie', 'Poland', 'First woman to win Nobel Prize', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Marie_Curie_c._1920s.jpg', 'Science'),
    HallOfFamer(16, 'stevejobs', 'USA', 'Apple co-founder and tech visionary', 'https://upload.wikimedia.org/wikipedia/commons/f/f5/Steve_Jobs_Headshot_2010-CROP2.jpg', 'Technology'),
    HallOfFamer(17, 'billgates', 'USA', 'Microsoft co-founder and philanthropist', 'https://upload.wikimedia.org/wikipedia/commons/a/a8/Bill_Gates_2017_%28cropped%29.jpg', 'Technology'),
    HallOfFamer(18, 'nelsonmandela', 'South Africa', 'Anti-apartheid revolutionary and president', 'https://upload.wikimedia.org/wikipedia/commons/0/02/Nelson_Mandela_1994.jpg', 'Politics'),
    HallOfFamer(19, 'martinlutherking', 'USA', 'Civil rights leader and Nobel Peace Prize winner', 'https://upload.wikimedia.org/wikipedia/commons/0/05/Martin_Luther_King%2C_Jr..jpg', 'Politics'),
    HallOfFamer(20, 'gandhi', 'India', 'Father of the Nation and peace activist', 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Portrait_Gandhi.jpg', 'Politics'),
  ];

  Future<List<HallOfFamer>> fetchHallOfFamers({
    String? location,
    String? timePeriod,
    String? category,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter the data based on location and time period
    List<HallOfFamer> filteredData = List.from(_dummyHallOfFamers);
    
    // Apply location filter
    if (location != null && location != 'All Locations') {
      filteredData = filteredData.where((famer) {
        // For demonstration, we'll filter based on the nationality field
        // In a real app, you'd have more sophisticated location matching
        return famer.nationality.toLowerCase().contains(location.toLowerCase()) ||
               location.toLowerCase().contains(famer.nationality.toLowerCase());
      }).toList();
    }
    
    // Apply category filter
    if (category != null && category != 'All Categories') {
      filteredData = filteredData.where((famer) {
        return famer.category.toLowerCase() == category.toLowerCase();
      }).toList();
    }
    
    // Apply time period filter (in a real app, you'd filter by actual dates)
    if (timePeriod != null && timePeriod != 'All Time') {
      // For demonstration, we'll simulate different time periods
      // In a real app, you'd filter by actual achievement dates
      switch (timePeriod) {
        case 'Today':
          // Show only recent achievements (simulated)
          filteredData = filteredData.take(2).toList();
          break;
        case 'Yesterday':
          filteredData = filteredData.take(1).toList();
          break;
        case 'This Week':
          filteredData = filteredData.take(3).toList();
          break;
        case 'This Month':
          filteredData = filteredData.take(4).toList();
          break;
        case 'This Year':
          filteredData = filteredData.take(5).toList();
          break;
        case 'Last Week':
          filteredData = filteredData.take(2).toList();
          break;
        case 'Last Month':
          filteredData = filteredData.take(3).toList();
          break;
        case 'Last Year':
          filteredData = filteredData.take(4).toList();
          break;
        case 'Past 7 Days':
          filteredData = filteredData.take(2).toList();
          break;
        case 'Past 30 Days':
          filteredData = filteredData.take(3).toList();
          break;
        case 'Past 3 Months':
          filteredData = filteredData.take(4).toList();
          break;
        case 'Past 6 Months':
          filteredData = filteredData.take(5).toList();
          break;
        case 'Past Year':
          filteredData = filteredData.take(6).toList();
          break;
        default:
          // Keep all data for other time periods
          break;
      }
    }
    
    return filteredData;
  }
}
