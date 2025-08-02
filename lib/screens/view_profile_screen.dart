import 'package:celebrating/widgets/add_wealth_item_modal.dart';
import 'package:celebrating/widgets/slideup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../widgets/add_education_modal.dart';
import '../widgets/add_fun_niche_modal.dart';
import '../widgets/add_persona_modal.dart';
import '../widgets/add_relationship_modal.dart';
import '../widgets/app_buttons.dart';
import '../widgets/comments_modal.dart';
import '../widgets/item_popup_modal.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/image_optional_text.dart';
import '../utils/profile_action_popup.dart';
import '../widgets/profile_preview_modal_content.dart';
import '../widgets/share_modal.dart';

class ViewProfilePage extends StatefulWidget {
  final User user;
  const ViewProfilePage({super.key, required this.user});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  bool statsLoading = false;
  List<Post> posts = [];

  void _handleFollowUnfollow() {
    // Implement follow/unfollow logic here
    setState(() {
      // Toggle follow state for demo
    });
  }

  String formatCount(int count) {
    if (count >= 1000000) {
      return (count / 1000000).toStringAsFixed(1) + 'M';
    } else if (count >= 1000) {
      return (count / 1000).toStringAsFixed(1) + 'K';
    } else {
      return count.toString();
    }
  }

  void _loadUserData() {
    setState(() {
      posts = widget.user.postsList ?? [];
      isLoading = false;
    });
  }

