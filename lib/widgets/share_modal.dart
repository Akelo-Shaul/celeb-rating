import 'dart:io';

import 'package:celebrating/models/post.dart';
import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user.dart';
import '../services/chat_service.dart';

Future<void> showShareModal(BuildContext context, Post postToShare) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final defaultTextColor = isDark ? Colors.white : Colors.black;
  final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

  List<ChatItem> allChats = await ChatService.getAllChats();
  List<User> chatUsers = allChats.map((chatItem) => chatItem.user).toList();

  await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context){


        // Helper widget for share options
        Widget _buildShareOption({
          IconData? icon, // Make IconData nullable
          String? svgAssetPath, // Add an optional String for SVG asset path
          required String label,
          required VoidCallback onTap,
          required Color defaultTextColor,
        }) {
          // Ensure that at least one of icon or svgAssetPath is provided
          // Or handle the case where neither is provided (e.g., show a default icon)
          assert(icon != null || svgAssetPath != null, 'Either icon or svgAssetPath must be provided.');

          return GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[300],
                  child:
                  // Conditionally render Icon or SvgPicture.asset
                  icon != null
                      ? Icon(icon, color: Colors.grey)
                      : svgAssetPath != null
                      ? SvgPicture.asset(
                    svgAssetPath,
                    colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn), // Apply color to SVG
                    width: 28, // Adjust size as needed
                    height: 28, // Adjust size as needed
                  )
                      : const SizedBox.shrink(), // Fallback if neither is provided (though assert should prevent this)
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: defaultTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final mediaItem = postToShare.media[0];
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Text('Share', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),),
              const SizedBox(height: 10,),
              if (postToShare.media != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        mediaItem.url,
                        width: 130,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image, size: 60, color: secondaryTextColor),
                      ),
                    ),
                    Positioned(
                      left: 1,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/celebratinglogo.png',
                        width: 60,
                        // fit: BoxFit.fitHeight, // Ensures the whole image is visible
                      )
                    )
                  ],
                ),
              const SizedBox(height: 10,),
              Text('Share to chats...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
              const SizedBox(height: 10,),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chatUsers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == chatUsers.length ) {
                      // Last item: show more icon
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.more_horiz, color: defaultTextColor, size: 28),
                            ),
                            const SizedBox(height: 4),
                            Text('More', style: TextStyle(fontSize: 12, color: defaultTextColor)),
                          ],
                        ),
                      );
                    }
                    final user = chatUsers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          ProfileAvatar(
                            imageUrl: user.profileImageUrl,
                            radius: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(user.username, style: TextStyle(fontSize: 12, color: defaultTextColor)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  _buildShareOption(
                    icon: Icons.link,
                    label: 'Copy link',
                    onTap: () async {
                      Navigator.pop(context); // Close modal first
                      // await Share.share('${postToShare.content}\n${postToShare.content}\nCheck it out: [Your post link here]');
                    },
                    defaultTextColor: defaultTextColor,
                  ),
                  const SizedBox(width: 10,),
                  _buildShareOption(
                    icon: Icons.repeat,
                    label: 'Recelebrate',
                    onTap: () async {
                      Navigator.pop(context); // Close modal first
                      // await Share.share('${postToShare.content}\n${postToShare.content}\nCheck it out: [Your post link here]');
                    },
                    defaultTextColor: defaultTextColor,
                  ),
                  const SizedBox(width: 10,),
                  _buildShareOption(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () async {
                      Navigator.pop(context); // Close modal first
                      try {
                        final response = await http.get(Uri.parse(mediaItem.url));
                        if (response.statusCode != 200) {
                          throw Exception('Failed to download media: ${response.statusCode}');
                        }

                        // Use XFile.fromData as recommended by share_plus
                        final XFile mediaXFile = XFile.fromData(
                          response.bodyBytes,
                          mimeType: response.headers['content-type'] ?? 'application/octet-stream',
                        );

                        await SharePlus.instance.share(
                          ShareParams(
                            files: [mediaXFile],
                            text: postToShare.content,
                          ),
                        );
                      } catch (e) {
                        print('Error sharing media with title: $e');
                      }
                    },
                    defaultTextColor: defaultTextColor,
                  ),
                ],
              )
            ],
          ),
        );
      }
  );
}