import 'post.dart';

class User {
  final int? id;
  final String username;
  final String password;
  final String email;
  final String role;
  final String fullName;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final bool? isActive;
  final List<Post>? postsList;

  User({
    this.id,
    this.profileImageUrl,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    required this.fullName,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.isActive,
    this.postsList,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'] ?? '',
        email: json['email'],
        role: json['role'],
        fullName: json['fullName'],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
        isActive: json['isActive'],
        profileImageUrl: json['profileImageUrl'] as String?,
        postsList: json['postsList'] != null ? (json['postsList'] as List).map((e) => Post.fromJson(e)).toList() : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'email': email,
        'role': role,
        'fullName': fullName,
        // Do NOT send id, createdAt, updatedAt, lastLogin, isActive to server
      };
}

class CelebrityUser extends User {
  final String occupation;
  final String nationality;
  final String bio;
  final String website;
  final int followers;
  final int posts;
  final String netWorth;
  final Map<String, List<Map<String, String>>> careerEntries;
  final Map<String, List<Map<String, String>>> wealthEntries;
  final String zodiacSign;
  final List<Map<String, dynamic>> familyMembers;
  final List<String> relationships;
  final List<Map<String, String>> educationEntries;
  final List<Map<String, dynamic>> hobbies;
  final String diet;
  final String spirituality;
  final List<Map<String, String>> involvedCauses;
  final List<String> pets;
  final List<String> tattoos;
  final List<Map<String, dynamic>> favouritePlaces;
  final List<Map<String, dynamic>> talents;
  final List<Map<String, dynamic>> socials;
  final String publicImageDescription;
  final List<Map<String, dynamic>> controversyMedia;
  final Map<String, List<Map<String, dynamic>>> fashionStyle;

  CelebrityUser({
    required int id,
    required String username,
    required String password,
    required String email,
    required String role,
    required String fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
    required this.occupation,
    required this.nationality,
    required this.bio,
    required this.website,
    required this.followers,
    required this.posts,
    required List<Post> postsList,
    required this.netWorth,
    required this.careerEntries,
    required this.wealthEntries,
    required this.zodiacSign,
    required this.familyMembers,
    required this.relationships,
    required this.educationEntries,
    required this.hobbies,
    required this.diet,
    required this.spirituality,
    required this.involvedCauses,
    required this.pets,
    required this.tattoos,
    required this.favouritePlaces,
    required this.talents,
    required this.socials,
    required this.publicImageDescription,
    required this.controversyMedia,
    required this.fashionStyle,
  }) : super(
          id: id,
          username: username,
          password: password,
          email: email,
          role: role,
          fullName: fullName,
          profileImageUrl: profileImageUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastLogin: lastLogin,
          isActive: isActive,
          postsList: postsList,
        );
}