import '../models/user.dart';
import 'search_service.dart';
import 'user_service.dart';

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isFromCurrentUser;
  final User user;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isFromCurrentUser,
    required this.user,
  });
}

class ChatItem {
  final String id;
  final User user;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isVerified;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;

  ChatItem({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.isVerified,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
  });
}

class ChatService {
  // Get current user from UserService
  static Future<User> getCurrentUser() async {
    return await UserService.fetchUser(UserService.currentUserId.toString(),
        isCelebrity: true);
  }

  // Track user online status
  static Map<String, DateTime> _lastSeenTimes = {};

  // Update user's last seen time
  static void updateUserLastSeen(String userId) {
    _lastSeenTimes[userId] = DateTime.now();
  }

  // Get user's online status
  static bool isUserOnline(String userId) {
    final lastSeen = _lastSeenTimes[userId];
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen) < const Duration(minutes: 5);
  }

  // Get user's last seen string
  static String getLastSeenString(String userId) {
    final lastSeen = _lastSeenTimes[userId];
    if (lastSeen == null) return 'Last seen recently';

    final difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) return 'Last seen just now';
    if (difference.inMinutes < 60) return 'Last seen ${difference.inMinutes}m ago';
    if (difference.inHours < 24) return 'Last seen ${difference.inHours}h ago';
    if (difference.inDays < 7) return 'Last seen ${difference.inDays}d ago';
    return 'Last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }

  // Get the last message for a chat
  static Future<String> getLastMessageForChat(String chatId) async {
    try {
      final messages = await getMessagesForChat(chatId);
      if (messages.isEmpty) return 'No messages';
      return messages.last.content;
    } catch (e) {
      return 'Unable to load messages';
    }
  }

  // Generate dummy chats with current user
  static Future<List<ChatItem>> getAllChats() async {
    print('Getting all chats...');
    final chats = [
      ChatItem(
        id: '1',
        user: SearchService.dummyUsers[0], // Bruam Halaberry
        lastMessage: 'Thank you so much! That means a lot to me',
        timestamp: getLastSeenString(SearchService.dummyUsers[0].id.toString()),
        unreadCount: 2,
        isOnline: isUserOnline(SearchService.dummyUsers[0].id.toString()),
        isVerified: true,
      ),
      ChatItem(
        id: '2',
        user: SearchService.dummyUsers[2], // Music Fan
        lastMessage: 'Can\'t wait! It\'s going to be amazing',
        timestamp: getLastSeenString(SearchService.dummyUsers[2].id.toString()),
        unreadCount: 1,
        isOnline: isUserOnline(SearchService.dummyUsers[2].id.toString()),
        isVerified: false,
      ),
      ChatItem(
        id: '3',
        user: SearchService.dummyUsers[3], // Jazz Cat
        lastMessage: 'I can imagine! The crowd was electric',
        timestamp: getLastSeenString(SearchService.dummyUsers[3].id.toString()),
        unreadCount: 1,
        isOnline: isUserOnline(SearchService.dummyUsers[3].id.toString()),
        isVerified: true,
      ),
      ChatItem(
        id: '4',
        user: SearchService.dummyUsers[4], // Rock Star
        lastMessage: 'That\'s awesome! I\'m excited to see you there',
        timestamp: getLastSeenString(SearchService.dummyUsers[4].id.toString()),
        unreadCount: 0,
        isOnline: isUserOnline(SearchService.dummyUsers[4].id.toString()),
        isVerified: true,
      ),
    ];
    print('Returning ${chats.length} all chats');
    return chats;
  }

  static Future<List<ChatItem>> getArchivedChats() async {
    print('Getting archived chats...');
    final chats = [
      ChatItem(
        id: '9',
        user: SearchService.dummyUsers[5], // Classic Man
        lastMessage: 'The venue was packed! Amazing energy',
        timestamp: '2 weeks ago',
        unreadCount: 0,
        isOnline: false,
        isVerified: true,
        isArchived: true,
      ),
      ChatItem(
        id: '10',
        user: SearchService.dummyUsers[6], // Hip Hop Head
        lastMessage: 'That collaboration was fire!',
        timestamp: '3 weeks ago',
        unreadCount: 0,
        isOnline: false,
        isVerified: true,
        isArchived: true,
      ),
    ];
    print('Returning ${chats.length} archived chats');
    return chats;
  }

  static Future<List<ChatItem>> getRequestChats() async {
    print('Getting request chats...');
    final chats = [
      ChatItem(
        id: '11',
        user: SearchService.dummyUsers[7], // Country Gal
        lastMessage: 'Sent you a chat request',
        timestamp: getLastSeenString(SearchService.dummyUsers[7].id.toString()),
        unreadCount: 1,
        isOnline: isUserOnline(SearchService.dummyUsers[7].id.toString()),
        isVerified: true,
      ),
      ChatItem(
        id: '12',
        user: SearchService.dummyUsers[8], // Reggae King
        lastMessage: 'Sent you a chat request',
        timestamp: getLastSeenString(SearchService.dummyUsers[8].id.toString()),
        unreadCount: 2,
        isOnline: isUserOnline(SearchService.dummyUsers[8].id.toString()),
        isVerified: true,
      ),
    ];
    print('Returning ${chats.length} request chats');
    return chats;
  }

  // Search chats by user name
  static Future<List<ChatItem>> searchChats(String query) async {
    final allChats = await getAllChats();
    return allChats
        .where((chat) =>
    chat.user.fullName.toLowerCase().contains(query.toLowerCase()) ||
        chat.user.username.toLowerCase().contains(query.toLowerCase()) ||
        chat.lastMessage.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Pin a chat
  static void pinChat(String chatId) {
    // In a real app, this would update the database
    print('Pinned chat: $chatId');
  }

  // Mute a chat
  static void muteChat(String chatId) {
    // In a real app, this would update the database
    print('Muted chat: $chatId');
  }

  // Block a user
  static void blockUser(String chatId) {
    // In a real app, this would update the database
    print('Blocked user: $chatId');
  }

  // Archive a chat
  static void archiveChat(String chatId) {
    // In a real app, this would update the database
    print('Archived chat: $chatId');
  }

  // Unarchive a chat
  static void unarchiveChat(String chatId) {
    // In a real app, this would update the database
    print('Unarchived chat: $chatId');
  }

  // Mark chat as read
  static void markAsRead(String chatId) {
    // In a real app, this would update the database
    // For now, we'll simulate marking as read by updating the chat item
    print('Marked as read: $chatId');
    // This would typically update the database to mark all messages as read
    // and reset the unread count to 0
  }

  // Get chat by ID
  static Future<ChatItem?> getChatById(String chatId) async {
    final allChats = await getAllChats();
    final archivedChats = await getArchivedChats(); // Await this as it's an async call
    final requestChats = await getRequestChats();

    try {
      return allChats.firstWhere(
            (chat) => chat.id == chatId,
      );
    } catch (e) {
      try {
        return archivedChats.firstWhere(
              (chat) => chat.id == chatId,
        );
      } catch (e) {
        try {
          return requestChats.firstWhere(
                (chat) => chat.id == chatId,
          );
        } catch (e) {
          throw Exception('Chat not found');
        }
      }
    }
  }

  // Get messages for a specific chat
  static Future<List<ChatMessage>> getMessagesForChat(String chatId) async {
    // In a real app, this would fetch from database
    // For now, return dummy messages based on chat ID
    final chat = await getChatById(chatId); // Await the call
    if (chat == null) return [];

    final currentUser = await getCurrentUser();

    // Different messages for each chat
    switch (chatId) {
      case '1': // Music Fan
        return [
          ChatMessage(
            id: '1_1',
            content: 'Hello! How are you doing today?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '1_2',
            content: 'I\'m doing great, thanks for asking! How about you?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
          ChatMessage(
            id: '1_3',
            content: 'Pretty good! I loved your latest performance',
            timestamp: DateTime.now().subtract(const Duration(hours: 23)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '1_4',
            content: 'Thank you so much! That means a lot to me',
            timestamp: DateTime.now().subtract(const Duration(hours: 22)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];

      case '2': // Jazz Cat
        return [
          ChatMessage(
            id: '2_1',
            content: 'Hey! I got tickets to your next show',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '2_2',
            content: 'That\'s awesome! I\'m excited to see you there',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
          ChatMessage(
            id: '2_3',
            content: 'Can\'t wait! It\'s going to be amazing',
            timestamp: DateTime.now().subtract(const Duration(hours: 23)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
        ];

      case '3': // Rock Star
        return [
          ChatMessage(
            id: '3_1',
            content: 'How does it feel to be back on stage?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '3_2',
            content: 'It feels incredible! I missed the energy so much',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
          ChatMessage(
            id: '3_3',
            content: 'I can imagine! The crowd was electric',
            timestamp: DateTime.now().subtract(const Duration(hours: 23)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
        ];

      case '4': // Pop Queen
        return [
          ChatMessage(
            id: '4_1',
            content: 'Thanks for the collaboration! It was amazing',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '4_2',
            content: 'You\'re welcome! I had a great time working with you',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
          ChatMessage(
            id: '4_3',
            content: 'We should do it again sometime!',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '4_4',
            content: 'Absolutely! I\'d love that',
            timestamp: DateTime.now().subtract(const Duration(hours: 22)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];

      case '5': // Classic Man
        return [
          ChatMessage(
            id: '5_1',
            content: 'Great performance last night!',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '5_2',
            content: 'Thank you! I really appreciate that',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];

      case '6': // Hip Hop Head
        return [
          ChatMessage(
            id: '6_1',
            content: 'When is your next album dropping?',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '6_2',
            content: 'Working on it! Should be ready soon',
            timestamp: DateTime.now().subtract(const Duration(days: 6)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];

      case '7': // Country Gal
        return [
          ChatMessage(
            id: '7_1',
            content: 'Love your new song!',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '7_2',
            content: 'Thank you! I\'m glad you like it',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];

      case '8': // Reggae King
        return [
          ChatMessage(
            id: '8_1',
            content: 'Let\'s work on something together',
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: '8_2',
            content: 'That sounds great! I\'d love to collaborate',
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
          ChatMessage(
            id: '8_3',
            content: 'Perfect! Let\'s set something up',
            timestamp: DateTime.now().subtract(const Duration(days: 13)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
        ];

      default:
        return [
          ChatMessage(
            id: 'default_1',
            content: 'Hello! How are you?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isFromCurrentUser: false,
            user: chat.user,
          ),
          ChatMessage(
            id: 'default_2',
            content: 'I\'m doing well, thanks!',
            timestamp: DateTime.now().subtract(const Duration(hours: 23)),
            isFromCurrentUser: true,
            user: currentUser,
          ),
        ];
    }
  }

  // Send a message
  static void sendMessage(String chatId, String content) {
    // Update last seen time for current user
    updateUserLastSeen(UserService.currentUserId.toString());

    // In a real app, this would save to database
    print('Sending message to chat $chatId: $content');
  }

  // Mark chat as read
  static void markChatAsRead(String chatId) {
    // In a real app, this would update the database
    print('Marked chat as read: $chatId');
  }
}