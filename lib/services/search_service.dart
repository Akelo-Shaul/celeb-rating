import '../models/user.dart';

class SearchService {
  // Dummy user data for search
  static final List<User> dummyUsers = [
    User(
      id: 1,
      username: 'hamcurd',
      password: '',
      email: 'hamcurd@example.com',
      role: 'Celebrity',
      fullName: 'Bruam Halaberry',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 2,
      username: 'musicfan',
      password: '',
      email: 'musicfan@example.com',
      role: 'User',
      fullName: 'Music Fan',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 3,
      username: 'jazzcat',
      password: '',
      email: 'jazzcat@example.com',
      role: 'Celebrity',
      fullName: 'Jazz Cat',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 4,
      username: 'rockstar',
      password: '',
      email: 'rockstar@example.com',
      role: 'Celebrity',
      fullName: 'Rock Star',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 5,
      username: 'popqueen',
      password: '',
      email: 'popqueen@example.com',
      role: 'Celebrity',
      fullName: 'Pop Queen',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 6,
      username: 'classicman',
      password: '',
      email: 'classicman@example.com',
      role: 'User',
      fullName: 'Classic Man',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/6.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 7,
      username: 'hiphophead',
      password: '',
      email: 'hiphophead@example.com',
      role: 'User',
      fullName: 'Hip Hop Head',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 8,
      username: 'countrygal',
      password: '',
      email: 'countrygal@example.com',
      role: 'Celebrity',
      fullName: 'Country Gal',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
      createdAt: DateTime.now(),
    ),
    User(
      id: 9,
      username: 'reggaeking',
      password: '',
      email: 'reggaeking@example.com',
      role: 'Celebrity',
      fullName: 'Reggae King',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/9.jpg',
      createdAt: DateTime.now(),
    ),
  ];

  static Future<List<User>> searchUsers(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyUsers
        .where((user) => user.fullName.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
