import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_avatar.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChatItem> _allChats = [];
  List<ChatItem> _archivedChats = [];
  List<ChatItem> _requestsChats = [];
  List<ChatItem> _filteredChats = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Call async method without await since initState can't be async
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final allChats = await ChatService.getAllChats();
      final archivedChats = await ChatService.getArchivedChats();
      final requestsChats = await ChatService.getRequestChats();
      
      if (!mounted) return;
      
      setState(() {
        _allChats = allChats;
        _archivedChats = archivedChats;
        _requestsChats = requestsChats;
        _filteredChats = allChats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading chat data: $e');
    }
  }

  void _onSearchChanged(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      setState(() {
        _filteredChats = _allChats;
      });
    } else {
      final searchResults = await ChatService.searchChats(query);
      setState(() {
        _filteredChats = searchResults;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showChatOptions(BuildContext context, ChatItem chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatOptionsPopup(
        onPin: () {
          Navigator.pop(context);
          ChatService.pinChat(chat.id);
          print('Pin chat: ${chat.user.fullName}');
        },
        onMute: () {
          Navigator.pop(context);
          ChatService.muteChat(chat.id);
          print('Mute chat: ${chat.user.fullName}');
        },
        onBlock: () {
          Navigator.pop(context);
          ChatService.blockUser(chat.id);
          print('Block chat: ${chat.user.fullName}');
        },
        onArchive: () {
          Navigator.pop(context);
          _archiveChat(chat);
        },
      ),
    );
  }

  void _archiveChat(ChatItem chat) {
    setState(() {
      _allChats.removeWhere((item) => item.id == chat.id);
      _archivedChats.add(chat);
    });
    ChatService.archiveChat(chat.id);
  }

  void _unarchiveChat(ChatItem chat) {
    setState(() {
      _archivedChats.removeWhere((item) => item.id == chat.id);
      _allChats.add(chat);
    });
    ChatService.unarchiveChat(chat.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final tabBackgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: secondaryTextColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                                 child: TextField(
                   decoration: InputDecoration(
                     hintText: 'Search',
                     hintStyle: TextStyle(color: secondaryTextColor),
                     border: InputBorder.none,
                     contentPadding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   style: TextStyle(color: defaultTextColor),
                   onChanged: _onSearchChanged,
                 ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Builder(
                  builder: (context) {
                    print('Building All tab with ${_filteredChats.length} chats');
                    return _buildChatList(_filteredChats, isDark, defaultTextColor, secondaryTextColor);
                  },
                ),
                Builder(
                  builder: (context) {
                    print('Building Archived tab with ${_archivedChats.length} chats');
                    return _buildChatList(_archivedChats, isDark, defaultTextColor, secondaryTextColor);
                  },
                ),
                Builder(
                  builder: (context) {
                    print('Building Requests tab with ${_requestsChats.length} chats');
                    return _buildChatList(_requestsChats, isDark, defaultTextColor, secondaryTextColor);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: const Color(0xFFD6AF0C),
      unselectedLabelColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: const Color(0xFFD6AF0C),
        ),
        insets: EdgeInsets.zero,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Archived'),
        Tab(text: 'Requests'),
      ],
    );
  }

  Widget _buildChatList(List<ChatItem> chats, bool isDark, Color defaultTextColor, Color secondaryTextColor) {
    print('_buildChatList called with ${chats.length} chats, isLoading: $_isLoading');
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (chats.isEmpty) {
      print('Chats list is empty, showing "No chats to display"');
      return Center(
        child: Text(
          'No chats to display',
          style: TextStyle(color: secondaryTextColor),
        ),
      );
    }

    print('Building ListView with ${chats.length} chats');
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Dismissible(
          key: Key(chat.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            // Only allow swipe in All and Archived tabs
            if (_tabController.index == 0) {
              _archiveChat(chat);
              return true;
            } else if (_tabController.index == 1) {
              _unarchiveChat(chat);
              return true;
            }
            return false; // No swipe in Requests tab
          },
          background: Container(
            color: const Color(0xFFD6AF0C),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              _tabController.index == 0 ? Icons.archive : Icons.unarchive,
              color: Colors.white,
            ),
          ),
          child: GestureDetector(
            onLongPress: () {
              if (_tabController.index == 0) { // Only show options in All tab
                _showChatOptions(context, chat);
              }
            },
            onTap: () {
              print('Open chat with ${chat.user.fullName}');
              ChatService.markAsRead(chat.id);
              context.pushNamed('chatMessage', 
                pathParameters: {'chatId': chat.id},
                extra: chat.user,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Stack(
                    children: [
                                             ProfileAvatar(
                         radius: 25,
                         imageUrl: chat.user.profileImageUrl,
                       ),
                      if (ChatService.isUserOnline(chat.user.id.toString()))
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.grey.shade900 : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    chat.user.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: defaultTextColor,
                                    ),
                                  ),
                                  if (chat.isVerified) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.verified, color: Colors.orange.shade700, size: 16),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              chat.timestamp,
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.lastMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat.unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6AF0C),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatOptionsPopup extends StatelessWidget {
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onBlock;
  final VoidCallback onArchive;

  const ChatOptionsPopup({
    super.key,
    required this.onPin,
    required this.onMute,
    required this.onBlock,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
          _buildOption(Icons.push_pin, 'Pin', onPin),
          _buildOption(Icons.notifications_off, 'Mute', onMute),
          _buildOption(Icons.block, 'Block', onBlock),
          _buildOption(Icons.archive, 'Archive', onArchive),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
} 