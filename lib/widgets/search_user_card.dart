import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';

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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          color: cardBg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ProfileAvatar(
                imageUrl: widget.user.profileImageUrl,
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
                          widget.user.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: nameColor),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: Colors.orange.shade700, size: 18),
                      ],
                    ),
                    Text(
                      '@${widget.user.username}',
                      style: TextStyle(color: usernameColor, fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Musician, Public Speaker',
                      style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      '2,355 followers',
                      style: TextStyle(color: subtitleColor, fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              ResizableButton(
                text: "Follow",
                onPressed: () {},
                width: 100,
                height: 35,
              )
            ],
          ),
        ),
        // Divider
        Container(
          margin: const EdgeInsets.only(left: 48, right: 0),
          child: Divider(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}
