import 'package:celebrating/models/comment.dart';
import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/user.dart';
import '../services/comment_service.dart';

class CommentsModal extends StatefulWidget {
  final List<Comment> comments;
  final String postId; // To know which post these comments belong to

  const CommentsModal({
    super.key,
    required this.comments,
    required this.postId,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _hasText = false; // To control the 'Reply' button color and enabled state
  Comment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_updateHasText);
    // Removed _commentFocusNode.addListener(_handleFocusChange); as _isCommenting is unused for UI toggle.
  }

  void _updateHasText() {
    setState(() {
      _hasText = _commentController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateHasText);
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _postComment() async {
    if (!_hasText) {
      return;
    }
    print('Posting comment to post ${widget.postId}: ${_commentController.text}');

    final User currentUser = User(
      id: 999,
      username: 'CurrentUser',
      fullName: 'You',
      profileImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      password: 'dummy_password',
      email: 'current@example.com',
      role: 'User',
      createdAt: DateTime.now(),
    );

    final newComment = await CommentService.postComment(
      postId: widget.postId,
      content: _commentController.text,
      user: currentUser,
      replyingTo: _replyingTo,
    );

    setState(() {
      if (_replyingTo != null) {
        _replyingTo!.replies.add(newComment);
        _replyingTo = null;
      } else {
        widget.comments.add(newComment);
      }
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBackgroundColor = isDark ? Colors.grey.shade900 : Colors.white;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: secondaryTextColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Title
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: defaultTextColor,
              ),
            ),
            const Divider(height: 24),

            // Comments List
            Expanded(
              child: widget.comments.isEmpty
                  ? Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(color: secondaryTextColor),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.comments.length,
                itemBuilder: (context, index) {
                  return CommentTile(
                    comment: widget.comments[index],
                    onReply: () {
                      setState(() {
                        _replyingTo = widget.comments[index];
                      });
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        _commentController.text = '@${widget.comments[index].user.username} ';
                        _commentFocusNode.requestFocus();
                        _commentController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _commentController.text.length),
                        );
                      });
                    },
                  );
                },
              ),
            ),
            if (_replyingTo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Text('Replying to @${_replyingTo!.user.username}', style: TextStyle(color: appPrimaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingTo = null;
                          _commentController.clear();
                        });
                      },
                      child: Icon(Icons.close, size: 18, color: secondaryTextColor),
                    )
                  ],
                ),
              ),
            // --- Comment Input Section ---
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ProfileAvatar(
                    radius: 20,
                    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  focusNode: _commentFocusNode,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                                    hintText: 'Add a reply...',
                                    hintStyle: TextStyle(color: secondaryTextColor),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                        color: secondaryTextColor.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                        color: secondaryTextColor.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                        color: appPrimaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(color: defaultTextColor),
                                ),
                              ),
                              // if (!_commentFocusNode.hasFocus && !_hasText)
                              //   Icon(Icons.alternate_email, color: secondaryTextColor, size: 24),
                            ],
                          ),
                          if (_commentFocusNode.hasFocus || _hasText)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0, bottom: 2.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print('Image icon tapped');
                                      // Add logic for image attachment
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Icon(Icons.image_outlined, color: secondaryTextColor, size: 24),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print('@ icon tapped');
                                      // Add logic for mentioning/tagging
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Icon(Icons.alternate_email, color: secondaryTextColor, size: 24),
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: _hasText ? _postComment : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _hasText ? appPrimaryColor : secondaryTextColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      minimumSize: const Size(0, 36),
                                    ),
                                    child: Text(
                                      'Reply',
                                      style: TextStyle(
                                        color: _hasText ? Colors.white : Colors.grey[300],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;

  const CommentTile({super.key, required this.comment, this.onReply});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          radius: 15, // Consistent size for post author avatar
          imageUrl: comment.user.profileImageUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: comment.user.username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: defaultTextColor,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: ' • 1d', // Placeholder for time ago, you can add this to your Comment model
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Like button for comment
                    GestureDetector(
                      onTap: () {
                        // Handle like for this specific comment
                        print('Liked comment: ${comment.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: secondaryTextColor,
                              size: 20,
                            ),
                            if (comment.likes > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  comment.likes.toString(),
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment Content
                Text(
                  comment.content,
                  style: TextStyle(
                    color: defaultTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Reply Button
                if (onReply != null)
                  GestureDetector(
                    onTap: onReply,
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Render replies recursively
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 8.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: comment.replies
                          .map((reply) => CommentTile(comment: reply)) // Recursive call for replies
                          .toList(),
                    ),
                  ),
              ],
            )
        )
      ],
    );
  }
}

