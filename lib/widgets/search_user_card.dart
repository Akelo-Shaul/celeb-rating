import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:celebrating/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/user.dart';
import 'app_buttons.dart';

class SearchUserCard extends StatefulWidget {
  final User user;
  const SearchUserCard({super.key, required this.user});

  @override
  State<SearchUserCard> createState() => _SearchUserCardState();
}

class _SearchUserCardState extends State<SearchUserCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color nameColor = isDark ? Colors.white : Colors.black;
    final Color usernameColor = isDark ? Colors.grey.shade300 : Colors.black54;
    final Color subtitleColor = isDark ? Colors.grey.shade200 : Colors.black87;
    final Color cardBg = isDark ? Colors.grey.shade900 : Colors.white;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final user = widget.user;
    final bool isCelebrity = user is CelebrityUser; // Use bool type
    String? occupation;
    String? nationality;
    int? followers;
    // publicImageDescription is not used, so can be removed if truly unused.
    // String? publicImageDescription;

    if (isCelebrity) {
      final celebrity = user as CelebrityUser;
      occupation = celebrity.occupation;
      nationality = celebrity.nationality;
      followers = celebrity.followers;
      // publicImageDescription = celebrity.publicImageDescription;
    }

    return GestureDetector(
      onTap: () {
        context.goNamed(
          'viewProfile',
          pathParameters: {'userId': user.id.toString()}, // Pass the user's ID
          extra: user, // Optionally pass the entire user object
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            color: cardBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ProfileAvatar(
                  imageUrl: user.profileImageUrl,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: nameColor,
                            ),
                          ),
                          if (isCelebrity) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: Colors.orange.shade700,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: usernameColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isCelebrity && occupation != null && occupation.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              occupation!, // Use ! as it's checked for null and not empty
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (isCelebrity && nationality != null && nationality.isNotEmpty)
                              Text(
                                nationality!, // Use ! as it's checked for null and not empty
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      if (isCelebrity && followers != null)
                        Text(
                          '${followers.toString()} followers',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                ResizableButton(
                  text: "Follow",
                  onPressed: () {},
                  width: MediaQuery.of(context).size.width * 0.28,
                  height: 35,
                ),
              ],
            ),
          ),
          // Divider
          Container(
            margin: const EdgeInsets.only(left: 48, right: 0),
            child: Divider(
              color: borderColor, // Use the borderColor variable
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}