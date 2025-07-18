import '../models/versus_user.dart';

class VersusService {
  static List<VersusUser> getDummyUsers() {
    return [
      VersusUser(id: '1', name: 'Bruam Halaberry', imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg'),
      VersusUser(id: '2', name: 'Chuck Hankey', imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg'),
      VersusUser(id: '3', name: 'Taylor Swift', imageUrl: 'https://randomuser.me/api/portraits/women/3.jpg'),
      VersusUser(id: '4', name: 'Zendaya', imageUrl: 'https://randomuser.me/api/portraits/women/4.jpg'),
      VersusUser(id: '5', name: 'Cristiano Ronaldo', imageUrl: 'https://randomuser.me/api/portraits/men/5.jpg'),
      VersusUser(id: '6', name: 'Billie Eilish', imageUrl: 'https://randomuser.me/api/portraits/women/6.jpg'),
      VersusUser(id: '7', name: 'Dwayne Johnson', imageUrl: 'https://randomuser.me/api/portraits/men/7.jpg'),
      VersusUser(id: '8', name: 'Ariana Grande', imageUrl: 'https://randomuser.me/api/portraits/women/8.jpg'),
    ];
  }
}
