import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_service.dart';
import '../widgets/profile_avatar.dart';
import '../services/chat_service.dart';
import '../models/user.dart';

class ChatMessageScreen extends StatefulWidget {
  final String chatId;
  final User otherUser;

  const ChatMessageScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _hasText = false;
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
    _messageController.addListener(_onTextChanged);
  }

  Future<void> _loadCurrentUser() async {
    final user = await UserService.fetchUser(UserService.currentUserId.toString(),
        isCelebrity: true);
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _loadMessages() async {
    // Update user's online status
    ChatService.updateUserLastSeen(UserService.currentUserId.toString());

    // Load messages from ChatService
    final messages = await ChatService.getMessagesForChat(widget.chatId);
    if (mounted) {
      setState(() {
        _messages = messages;
      });
      // Mark all messages as read when chat is opened
      ChatService.markAsRead(widget.chatId);
    }
  }

  void _sendMessage() {
    if (_hasText && _currentUser != null) {
      final messageContent = _messageController.text.trim();

      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageContent,
        timestamp: DateTime.now(),
        isFromCurrentUser: true,
        user: _currentUser!,
      );

      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
        _hasText = false;
      });

      // Send message through ChatService
      ChatService.sendMessage(widget.chatId, messageContent);

      // Simulate typing indicator and response
      _simulateTyping();
    }
  }

  void _simulateTyping() {
    setState(() {
      _isTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });

        // Add a dummy response
        final response = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Thanks for the message!',
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
          user: widget.otherUser,
        );

        setState(() {
          _messages.add(response);
        });
      }
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMediaPicker(),
    );
  }

  Widget _buildMediaPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildMediaOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      print('Gallery selected');
                    },
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildMediaOption(
                    icon: Icons.videocam,
                    label: 'Video',
                    onTap: () {
                      Navigator.pop(context);
                      print('Video selected');
                    },
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildMediaOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      print('Camera selected');
                    },
                    textColor: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(icon, color: const Color(0xFFD6AF0C), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Yesterday';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: defaultTextColor),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            ProfileAvatar(
              radius: 20,
              imageUrl: widget.otherUser.profileImageUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.otherUser.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: defaultTextColor,
                          ),
                        ),
                      ),
                      if (widget.otherUser is CelebrityUser)
                        Icon(Icons.verified, color: Colors.orange.shade700, size: 16),
                    ],
                  ),
                  Row(
                    children: [
                      // Corrected logic for online status indicator
                      if (ChatService.isUserOnline(widget.otherUser.id.toString()))
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        ChatService.isUserOnline(widget.otherUser.id.toString())
                            ? 'Online'
                            : ChatService.getLastSeenString(widget.otherUser.id.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: defaultTextColor),
            onPressed: () => print('Video call'),
          ),
          IconButton(
            icon: Icon(Icons.call, color: defaultTextColor),
            onPressed: () => print('Voice call'),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: defaultTextColor),
            onPressed: () => print('More options'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputSection(isDark, defaultTextColor, secondaryTextColor, appPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: message.isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isFromCurrentUser) ...[
                ProfileAvatar(
                  radius: 16,
                  imageUrl: message.user.profileImageUrl,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isFromCurrentUser
                        ? const Color(0xFFD6AF0C)
                        : (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromCurrentUser ? Colors.white : defaultTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (message.isFromCurrentUser) ...[
                const SizedBox(width: 8),
                ProfileAvatar(
                  radius: 16,
                  imageUrl: message.user.profileImageUrl,
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: message.isFromCurrentUser ? 0 : 40,
              right: message.isFromCurrentUser ? 40 : 0,
              top: 4,
            ),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ProfileAvatar(
            radius: 16,
            imageUrl: widget.otherUser.profileImageUrl,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + (index * 200)),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: null,
      ),
    );
  }

  Widget _buildInputSection(bool isDark, Color defaultTextColor, Color secondaryTextColor, Color appPrimaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_currentUser != null) ...[
            ProfileAvatar(
              radius: 20,
              imageUrl: _currentUser!.profileImageUrl,
            ),
            const SizedBox(width: 10),
          ],
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
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                            hintText: 'Type a message...',
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
                    ],
                  ),
                  if (_messageFocusNode.hasFocus || _hasText)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0, bottom: 2.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showMediaPicker,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.image_outlined, color: secondaryTextColor, size: 24),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => print('Voice message'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(Icons.mic, color: secondaryTextColor, size: 24),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _hasText ? _sendMessage : null,
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
                              'Send',
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
    );
  }
}