  void _showProfilePreviewModal({
    required BuildContext context,
    required String userName,
    required String relationshipDesc,
    String? userProfileImageUrl,
    VoidCallback? onViewProfile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = Theme.of(context).primaryColor;

    showSlideUpDialog(
      context: context,
      height:460,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Theme.of(context).cardColor,
      child: ProfilePreviewModalContent(
        userName: userName,
        relationshipDesc: relationshipDesc,
        userProfileImageUrl: userProfileImageUrl,
        onViewProfile: onViewProfile,
        defaultTextColor: defaultTextColor,
        secondaryTextColor: secondaryTextColor,
        appPrimaryColor: appPrimaryColor,
      ),
    );
  }

  void _showItemPopupModal({
    required BuildContext context,
    required String sectionTitle,
    required String sectionType,
    required Map<String, dynamic> itemData,
  }) {
    showSlideUpDialog(
      context: context,
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Theme.of(context).cardColor,
      child: ItemPopupModal(
        itemData: itemData,
        sectionType: sectionType,
        sectionTitle: sectionTitle,
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    // Initialize with length 6, regardless of user type, to match profile_page.dart
    _tabController = TabController(length: 6, vsync: this);
    _loadUserData();
  }

  final Map<String, IconData> _careerCategoryIcons = {
    'Profession': Icons.work_outline,
    'Debut Work': Icons.rocket_launch_outlined,
    'Awards': Icons.emoji_events_outlined,
    'Songs': Icons.music_note_outlined,
    'Collaborations': Icons.group_add_outlined, // Added icon for collaborations
    // Add more as needed
  };

  // Align with actual keys in wealthEntries map: 'Cars', 'Houses', 'Art Collection', 'Watch Collection'
  final List<String> _wealthCategories = [
    'Cars',
    'Houses',
    'Art Collection',
    'Watch Collection',
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  void _showCommentsModal(BuildContext context, List<Comment> comments, {required String postId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.85, // Adjust this to control how much screen height the modal takes
          child: CommentsModal(
            comments: comments,
            postId: postId,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    // Removed unused appPrimaryColor here as it's not directly used in the Scaffold/AppBar
    // final tabBackgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200; // Not used

    return Scaffold(
      // appBar: _buildAppBar(defaultTextColor), // Re-enable if you want an AppBar
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 400.0, // Estimated height of header content
                floating: true,
                pinned: true,
                automaticallyImplyLeading: false,
                snap: true, // Optional: for snapping effect
                elevation: 0, // No shadow for a cleaner look
                backgroundColor: Theme.of(context).cardColor, // Background for the app bar itself
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin, // Ensures background content collapses correctly
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // These widgets already have their background set within their own functions
                      _buildProfileHeader(defaultTextColor, secondaryTextColor),
                      _buildActionButtons(),
                      const SizedBox(height: 5,),
                      _buildStatsRow(defaultTextColor, secondaryTextColor),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.0), // Standard TabBar height
                  child: _buildTabBar(isDark),
                ),
              ),
            ];
          },
          body: _buildTabs(),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color defaultTextColor, Color secondaryTextColor) {
    final user = widget.user;
    final isCelebrity = user is CelebrityUser;
    final celeb = isCelebrity ? user as CelebrityUser : null;
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30,),
                  Text(
                    'Profession', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  Text(
                    isCelebrity ? celeb!.occupation : '', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nationality', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  Text(
                    isCelebrity ? celeb!.nationality : '', // Use !
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Place of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.hometown : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Date Of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  Text(
                    user.dob != null
                        ? DateFormat('MMMM d, y').format(user.dob) // Format as "July 31, 2025"
                        : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Zodiac Sign', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  Text(
                    isCelebrity ? celeb!.zodiacSign : '', // Use !
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      ProfileAvatar(
                        radius: 60,
                        imageUrl: user.profileImageUrl, // Removed `user != null ?`
                      ),
                      if (isCelebrity) ...[
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Icon(Icons.verified, color:  Colors.orange.shade700, size: 30),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    user.fullName, // Removed `user != null ?` as user is always non-null here
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: defaultTextColor,
                    ),
                  ),
                  Text(
                    '@${user.username}', // Removed `user != null ?`
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6,),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: const Color(0xFFD6AF0C),
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Text(
            isCelebrity ? celeb!.bio : '', // Use !
            style: TextStyle(color: defaultTextColor),
          ),
          GestureDetector(
            onTap: () {
              if (isCelebrity && celeb != null) {
                print('Website link tapped: ${celeb.website}');
              }
            },
            child: Text(
              isCelebrity ? celeb!.website : '', // Use !
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ResizableButton(
                text: localizations.follow,
                onPressed: () {
                  if (!statsLoading) { // Removed `widget.user == null` as user is always non-null
                    _handleFollowUnfollow();
                  }
                },
                width: 100,
                height: 35,
              ),
              const SizedBox(width: 16,),
              GestureDetector(
                onTap: () async {
                  // Get current user
                  final currentUser = await UserService.fetchUser(UserService.currentUserId.toString(), isCelebrity: true);
                  // Find or create chatId for current user and viewed user
                  final otherUser = widget.user;
                  // Try to find an existing chat between these users
                  String? chatId;
                  final allChats = await ChatService.getAllChats();
                  for (final chat in allChats) {
                    if ((chat.user.id == otherUser.id)) {
                      chatId = chat.id;
                      break;
                    }
                  }
                  // If not found, create a new chatId (for demo, use a combination)
                  chatId ??= '${currentUser.id}_${otherUser.id}';
                  context.pushNamed(
                    'chatMessage',
                    pathParameters: {'chatId': chatId},
                    extra: otherUser,
                  );
                },
                child: SvgPicture.asset(
                  'assets/icons/message.svg',
                  height: 32,
                  width: 35,
                  colorFilter: ColorFilter.mode(Color(0xFFBDBCBA), BlendMode.srcIn),
                ),
              ),
            ],
          ),
          ResizableButton(
            text: localizations.events,
            onPressed: () {},
            width: 120,
            height: 35,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Color defaultTextColor, Color secondaryTextColor) {
    final localizations = AppLocalizations.of(context)!;
    int followers = 0;
    if (widget.user is CelebrityUser) {
      followers = (widget.user as CelebrityUser).followers;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${formatCount(followers)} ', // Removed `widget.user != null ?`
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: defaultTextColor,
            ),
          ),
          Text(
            localizations.followers,
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(width: 20),
          Text(
            widget.user.postsList != null ? '${widget.user.postsList!.length} ' : '0 ', // Removed `widget.user != null`
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: defaultTextColor,
            ),
          ),
          Text(
            localizations.posts,
            style: TextStyle(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final localizations = AppLocalizations.of(context)!;
    // Removed isCelebrity check to always show all 6 tabs
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
      tabs: const [ // Always show all 6 tabs
        Tab(text: 'Celebrations'),
        Tab(text: 'Personal'), // Using hardcoded string as in profile_page.dart for personalTab
        Tab(text: 'Wealth'), // Using hardcoded string as in profile_page.dart for wealthTab
        Tab(text: 'Career'), // Using hardcoded string as in profile_page.dart for careerTab
        Tab(text: 'Public Persona'), // Using hardcoded string as in profile_page.dart for publicPersonaTab
        Tab(text: 'Fun & Niche'),
      ],
    );
  }

  Widget _buildTabs() {
    // Removed isCelebrity check to always show all 6 TabBarView children
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsTab(),
        _buildPersonalTab(),
        _buildWealthTab(),
        _buildCareerTab(),
        _buildPublicPersonaTab(),
        _buildFunNicheTab()
      ],
    );
  }

  Widget _buildPostsTab(){
    if (posts.isEmpty) {
      return const Center(child: Text('No celebrations to display.'));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, i) => PostCard(
        post: posts[i],
        showFollowButton: false,
        onSharePressed: (post){
          showShareModal(context, post);
        },
      ),
    );
  }


  Widget _buildPersonalTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Check if the user is a CelebrityUser and has personal entries
    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No personal data available."));
    }
    final celeb = widget.user as CelebrityUser;
    // Dummy data for Pets (MOVED to Personal Tab, previously in Fun & Niche)

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Relationships Section
              _buildSectionHeader(
                  AppLocalizations.of(context)!.family,
                  Icons.link,
                  Color(0xFFD6AF0C),),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.familyMembers.length,
                  itemBuilder: (context, index) {
                    final relationship = celeb.familyMembers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _showProfilePreviewModal(
                            context: context,
                            userName: relationship['name'], // Replace with actual name if available
                            relationshipDesc: relationship['relation'], // Replace with actual relationship type if available
                            userProfileImageUrl: relationship['imageUrl'],
                            onViewProfile: () {
                              // Add navigation to profile view here
                            },
                          );
                        },
                        child: ProfileAvatar(
                          radius: 30,
                          imageUrl: relationship['imageUrl'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Relationships Section
              _buildSectionHeader(
                  AppLocalizations.of(context)!.relationships,
                  Icons.people,
                  Color(0xFFD6AF0C),),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.relationships.length,
                  itemBuilder: (context, index) {
                    final relationship = celeb.relationships[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _showProfilePreviewModal(
                            context: context,
                            userName: relationship['name'], // Replace with actual name if available
                            relationshipDesc: relationship['type'], // Replace with actual relationship type if available
                            userProfileImageUrl: relationship['imageUrl'],
                            onViewProfile: () {
                              // Add navigation to profile view here
                            },
                          );
                        },
                        child: ProfileAvatar(
                          radius: 30,
                          imageUrl: relationship['imageUrl'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Pets Section (MOVED here, displayed with ProfileAvatar)
              _buildSectionHeader(
                  AppLocalizations.of(context)!.pets,
                  Icons.pets,
                  Color(0xFFD6AF0C),),
              const SizedBox(height: 10),
              SizedBox(
                height: 60, // Height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.pets.length,
                  itemBuilder: (context, index) {
                    final pet = celeb.pets[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {
                          // Existing _showProfilePreviewModal for pets
                          _showProfilePreviewModal(
                            context: context,
                            userName: pet['name']!,
                            relationshipDesc: pet['type']!,
                            userProfileImageUrl: pet['imageUrl'],
                            onViewProfile: () {
                              // Optionally handle view profile action
                            },
                          );
                        },
                        child: ProfileAvatar(
                          radius: 30,
                          imageUrl: pet['imageUrl'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Education Section
              _buildSectionHeader(
                  AppLocalizations.of(context)!.education,
                  Icons.menu_book,
                  Color(0xFFD6AF0C),),
              const SizedBox(height: 10),
              ...celeb.educationEntries.map((entry) {
                final institution = entry['institution'] ?? '';
                final qualifications = (entry['qualifications'] as List?) ?.cast<Map<String, String>>() ?? [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    // This is the main Row for the icon and text content
                    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the top
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school_outlined, size: 35, color: Color(0xFFD6AF0C)),
                      ),
                      const SizedBox(width: 12), // Add spacing between icon and text
                      Expanded(
                        // This Expanded widget ensures the text content takes up remaining space
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              institution,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: defaultTextColor,
                              ),
                            ),
                            ...qualifications.map<Widget>((deg) {
                              return Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 2.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deg['title'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: defaultTextColor
                                                .withOpacity(0.85),
                                          ),
                                        ),
                                        if (deg['year'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Text(
                                              deg['year']!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: secondaryTextColor
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              _buildSectionHeader(
                  AppLocalizations.of(context)!.hobbies,
                  Icons.sports_soccer,
                  Color(0xFFD6AF0C),),
              // Hobbies Section
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.hobbies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _showItemPopupModal(
                            context: context,
                            sectionTitle: AppLocalizations.of(context)!.hobbies,
                            itemData: celeb.hobbies[index],
                            sectionType: celeb.hobbies[index]['name'], // Assuming description may be empty
                          );
                        },
                        child: ImageWithOptionalText(
                          width: 100,
                          height: 150,
                          imageUrl: celeb.hobbies[index]['imageUrl'],
                          bottomText: celeb.hobbies[index]['name'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Lifestyle Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nightlife, size: 24, color: Color(0xFFD6AF0C),),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.lifestyle,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD6AF0C)
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFD6AF0C)),
                    tooltip: 'Edit lifestyle',
                    onPressed: (){
                      //TODO: Add edit lifestyle
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Diet: ${celeb.diet}',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic ,color: defaultTextColor),
              ),
              Text(
                'Spirituality: ${celeb.spirituality}',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic , color: defaultTextColor),
              ),
              const SizedBox(height: 20),
              // Involved Causes Section
              _buildSectionHeader(
                  AppLocalizations.of(context)!.involvedCauses,
                  Icons.volunteer_activism,
                  Color(0xFFD6AF0C),),
              const SizedBox(height: 10),
              ...celeb.involvedCauses.map((cause) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Icon here if needed
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cause['cause'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: defaultTextColor,
                            ),
                          ),
                          Text(
                            cause['role'] ?? '',
                            style: TextStyle(fontSize: 14, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWealthTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (widget.user is! CelebrityUser) { // Simplified null check
      return const Center(child: Text("No wealth data available."));
    }
    final celeb = widget.user as CelebrityUser;
    final Map<String, List<Map<String, String>>> wealthData =
        celeb.wealthEntries;
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${localizations.netWorth} : ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                Text(
                  celeb.netWorth,
                  style: TextStyle(
                    fontSize: 18,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            ..._wealthCategories.map((categoryKey) {
              final items = wealthData[categoryKey] ?? [];
              if (items.isEmpty) return const SizedBox.shrink();
              String localizedCategory;
              IconData icon;
              switch (categoryKey) {
                case 'Cars':
                  localizedCategory = localizations.categoryValueCar;
                  icon = Icons.directions_car_sharp;
                  break;
                case 'Houses':
                  localizedCategory = localizations.categoryValueHouse;
                  icon = Icons.house;
                  break;
                case 'Art Collection':
                  localizedCategory = localizations.categoryValueArt;
                  icon = Icons.brush_outlined;
                  break;
                case 'Watch Collection':
                  localizedCategory = localizations.categoryValueJewelry;
                  icon = Icons.watch;
                  break;
                default:
                  localizedCategory = categoryKey;
                  icon = Icons.category_outlined;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    localizedCategory,
                    icon,
                    Color(0xFFD6AF0C),),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              _showItemPopupModal(
                                context: context,
                                sectionTitle: localizedCategory,
                                itemData: item,
                                sectionType: item['name']!, // Assuming description may be empty
                              );
                            }, // Wealth items don't trigger item_popup
                            child: ImageWithOptionalText(
                              width: 100,
                              height: 150,
                              imageUrl: item['imageUrl'],
                              bottomText: item['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.orange[300] : Colors.brown[300];
    if (widget.user is! CelebrityUser) { // Simplified null check
      return const Center(child: Text("No career data available."));
    }
    final celeb = widget.user as CelebrityUser;
    final Map<String, List<Map<String, String>>> careerData =
        celeb.careerEntries;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: careerData.entries
                .where((entry) => entry.value.isNotEmpty)
                .map((entry) {
              final category = entry.key;
              final items = entry.value;
              final icon = _careerCategoryIcons[category] ?? Icons.info_outline;

              return Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 32, color: iconColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category, // Use ! as celeb is non-null if isCelebrity is true
                            style: TextStyle( fontSize: 13,color: isDark ? Colors.orange[300] : Colors.brown[300]),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: items.map((item) {
                              if (category == 'Awards') {
                                final title = item['title'];
                                final award = item['award'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (title != null)
                                        Text(title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: defaultTextColor)),
                                      if (award != null)
                                        Text(award,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: defaultTextColor.withOpacity(0.8))),
                                    ],
                                  ),
                                );
                              } else if (category == 'Collaborations') {
                                final title = item['title'];
                                final subtitle = item['subtitle'];
                                final type = item['type'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (title != null)
                                        Text(title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: defaultTextColor)),
                                      if (subtitle != null)
                                        Text(subtitle,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: defaultTextColor.withOpacity(0.8))),
                                      if (type != null)
                                        Text(type,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: defaultTextColor.withOpacity(0.7))),
                                    ],
                                  ),
                                );
                              } else if (category == 'Debut Work') {
                                final title = item['title'];
                                final subtitle = item['subtitle'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (title != null)
                                        Text(title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: defaultTextColor)),
                                      if (subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(subtitle,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: defaultTextColor.withOpacity(0.8))),
                                      ],
                                    ],
                                  ),
                                );
                              } else {
                                // Covers 'Profession' and any other general categories
                                final title = item['title'];
                                final subtitle = item['subtitle'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (title != null)
                                        Text(title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: defaultTextColor)),
                                      if (subtitle != null)
                                        Text(subtitle,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: defaultTextColor.withOpacity(0.8))),
                                    ],
                                  ),
                                );
                              }
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),// Add some padding at the bottom
      ],
    );
  }


  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No public persona data available."));
    }

    final celeb = widget.user as CelebrityUser;

    // Dummy data for Public Persona sections (MODIFIED with image URLs)
    final Map<String, List<Map<String, String>>> publicPersonaData = {
      'Quotes or Public Statements': [
        {'quote': '“Be yourself; everyone else is already taken.”', 'context': 'Interview with Vogue, 2021.'},
        {'quote': '“The only way to do great work is to love what you do.”', 'context': 'Award acceptance speech, 2023.'},
      ],
    };


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Social Media Presence
            _buildSectionHeader(
                AppLocalizations.of(context)!.socialMediaPresence,
                Icons.public,
              Color(0xFFD6AF0C),),

            _buildSocialIcons(),
            const SizedBox(height: 20),

            // Public Image / Reputation
            _buildSectionHeader(
                AppLocalizations.of(context)!.publicImageReputation,
                Icons.stars,
              Color(0xFFD6AF0C),),
            ... celeb.publicImageDescription.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: defaultTextColor),
                    ),
                    Text(
                      item['description']!,
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            // Fashion Style (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.fashionStyle,
                Icons.whatshot,
              Color(0xFFD6AF0C),),
            const SizedBox(height: 10),
            ...celeb.fashionStyle.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key[0].toUpperCase() + entry.key.substring(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      itemBuilder: (context, idx) {
                        final img = entry.value[idx]['imageUrl'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ImageWithOptionalText(
                            width: 100,
                            height: 150,
                            imageUrl: img,
                            bottomText: null, // No bottom text for fashion images
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),

            // Red Carpet Moments (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.redCarpetMoments,
                Icons.movie_filter,
              Color(0xFFD6AF0C),),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: celeb.redCarpetMoments.length,
                itemBuilder: (context, index) {
                  final item = celeb.redCarpetMoments[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          sectionTitle: AppLocalizations.of(context)!.redCarpetMoments,
                          itemData: item,
                          sectionType: item['title'], // Assuming description may be empty
                        );
                      },
                      child: ImageWithOptionalText(
                        width: 100,
                        height: 150,
                        imageUrl: item['imageUrl'],
                        bottomText: item['title'],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Quotes or Public Statements
            _buildSectionHeader(
                AppLocalizations.of(context)!.quotesPublicStatements,
                Icons.format_quote,
              Color(0xFFD6AF0C),),
            ... celeb.quotesAndPublicStatements.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['quote'] ?? item['interaction']!,
                      style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: defaultTextColor),
                    ),
                    Text(
                      '- ${item['context']}',
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildFunNicheTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No personal data available."));
    }
    final celeb = widget.user as CelebrityUser;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tattoos or Unique Physical Traits (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.tattoos,
                Icons.brush,
              Color(0xFFD6AF0C),),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: celeb.tattoos.length,
                itemBuilder: (context, index) {
                  final tattoo = celeb.tattoos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          sectionTitle: AppLocalizations.of(context)!.tattoos,
                          itemData: tattoo,
                          sectionType: tattoo['name'], // Assuming description may be empty
                        );
                      },
                      child: ImageWithOptionalText(
                        width: 100,
                        height: 150,
                        imageUrl: tattoo['imageUrl'],
                        bottomText: tattoo['name'],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Favorite Things (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.favoriteThings,
                Icons.favorite_border,
              Color(0xFFD6AF0C),),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: celeb.favouriteThings.length,
                itemBuilder: (context, index) {
                  final item = celeb.favouriteThings[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          sectionTitle: AppLocalizations.of(context)!.favoriteThings,
                          itemData: item,
                          sectionType: item['item'], // Assuming description may be empty
                        );
                      },
                      child: ImageWithOptionalText(
                        width: 100,
                        height: 150,
                        imageUrl: item['imageUrl'],
                        bottomText: item['item'],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Hidden Talents (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.hiddenTalents,
                Icons.star_outline,
              Color(0xFFD6AF0C),),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: celeb.talents.length,
                itemBuilder: (context, index) {
                  final item = celeb.talents[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          sectionTitle: AppLocalizations.of(context)!.hiddenTalents,
                          itemData: item,
                          sectionType: item['name'], // Assuming description may be empty
                        );
                      },
                      child: ImageWithOptionalText(
                        width: 100,
                        height: 150,
                        imageUrl: item['imageUrl'],
                        bottomText: item['name'],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Fan Theories or Fan Interactions
            _buildSectionHeader(
                AppLocalizations.of(context)!.fanTheoriesInteractions,
                Icons.people_outline,
              Color(0xFFD6AF0C),),
            ... celeb.fanTheoriesOrInteractions.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['theory'] ?? item['interaction']!,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: defaultTextColor),
                    ),
                    Text(
                      item['description']!,
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(
      String title, IconData icon, Color defaultTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: defaultTextColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: defaultTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final appPrimaryColor = Theme.of(context).primaryColor;
    if (widget.user == null || widget.user is! CelebrityUser) return const SizedBox.shrink();
    final celeb = widget.user as CelebrityUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Socials Section
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: celeb.socials.length,
            itemBuilder: (context, index) {
              final social = celeb.socials[index];
              final iconPath = _getSocialIconPath(social['title']);
              if (iconPath.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    if (social['link'] != null) {
                      //TODO: Create a socials preview
                      // _launchSocialLink(social['link']);
                    }
                  },
                  child: Image.asset(
                    iconPath,
                    height: 40,
                    width: 40,
                    errorBuilder: (context, error, stackTrace) {
                      // Return a fallback icon if the image fails to load
                      return Icon(Icons.error_outline, size: 24, color: Colors.grey);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getSocialIconPath(String platform) {
    switch (platform) {
      case 'Instagram':
        return 'assets/icons/instagram_icon.png';
      case 'Facebook':
        return 'assets/icons/facebook_icon.png';
      case 'TikTok':
        return 'assets/icons/tiktok_icon.png';
      default:
        return '';
    }
  }
}