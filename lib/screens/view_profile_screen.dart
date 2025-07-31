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
      height: MediaQuery.of(context).size.height * 0.45,
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
    final isCelebrity = widget.user is CelebrityUser;
    _tabController = TabController(length: isCelebrity ? 6 : 1, vsync: this);
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
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    isCelebrity ? celeb!.occupation : '', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nationality', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    isCelebrity ? celeb!.nationality : '', // Use !
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Place of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.hometown : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date Of Birth', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    user.dob != null
                        ? DateFormat('MMMM d, y').format(user.dob) // Format as "July 31, 2025"
                        : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Zodiac Sign', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  Text(
                    isCelebrity ? celeb!.zodiacSign : '', // Use !
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
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
                ],
              ),
            ],
          ),
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
    final isCelebrity = widget.user is CelebrityUser;

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
      tabs: isCelebrity ? [
        const Tab(text: 'Celebrations'), // Added const
        Tab(text: localizations.personalTab),
        Tab(text: localizations.wealthTab),
        Tab(text: localizations.careerTab),
        Tab(text: localizations.publicPersonaTab),
        const Tab(text: 'Fun & Niche'), // New Tab
      ] : const [ // Added const
        Tab(text: 'Celebrations'),
      ],
    );
  }

  Widget _buildTabs() {
    final isCelebrity = widget.user is CelebrityUser;

    return TabBarView(
      controller: _tabController,
      children: isCelebrity ? [
        _buildPostsTab(),
        _buildPersonalTab(),
        _buildWealthTab(),
        _buildCareerTab(),
        _buildPublicPersonaTab(),
        _buildFunNicheTab()
      ] : [
        _buildPostsTab(),
      ],
    );
  }

  Widget _buildPostsTab(){
    if (posts.isEmpty) {
      return const Center(child: Text('No celebrations to display'));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, i) => PostCard(post: posts[i], showFollowButton: false),
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
    bool hasAnyCareerItems = careerData.values.any((list) =>
        list.any((item) {
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
            return (item['title']?.isNotEmpty ?? false) ||
                (item['subtitle']?.isNotEmpty ?? false) ||
                (item['type']?.isNotEmpty ?? false);
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
              switch (categoryKey) {
                case 'Cars':
                  localizedCategory = localizations.categoryValueCar;
                  break;
                case 'Houses':
                  localizedCategory = localizations.categoryValueHouse;
                  break;
                case 'Art Collection':
                  localizedCategory = localizations.categoryValueArt;
                  break;
                case 'Watch Collection':
                  localizedCategory = localizations.categoryValueJewelry;
                  break;
                default:
                  localizedCategory = categoryKey;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedCategory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
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
                            onTapDown: (details) {
                              showProfileActionPopup(
                                context: context,
                                globalPosition: details.globalPosition,
                                onReview: () {
                                  // Use empty list and dummy postId if not available
                                  _showCommentsModal(context, [], postId: 'profile');
                                },
                                onPreview: () {},
                                onSalute: () {},
                                onRate: (rating) {},
                                currentRating: 0,
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
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab(){
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (widget.user is! CelebrityUser) { // Simplified null check
      return const Center(child: Text("No personal data available."));
    }
    final celeb = widget.user as CelebrityUser;

    // Check if there's any personal information to display
    bool hasAnyContent = celeb.zodiacSign.isNotEmpty ||
        celeb.relationships.isNotEmpty ||
        celeb.educationEntries.isNotEmpty ||
        celeb.hobbies.isNotEmpty ||
        celeb.diet.isNotEmpty ||
        celeb.spirituality.isNotEmpty ||
        celeb.involvedCauses.isNotEmpty ||
        celeb.pets.isNotEmpty ||
        celeb.tattoos.isNotEmpty ||
        celeb.favouritePlaces.isNotEmpty;

    if (!hasAnyContent) {
      return const Center(child: Text("No personal information to display"));
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign
              Text(
                '${AppLocalizations.of(context)!.sign}: ${celeb.zodiacSign}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 20),
              // Relationships Section
              if (celeb.relationships.isNotEmpty) ...[
                Text(
                  'Family and relationships',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: celeb.relationships.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTapDown: (details) {
                            showProfileActionPopup(
                              context: context,
                              globalPosition: details.globalPosition,
                              onReview: () {
                                // Use empty list and dummy postId if not available
                                _showCommentsModal(context, [], postId: 'profile');
                              },
                              onSalute: () {},
                              onPreview: () {
                                // Check for null before accessing user properties
                                if (widget.user != null) {
                                  _showProfilePreviewModal(
                                    context: context,
                                    userName: widget.user.fullName, // Removed !
                                    userProfession: widget.user is CelebrityUser ? (widget.user as CelebrityUser).occupation : '',
                                    userProfileImageUrl: widget.user.profileImageUrl, // Removed !
                                    onViewProfile: () {
                                      // Optionally handle view profile action
                                    },
                                  );
                                }
                              },
                              onRate: (rating) {},
                              currentRating: 0,
                            );
                          },
                          child: ProfileAvatar(
                            radius: 30,
                            imageUrl: celeb.relationships[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ], // Closing bracket for Relationships Section if
              // Education Section
              if (celeb.educationEntries.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.education,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...celeb.educationEntries.map((entry) {
                  // entry: {'university': 'Princeton University', 'degrees': [ {title, year}, ... ] }
                  final university = entry['university'] ?? '';
                  final degrees = (entry['degrees'] as List?)?.cast<Map<String, String>>() ?? []; // Cast to correct type
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                university,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: defaultTextColor,
                                ),
                              ),
                              ...degrees.map<Widget>((deg) {
                                return Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.school_outlined, size: 35, color: const Color(0xFFD6AF0C)), // Added const
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 2.0),
                                      child: GestureDetector(
                                        onTapDown: (details) {
                                          showProfileActionPopup(
                                            context: context,
                                            globalPosition: details.globalPosition,
                                            onReview: () {
                                              // Use empty list and dummy postId if not available
                                              _showCommentsModal(context, [], postId: 'profile');
                                            },
                                            onPreview: () {},
                                            onSalute: () {},
                                            onRate: (rating) {},
                                            currentRating: 0,
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deg['title'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: defaultTextColor.withOpacity(0.85),
                                              ),
                                            ),
                                            if (deg['year'] != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2.0),
                                                child: Text(
                                                  deg['year']!, // Use ! as checked for null
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: secondaryTextColor.withOpacity(0.7),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
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
              ], // Closing bracket for Education Section if

              // Hobbies Section
              if (celeb.hobbies.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.hobbies,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
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
                          onTapDown: (details) {
                            showProfileActionPopup(
                              context: context,
                              globalPosition: details.globalPosition,
                              onReview: () {
                                // Use empty list and dummy postId if not available
                                _showCommentsModal(context, [], postId: 'profile');
                              },
                              onPreview: () {},
                              onSalute: () {},
                              onRate: (rating) {},
                              currentRating: 0,
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
              ], // Closing bracket for Hobbies Section if

              // Lifestyle Section
              if (celeb.diet.isNotEmpty || celeb.spirituality.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.lifestyle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (celeb.diet.isNotEmpty)
                  Text(
                    'Diet: ${celeb.diet}',
                    style: TextStyle(fontSize: 14, color: defaultTextColor),
                  ),
                if (celeb.spirituality.isNotEmpty)
                  Text(
                    'Spirituality: ${celeb.spirituality}',
                    style: TextStyle(fontSize: 14, color: defaultTextColor),
                  ),
                const SizedBox(height: 20),
              ], // Closing bracket for Lifestyle Section if

              // Involved Causes Section
              if (celeb.involvedCauses.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.involvedCauses,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
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
                          child: const Icon(Icons.volunteer_activism, size: 30, color: const Color(0xFFD6AF0C)), // Added a placeholder icon
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cause['name'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: defaultTextColor,
                              ),
                            ),
                            Text(
                              cause['role'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ], // Closing bracket for Involved Causes Section if

              // Pets Section
              if (celeb.pets.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.pets,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: celeb.pets.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTapDown: (details) {
                            showProfileActionPopup(
                              context: context,
                              globalPosition: details.globalPosition,
                              onReview: () {
                                // Use empty list and dummy postId if not available
                                _showCommentsModal(context, [], postId: 'profile');
                              },
                              onPreview: () {},
                              onSalute: () {},
                              onRate: (rating) {},
                              currentRating: 0,
                            );
                          },
                          child: ProfileAvatar(
                            radius: 30,
                            imageUrl: celeb.pets[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ], // Closing bracket for Pets Section if

              // Tattoos Section
              if (celeb.tattoos.isNotEmpty) ...[
                Text(
                  AppLocalizations.of(context)!.tattoos,
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
                    itemCount: celeb.tattoos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTapDown: (details) {
                            showProfileActionPopup(
                              context: context,
                              globalPosition: details.globalPosition,
                              onReview: () {
                                // Use empty list and dummy postId if not available
                                _showCommentsModal(context, [], postId: 'profile');
                              },
                              onSalute: () {},
                              onPreview: () {},
                              onRate: (rating) {},
                              currentRating: 0,
                            );
                          },
                          child: ImageWithOptionalText(
                            width: 100,
                            height: 150,
                            imageUrl: celeb.tattoos[index],
                            bottomText: null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ], // Closing bracket for Tattoos Section if

              // Favourites Section
              Text(
                AppLocalizations.of(context)!.favourites,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.favouritePlaces.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {
                          showProfileActionPopup(
                            context: context,
                            globalPosition: details.globalPosition,
                            onReview: () {
                              // Use empty list and dummy postId if not available
                              _showCommentsModal(context, [], postId: 'profile');
                            },
                            onSalute: () {},
                            onPreview: () {},
                            onRate: (rating) {},
                            currentRating: 0,
                          );
                        },
                        child: ImageWithOptionalText(
                          width: 100,
                          height: 150,
                          imageUrl: celeb.favouritePlaces[index]['imageUrl'],
                          bottomText: celeb.favouritePlaces[index]['name'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Talents Section
              Text(
                AppLocalizations.of(context)!.talents,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.talents.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {
                          showProfileActionPopup(
                            context: context,
                            globalPosition: details.globalPosition,
                            onReview: () {
                              // Use empty list and dummy postId if not available
                              _showCommentsModal(context, [], postId: 'profile');
                            },
                            onSalute: () {},
                            onPreview: () {},
                            onRate: (rating) {},
                            currentRating: 0,
                          );
                        },
                        child: ImageWithOptionalText(
                          width: 100,
                          height: 150,
                          imageUrl: celeb.talents[index]['imageUrl'],
                          bottomText: celeb.talents[index]['name'],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title, IconData icon, Color textColor, VoidCallback onAddPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: textColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD6AF0C)),
          tooltip: 'Add $title',
          onPressed: onAddPressed,
        ),
      ],
    );
  }

  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final appPrimaryColor = Theme.of(context).primaryColor;

    if (widget.user is! CelebrityUser) {
      return const Center(child: Text("No public persona data available"));
    }
    final celeb = widget.user as CelebrityUser;

    // Check if there's any public persona information to display
    bool hasAnyContent =
        celeb.socials.any((social) =>
        (social['title']?.isNotEmpty ?? false) ||
            (social['link']?.isNotEmpty ?? false)) ||
            celeb.publicImageDescription.isNotEmpty ||
            celeb.controversyMedia.any((controversy) =>
            (controversy['controversy']?.isNotEmpty ?? false) ||
                ((controversy['media'] as List?)?.isNotEmpty == true)) ||
            celeb.fashionStyle.entries.any((entry) =>
                entry.value.any((item) =>
                (item['imageUrl']?.isNotEmpty ?? false)));

    if (!hasAnyContent) {
      return const Center(child: Text("No persona entries"));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Socials Section
            if (celeb.socials.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.socials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.socials.length,
                  itemBuilder: (context, index) {
                    final social = celeb.socials[index];
                    final iconPath = 'assets/icons/socials/${social['title']?.toLowerCase()}.png';

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          if (social['link'] != null) {
                            // Add url_launcher implementation here
                            print('Opening: ${social['link']}');
                          }
                        },
                        child: Image.asset(
                          iconPath,
                          height: 40,
                          width: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error_outline, size: 24, color: Colors.grey);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Public Image Description
            if (celeb.publicImageDescription.isNotEmpty) ...[
              Text(
                'Public Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                celeb.publicImageDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Fashion Style Section
            if (celeb.fashionStyle.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.fashionStyle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 10),
              ...celeb.fashionStyle.entries.map((entry) {
                if (entry.value.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key[0].toUpperCase() + entry.key.substring(1),
                      style: TextStyle(
                        fontSize: 14,
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
                              bottomText: null,
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

            // Fan Theories & Interactions Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.fanTheoriesInteractions,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
      return const Center(child: Text("No fun & niche data available."));
    }
    final celeb = widget.user as CelebrityUser;

    // Dummy data for Fun or Niche Details sections (MODIFIED with image URLs)
    final Map<String, List<Map<String, String>>> funNicheData = {
      'Tattoos or Unique Physical Traits': [
        {'title': 'Anchor Tattoo', 'description': 'Small anchor on left wrist, symbolizing stability.', 'imageUrl': 'https://i.ibb.co/Zc01k23/tattoo1.jpg'},
        {'title': 'Birthmark', 'description': 'Star-shaped birthmark on right shoulder.', 'imageUrl': 'https://i.ibb.co/pLg0L67/tattoo2.jpg'},
        {'title': 'Dragon Sleeve', 'description': 'Intricate dragon design covering the entire left arm.', 'imageUrl': 'https://i.ibb.co/6y45sKq/tattoo3.jpg'},
      ],
      'Favorite Things': [
        {'category': 'Food', 'item': 'Sushi', 'description': 'Loves all kinds of sushi, especially salmon nigiri.', 'imageUrl': 'https://i.ibb.co/y423n5P/fave-sushi.jpg'},
        {'category': 'Place', 'item': 'Kyoto, Japan', 'description': 'Enjoys the tranquility and cultural richness.', 'imageUrl': 'https://i.ibb.co/c123h1j/fave-kyoto.jpg'},
        {'category': 'Music Genre', 'item': 'Jazz', 'description': 'Finds inspiration and relaxation in jazz music.', 'imageUrl': 'https://i.ibb.co/9y56g7F/fave-jazz.jpg'},
      ],
      'Hidden Talents': [
        {'title': 'Juggling', 'description': 'Can juggle up to five objects simultaneously.', 'imageUrl': 'https://i.ibb.co/C0f11Kk/talent-juggling.jpg'}, // Placeholder image
        {'title': 'Amateur Chef', 'description': 'Known among friends for cooking gourmet meals.', 'imageUrl': 'https://i.ibb.co/y4L2k2n/talent-chef.jpg'}, // Placeholder image
      ],
      'Fan Theories or Fan Interactions': [
        {'theory': 'Secret Album Theory', 'description': 'Fans speculate about a hidden album to be released on a specific date.'},
        {'interaction': 'Surprise Fan Meetup', 'description': 'Known for organizing spontaneous meetups with fans in different cities.'},
      ],
      // 'Pets' section removed from here and moved to personal tab
    };

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
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddFunNicheModal(
                      sectionTitle: AppLocalizations.of(context)!.tattoos,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (funNicheData['Tattoos or Unique Physical Traits'] ?? []).length,
                itemBuilder: (context, index) {
                  final item = funNicheData['Tattoos or Unique Physical Traits']![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title: item['title']!,
                          description: item['description']!,
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

            // Favorite Things (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.favoriteThings,
                Icons.favorite_border,
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddFunNicheModal(
                      sectionTitle: AppLocalizations.of(context)!.favoriteThings,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (funNicheData['Favorite Things'] ?? []).length,
                itemBuilder: (context, index) {
                  final item = funNicheData['Favorite Things']![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title: '${item['category']}: ${item['item']}',
                          description: item['description']!,
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
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddFunNicheModal(
                      sectionTitle: AppLocalizations.of(context)!.hiddenTalents,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            const SizedBox(height: 10),
            SizedBox(
              height: 170, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (funNicheData['Hidden Talents'] ?? []).length,
                itemBuilder: (context, index) {
                  final item = funNicheData['Hidden Talents']![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title: item['title']!,
                          description: item['description']!,
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

            // Fan Theories or Fan Interactions
            _buildSectionHeader(
                AppLocalizations.of(context)!.fanTheoriesInteractions,
                Icons.people_outline,
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddFunNicheModal(
                      sectionTitle: AppLocalizations.of(context)!.fanTheoriesInteractions,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            ... (funNicheData['Fan Theories or Fan Interactions'] ?? []).map((item) {
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
}

class ProfilePreviewModalContent extends StatelessWidget {
  final String userName;
  final String userProfession;
  final String? userProfileImageUrl;
  final VoidCallback? onViewProfile;
  final Color? defaultTextColor;
  final Color? secondaryTextColor;
  final Color? appPrimaryColor;

  const ProfilePreviewModalContent({
    Key? key,
    required this.userName,
    required this.userProfession,
    this.userProfileImageUrl,
    this.onViewProfile,
    this.defaultTextColor,
    this.secondaryTextColor,
    this.appPrimaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color _defaultTextColor = defaultTextColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black);
    final Color _secondaryTextColor = secondaryTextColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600);
    final Color _appPrimaryColor = appPrimaryColor ?? Theme.of(context).primaryColor;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileAvatar(radius: 30, imageUrl: userProfileImageUrl ?? 'https://via.placeholder.com/150'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _defaultTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.orange, size: 18), // Added const
                    ],
                  ),
                  Text(
                    userProfession,
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onViewProfile ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _appPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                localizations.viewProfile,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        // This Expanded SizedBox was preventing the lower content from rendering if the modal height was constrained.
        // It's usually not needed unless you specifically want the content to push down.
        // For a modal with Column, minAxisSize: MainAxisSize.min is better.
        // const Expanded(
        //   child: SizedBox(),
        // ),
        const SizedBox(height: 20), // Add some spacing here instead
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _defaultTextColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userName, // This seems to be a placeholder, you might want a bio or description here
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _defaultTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ControversyCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> controversyMedia;
  final Color defaultTextColor;
  final Color cardColor;
  const _ControversyCarousel({
    required this.controversyMedia,
    required this.defaultTextColor,
    required this.cardColor,
    Key? key,
  }) : super(key: key);

  @override
  State<_ControversyCarousel> createState() => _ControversyCarouselState();
}

class _ControversyCarouselState extends State<_ControversyCarousel> {
  int _currentIndex = 0;

  void _goLeft() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.controversyMedia.length) % widget.controversyMedia.length;
    });
  }

  void _goRight() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.controversyMedia.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controversyMedia.isEmpty) {
      return const SizedBox.shrink(); // Don't build if no media
    }

    final cont = widget.controversyMedia[_currentIndex];
    final List media = cont['media'] ?? [];
    final String controversy = cont['controversy'] ?? '';
    const double cardWidth = 120; // Added const
    const double cardHeight = 100; // Added const
    const double spacing = 8; // Added const

    Widget buildMediaBox(String url, {bool isVideo = false}) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.defaultTextColor.withOpacity(0.2)),
        ),
        child: isVideo
            ? Center(child: Icon(Icons.play_circle_fill, size: 50, color: Colors.grey[400])) // Adjusted icon color
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      );
    }

    List<Widget> buildGrid() {
      if (media.length == 1) {
        final url = media[0].toString(); // Ensure it's a string
        final isVideo = url.endsWith('.mp4');
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildMediaBox(url, isVideo: isVideo),
            ],
          ),
        ];
      } else if (media.length == 2) {
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildMediaBox(media[0].toString(), isVideo: media[0].toString().endsWith('.mp4')),
              const SizedBox(width: spacing), // Added const
              buildMediaBox(media[1].toString(), isVideo: media[1].toString().endsWith('.mp4')),
            ],
          ),
        ];
      } else if (media.length >= 3) {
        // 2x2 grid: left column (2 rows), right column (1 row, full height)
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column (2 rows)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildMediaBox(media[0].toString(), isVideo: media[0].toString().endsWith('.mp4')),
                  const SizedBox(height: spacing), // Added const
                  buildMediaBox(media[1].toString(), isVideo: media[1].toString().endsWith('.mp4')),
                ],
              ),
              const SizedBox(width: spacing), // Added const
              // Right column (one media, full height)
              // Ensure this Container correctly wraps the media box and fits its content
              SizedBox( // Changed to SizedBox for explicit dimensions
                width: cardWidth,
                height: cardHeight * 2 + spacing,
                child: buildMediaBox(media[2].toString(), isVideo: media[2].toString().endsWith('.mp4')),
              ),
            ],
          ),
        ];
      }
      return [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controversy,
          style: TextStyle(fontSize: 14, color: widget.defaultTextColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left, color: widget.defaultTextColor),
              onPressed: widget.controversyMedia.length > 1 ? _goLeft : null,
            ),
            // Correctly spread the list of widgets returned by buildGrid()
            ...buildGrid(),
            IconButton(
              icon: Icon(Icons.arrow_right, color: widget.defaultTextColor),
              onPressed: widget.controversyMedia.length > 1 ? _goRight : null,
            ),
          ],
        ),
      ],
    );
  }
}