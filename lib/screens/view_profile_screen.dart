import 'package:celebrating/widgets/add_wealth_item_modal.dart';
import 'package:celebrating/widgets/slideup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
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
    required String userProfession,
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
        userProfession: userProfession,
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
    String? imageUrl,
    required String title,
    required String description,
  }) {
    showSlideUpDialog(
      context: context,
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.9,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Theme.of(context).cardColor,
      child: ItemPopupModal(
        imageUrl: imageUrl,
        title: title,
        description: description,
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
                expandedHeight: 430.0, // Estimated height of header content
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
                  const SizedBox(height: 5),
                  Text(
                    'Profession', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    isCelebrity ? celeb!.occupation : '', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nationality', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    isCelebrity ? celeb!.nationality : '', // Use !
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Place of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.hometown : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date Of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    user.dob != null
                        ? DateFormat('MMMM d, y').format(user.dob) // Format as "July 31, 2025"
                        : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Zodiac Sign', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
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
                onTap: (){},
                child: SvgPicture.asset(
                  'assets/icons/message.svg', // Replace with your icon's path
                  height: 32,
                  width: 35,
                  colorFilter: ColorFilter.mode(Color(0xFFBDBCBA), BlendMode.srcIn), // You can easily change colors
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
      itemBuilder: (context, i) => PostCard(post: posts[i], showFollowButton: false),
    );
  }

  Widget _buildPersonalTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.orange[300] : Colors.brown[300];

    // Check if the user is a CelebrityUser and has personal entries
    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No personal data available."));
    }

    final celeb = widget.user as CelebrityUser;
    // Dummy personal data
    final Map<String, List<Map<String, String>>> personalData = {
      'Relationships': [
        {'name': 'Jane Doe', 'type': 'Friend', 'description': 'Best friend from college.'},
        {'name': 'John Smith', 'type': 'Sibling', 'description': 'Older brother.'},
      ],
      'Education': [
        {'institution': 'Harvard University', 'degree': 'B.A. in Music', 'period': '2010-2014'},
      ],
    };

    // A map to define icons for each category, similar to careerCategoryIcons
    final Map<String, IconData> personalCategoryIcons = {
      'Relationships': Icons.favorite_outline,
      'Education': Icons.school_outlined,
      'Other': Icons.info_outline, // Default or for categories without specific icons
    };

    return ListView(
      children: personalData.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) {
        final category = entry.key;
        final items = entry.value;
        final icon = personalCategoryIcons[category] ?? Icons.info_outline;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      category,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.orange[300] : Colors.brown[300]),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((item) {
                        if (category == 'Relationships') {
                          final name = item['name'];
                          final type = item['type'];
                          final description = item['description'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (name != null)
                                  Text(
                                    name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: defaultTextColor),
                                  ),
                                if (type != null)
                                  Text(
                                    type,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: defaultTextColor.withOpacity(0.8)),
                                  ),
                                if (description != null)
                                  Text(
                                    description,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: defaultTextColor.withOpacity(0.7)),
                                  ),
                              ],
                            ),
                          );
                        } else if (category == 'Education') {
                          final institution = item['institution'];
                          final degree = item['degree'];
                          final period = item['period'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (institution != null)
                                  Text(
                                    institution,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: defaultTextColor),
                                  ),
                                if (degree != null)
                                  Text(
                                    degree,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: defaultTextColor.withOpacity(0.8)),
                                  ),
                                if (period != null)
                                  Text(
                                    period,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: defaultTextColor.withOpacity(0.7)),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          // General structure for other personal items
                          final title = item['title'];
                          final description = item['description'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title != null)
                                  Text(
                                    title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: defaultTextColor),
                                  ),
                                if (description != null)
                                  Text(
                                    description,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: defaultTextColor.withOpacity(0.7)),
                                  ),
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
    );
  }

  Widget _buildWealthTab(){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (widget.user is! CelebrityUser) { // Simplified null check
      return const Center(child: Text("No wealth data available."));
    }
    final celeb = widget.user as CelebrityUser;
    final Map<String, List<Map<String, String>>> wealthData = celeb.wealthEntries;
    final localizations = AppLocalizations.of(context)!;
    // Check if there are any items in any category
    bool hasAnyItems = false;
    for (var category in _wealthCategories) {
      if ((wealthData[category] ?? []).isNotEmpty) {
        hasAnyItems = true;
        break;
      }
    }
    if (!hasAnyItems) {
      return const Center(child: Text("No wealth items to display"));
    }
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
                      color: defaultTextColor),
                ),
                Text(
                  celeb.netWorth, // Assuming netWorth is a String or formatted as such
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._wealthCategories.map((category) {
              final items = wealthData[category] ?? [];
              if (items.isEmpty) return const SizedBox.shrink(); // Hide if no items

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(category, Icons.category, defaultTextColor), // Generic icon for now
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8, // Adjust as needed
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () => _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title: item['title']!,
                          description: item['description']!,
                        ),
                        child: ImageWithOptionalText(
                          width: 150,
                          height: 150,
                          imageUrl: item['imageUrl'],
                          bottomText: item['title'],
                        ),
                      );
                    },
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
    final iconColor = isDark ? const Color(0xFFD6AF0C): Colors.brown[300];
    if (widget.user is! CelebrityUser) { // Simplified null check
      return const Center(child: Text("No career data available."));
    }
    final celeb = widget.user as CelebrityUser;
    final Map<String, List<Map<String, String>>> careerData = celeb.careerEntries;

    // Check if there are any career items with actual content
    bool hasAnyCareerItems = careerData.values.any((list) => list.any((item) {
      if (item.containsKey('title') && item['title']?.isNotEmpty == true) return true;
      if (item.containsKey('award') && item['award']?.isNotEmpty == true) return true;
      if (item.containsKey('subtitle') && item['subtitle']?.isNotEmpty == true) return true;
      if (item.containsKey('type') && item['type']?.isNotEmpty == true) return true;
      return false;
    })
    );

    if (!hasAnyCareerItems) {
      return const Center(child: Text("No career entries"));
    }

    return ListView(
      children: careerData.entries
          .where((entry) {
        // Only include categories that have items with non-null values
        return entry.value.any((item) {
          if (entry.key == 'Awards') {
            return (item['title']?.isNotEmpty ?? false) || (item['award']?.isNotEmpty ?? false);
          } else if (entry.key == 'Collaborations') {
            return (item['title']?.isNotEmpty ?? false) || (item['subtitle']?.isNotEmpty ?? false) || (item['type']?.isNotEmpty ?? false);
          } else if (entry.key == 'Debut Work') {
            return (item['title']?.isNotEmpty ?? false) || (item['subtitle']?.isNotEmpty ?? false);
          } else {
            return (item['title']?.isNotEmpty ?? false) || (item['subtitle']?.isNotEmpty ?? false);
          }
        });
      })
          .map((entry) {
        final category = entry.key;
        final items = entry.value;
        final icon = _careerCategoryIcons[category] ?? Icons.info_outline;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: defaultTextColor)),
                            if (award != null)
                              Text(award, style: TextStyle(fontSize: 15, color: defaultTextColor.withOpacity(0.8))),
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
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: defaultTextColor)),
                            if (subtitle != null)
                              Text(subtitle, style: TextStyle(fontSize: 15, color: defaultTextColor.withOpacity(0.8))),
                            if (type != null)
                              Text(type, style: TextStyle(fontSize: 13, color: defaultTextColor.withOpacity(0.7))),
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
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: defaultTextColor)),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(subtitle, style: TextStyle(fontSize: 15, color: defaultTextColor.withOpacity(0.8))),
                            ],
                          ],
                        ),
                      );
                    } else { // Covers 'Profession' and any other general categories
                      final title = item['title'];
                      final subtitle = item['subtitle'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: defaultTextColor)),
                            if (subtitle != null)
                              Text(subtitle, style: TextStyle(fontSize: 15, color: defaultTextColor.withOpacity(0.8))),
                          ],
                        ),
                      );
                    }
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No public persona data available."));
    }

    final celeb = widget.user as CelebrityUser;
    // Dummy public persona data
    final Map<String, List<Map<String, String>>> publicPersonaData = {
      'Personas': [
        {'title': 'The Charmer', 'description': 'Known for a charismatic stage presence.'},
        {'title': 'The Philanthropist', 'description': 'Active in charity events.'},
      ],
      'Relationships': [
        {'name': 'Jane Doe', 'type': 'Manager', 'description': 'Longtime manager and friend.'},
      ],
    };

    // Check if there are any public persona items
    bool hasPublicPersonaItems = publicPersonaData.values.any((list) => list.isNotEmpty);
    if (!hasPublicPersonaItems) {
      return const Center(child: Text("No public persona items to display."));
    }

    // A map to define icons for each category
    final Map<String, IconData> publicPersonaCategoryIcons = {
      'Personas': Icons.masks_outlined,
      'Relationships': Icons.people_alt_outlined,
      'Other': Icons.info_outline, // Default or for categories without specific icons
    };


    return ListView(
      children: publicPersonaData.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) {
        final category = entry.key;
        final items = entry.value;
        final icon = publicPersonaCategoryIcons[category] ?? Icons.info_outline;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(category, icon, defaultTextColor),
              const SizedBox(height: 10),
              ...items.map((item) {
                if (category == 'Personas') {
                  final title = item['title'];
                  final description = item['description'];
                  final imageUrl = item['imageUrl'];

                  return GestureDetector(
                    onTap: () => _showItemPopupModal(
                      context: context,
                      imageUrl: imageUrl,
                      title: title!,
                      description: description!,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: defaultTextColor),
                            ),
                          if (description != null)
                            Text(
                              description,
                              style: TextStyle(fontSize: 14, color: secondaryTextColor),
                            ),
                        ],
                      ),
                    ),
                  );
                } else if (category == 'Relationships') {
                  final name = item['name'];
                  final type = item['type'];
                  final description = item['description'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (name != null)
                          Text(
                            name,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: defaultTextColor),
                          ),
                        if (type != null)
                          Text(
                            type,
                            style: TextStyle(fontSize: 14, color: secondaryTextColor),
                          ),
                        if (description != null)
                          Text(
                            description,
                            style: TextStyle(fontSize: 14, color: secondaryTextColor),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink(); // Fallback for unhandled categories
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFunNicheTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No fun & niche data available."));
    }

    final celeb = widget.user as CelebrityUser;
    // Dummy fun & niche data
    final Map<String, List<Map<String, String>>> funNicheData = {
      'Favorite Things': [
        {'item': 'Sushi', 'description': 'Loves all kinds of sushi, especially salmon nigiri.'},
        {'item': 'Jazz', 'description': 'Finds inspiration and relaxation in jazz music.'},
      ],
      'Fan Theories or Fan Interactions': [
        {'theory': 'Secret Album Theory', 'description': 'Fans speculate about a hidden album to be released on a specific date.'},
        {'interaction': 'Surprise Fan Meetup', 'description': 'Known for organizing spontaneous meetups with fans in different cities.'},
      ],
    };

    bool hasFunNicheItems = funNicheData.values.any((list) => list.isNotEmpty);
    if (!hasFunNicheItems) {
      return const Center(child: Text("No fun & niche items to display."));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Favorite Things',
              Icons.favorite_border,
              defaultTextColor,
            ),
            ... (funNicheData['Favorite Things'] ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: defaultTextColor),
                    ),
                    Text(
                      item['description'] ?? '',
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            _buildSectionHeader(
              AppLocalizations.of(context)!.fanTheoriesInteractions,
              Icons.people_outline,
              defaultTextColor,
            ),
            ... (funNicheData['Fan Theories or Fan Interactions'] ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['theory'] ?? item['interaction'] ?? '',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: defaultTextColor),
                    ),
                    Text(
                      item['description'] ?? '',
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