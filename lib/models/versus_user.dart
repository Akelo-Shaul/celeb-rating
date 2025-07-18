import 'package:celebrating/models/user.dart';

class VersusUser {
  final String id;
  final String name;
  final String imageUrl;

  const VersusUser({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Factory constructor to convert a User object to VersusUser
  factory VersusUser.fromUser(User user) {
    return VersusUser(
      id: user.id.toString(),
      name: user.fullName,
      imageUrl: user.profileImageUrl ?? '',
    );
  }
}