import 'package:celebrating/widgets/add_career_higlights_modal.dart';
import 'package:celebrating/widgets/add_wealth_item_modal.dart';
import 'package:celebrating/widgets/slideup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/add_education_modal.dart';
import '../widgets/add_persona_modal.dart';
import '../widgets/add_relationship_modal.dart';
import '../widgets/add_fun_niche_modal.dart';
import '../widgets/app_buttons.dart';
import '../widgets/comments_modal.dart';
import '../widgets/image_optional_text.dart';
import '../widgets/item_popup_modal.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_preview_modal_content.dart';

class ProfilePage extends StatefulWidget {
  // Added userId parameter to enable viewing other user profiles
  final String? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CelebrityUser? user;
  bool isLoading = true;
  List<Post> posts = [];


  // --- MISSING VARIABLES AND METHODS ---
  bool isOwnProfile = false; // Set to true if viewing own profile
  bool statsLoading = false; // Set to true if stats are loading

  void _handleFollowUnfollow() {
    // Implement follow/unfollow logic here
    setState(() {
      // Toggle follow state for demo
      isOwnProfile = !isOwnProfile;
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

  void fetchProfileUser() async {
    // Use widget.userId if provided, otherwise a default for testing/own profile
    final String userIdToFetch = widget.userId ?? '456';
    final fetchedUser =
    await UserService.fetchUser(userIdToFetch, isCelebrity: true);
    if (fetchedUser is CelebrityUser) {
      setState(() {
        user = fetchedUser;
        posts = fetchedUser.postsList ?? [];
        isLoading = false;
        // Determine if it's the user's own profile (dummy logic for now)
        isOwnProfile = (widget.userId == null ||
            widget.userId ==
                'currentLoggedInUserId'); // Replace 'currentLoggedInUserId' with actual ID
      });
      print('Celebrity user: ${fetchedUser.fullName}');
      print('Occupation: ${fetchedUser.occupation}');
      print('Followers: ${fetchedUser.followers}');
      print('PostsList: ${fetchedUser.postsList}');
    }
  }

  // MODIFIED: _showProfilePreviewModal to include action buttons
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
        isOwnProfile: isOwnProfile,
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

  // NEW: _showItemPopupModal for image-enabled sections
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
        isOwnProfile: isOwnProfile,
        imageUrl: imageUrl,
        title: title,
        description: description,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Call the method to fetch a celebrity user
    fetchProfileUser();
    _tabController = TabController(length: 6, vsync: this); // Length remains 6 as two sections replaced one
  }

  final Map<String, IconData> _careerCategoryIcons = {
    'Profession': Icons.work_outline,
    'Debut Work': Icons.rocket_launch_outlined,
    'Awards': Icons.emoji_events_outlined,
    'Songs': Icons.music_note_outlined,
    'Collaborations':
    Icons.group_add_outlined, // Added icon for collaborations
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

  void _showCommentsModal(BuildContext context, List<Comment> comments,
      {required String postId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor:
          0.85, // Adjust this to control how much screen height the modal takes
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
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 450.0, // Estimated height of header content
                floating: true,
                pinned: true,
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
    final isCelebrity = user is CelebrityUser;
    final celeb = isCelebrity ? user as CelebrityUser : null;
    return Container( // Wrap with Container
      color: Theme.of(context).cardColor, // Set background color to match bottom sections
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
                    user != null ? user!.fullName : '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: defaultTextColor,
                    ),
                  ),
                  Text(
                    user != null ? '@${user!.username}' : '',
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
                    isCelebrity && celeb != null ? celeb.occupation : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nationality', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.nationality : '',
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
                    isCelebrity && celeb?.dob != null 
                        ? DateFormat('MMMM d, y').format(celeb!.dob) // Format as "July 31, 2025"
                        : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Zodiac Sign', // Use ! as celeb is non-null if isCelebrity is true
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.zodiacSign : '',
                    style: TextStyle(color: defaultTextColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: defaultTextColor),
                    onPressed: () {
                      context.pushNamed('settings');
                    },
                  ),
                  Stack(
                    children: [
                      ProfileAvatar(
                        radius: 60,
                        imageUrl: user != null ? user!.profileImageUrl : null,
                      ),
                      if (isCelebrity) ...[
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Icon(Icons.verified,
                              color: Colors.orange.shade700, size: 30),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          _getSocialIconPath('Instagram'),
                          height: 30,
                          width: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.public, size: 24, color: Colors.grey);
                          },
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          _getSocialIconPath('Facebook'),
                          height: 30,
                          width: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.public, size: 24, color: Colors.grey);
                          },
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          _getSocialIconPath('TikTok'),
                          height: 30,
                          width: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.public, size: 24, color: Colors.grey);
                          },
                        ),
                      ],
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
            isCelebrity && celeb != null ? celeb.bio : '',
            style: TextStyle(color: defaultTextColor),
          ),
          GestureDetector(
            onTap: () {
              if (isCelebrity && celeb != null) {
                print(
                    'Website link tapped: ${celeb.website}'); // Corrected string interpolation
              }
            },
            child: Text(
              isCelebrity && celeb != null ? celeb.website : '',
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final localizations = AppLocalizations.of(context)!;
    return Container( // Wrap with Container
      color: Theme.of(context).cardColor, // Set background color to match bottom sections
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (!isOwnProfile)
                  ResizableButton(
                    text: localizations.follow,
                    onPressed: () {
                      if (!(statsLoading || user == null)) {
                        _handleFollowUnfollow();
                      }
                    },
                    width: 100,
                    height: 35,
                  ),
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
      ),
    );
  }

  Widget _buildStatsRow(Color defaultTextColor, Color secondaryTextColor) {
    final localizations = AppLocalizations.of(context)!; // Corrected typo here
    int followers = 0;
    if (user is CelebrityUser) {
      followers = (user as CelebrityUser).followers;
    }
    return Container( // Wrap with Container
      color: Theme.of(context).cardColor, // Set background color to match bottom sections
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user != null ? '${formatCount(followers)} ' : '0 ',
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
              user != null && user!.postsList != null
                  ? '${user!.postsList!.length} '
                  : '0 ',
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
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final localizations = AppLocalizations.of(context)!;
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: const Color(0xFFD6AF0C),
      unselectedLabelColor:
      isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle:
      const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: const Color(0xFFD6AF0C),
        ),
        insets: EdgeInsets.zero,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      tabs: [
        const Tab(text: 'Celebrations'),
        Tab(text: localizations.personalTab),
        Tab(text: localizations.wealthTab),
        Tab(text: localizations.careerTab),
        Tab(text: localizations.publicPersonaTab),
        const Tab(text: 'Fun & Niche'), // New Tab
      ],
    );
  }

  Widget _buildTabs() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPostsTab(), // Celebrations (renamed from posts)
        _buildPersonalTab(),
        _buildWealthTab(),
        _buildCareerTab(),
        _buildPublicPersonaTab(),
        _buildFunNicheTab(), // New Tab View
      ],
    );
  }

  Widget _buildPostsTab() {
    if (posts.isEmpty) {
      return const Center(child: Text('No celebrations to display.'));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, i) =>
          PostCard(post: posts[i], showFollowButton: false),
    );
  }

  Widget _buildCareerTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.orange[300] : Colors.brown[300];
    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No career data available."));
    }
    final celeb = user as CelebrityUser;
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
        ),
        ElevatedButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddCareerHighlightsModal(
                onAdd: (item) {
                  // TODO: Add logic to update data
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD6AF0C),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add Career Highlights',

            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 10), // Add some padding at the bottom
      ],
    );
  }

  Widget _buildWealthTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No wealth data available."));
    }
    final celeb = user as CelebrityUser;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizedCategory,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: defaultTextColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFFD6AF0C)),
                        tooltip: 'Add Wealth',
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddWealthItemModal(
                              sectionTitle: localizedCategory,
                              onAdd: (item) {
                                // TODO: Add logic to update data
                              },
                            ),
                          );
                        },
                      ),
                    ],
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
                            onTap: () {
                              _showItemPopupModal(
                                context: context,
                                imageUrl: item['imageUrl'],
                                title: item['title']!,
                                description: item['description']!,
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

  String _getSocialIconPath(String title) {
    // All social media icons are PNGs
    return 'assets/icons/socials/${title.toLowerCase()}.png';
  }

  Future<void> _launchSocialLink(String url) async {
    try {
      // await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No public persona data available."));
    }
    final celeb = user as CelebrityUser;

    // Dummy data for Public Persona sections (MODIFIED with image URLs)
    final Map<String, List<Map<String, String>>> publicPersonaData = {
      'Social Media Presence': [
        {'platform': 'Instagram', 'followers': '15M', 'link': 'https://instagram.com/celeba'},
        {'platform': 'TikTok', 'followers': '10M', 'link': 'https://tiktok.com/@celeba'},
      ],
      'Public Image / Reputation': [
        {'title': 'Philanthropic Work', 'description': 'Known for extensive charity work and advocacy.'},
        {'title': 'Role Model', 'description': 'Considered a positive role model by many fans.'},
      ],
      'Fashion Style': [
        {'title': 'Casual Chic', 'description': 'Known for casual yet chic street style, often incorporating vintage pieces.', 'imageUrl': 'https://i.ibb.co/T4X16yR/fashion-style1.jpg'},
        {'title': 'Ethereal Gowns', 'description': 'Often seen in flowing, ethereal gowns at events, emphasizing grace and movement.', 'imageUrl': 'https://i.ibb.co/K2sY5sP/fashion-style2.jpg'},
        {'title': 'Bohemian Edge', 'description': 'Combines bohemian elements with a modern, edgy twist, creating unique looks.', 'imageUrl': 'https://i.ibb.co/2d11VpX/fashion-style3.jpg'},
      ],
      'Red Carpet Moments': [
        {'title': 'Met Gala 2023', 'description': 'Stunning custom gown by designer X, widely praised for its innovative design.', 'imageUrl': 'https://i.ibb.co/N73yB9c/red-carpet1.jpg'},
        {'title': 'Oscars 2024', 'description': 'Epitome of elegance in a classic black tuxedo, breaking traditional gender norms.', 'imageUrl': 'https://i.ibb.co/y4L2k2n/red-carpet2.jpg'},
        {'title': 'Cannes Film Festival', 'description': 'Wore a shimmering silver dress that captured international attention for its bold silhouette.', 'imageUrl': 'https://i.ibb.co/C0f11Kk/red-carpet3.jpg'},
      ],
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
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.socialMediaPresence,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            ... (publicPersonaData['Social Media Presence'] ?? []).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Image.asset(
                      _getSocialIconPath(item['platform']!),
                      height: 30,
                      width: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.public, size: 24, color: Colors.grey);
                      },
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['platform']}: ${item['followers']}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: defaultTextColor),
                        ),
                        if (item['link'] != null)
                          GestureDetector(
                            onTap: () => _launchSocialLink(item['link']!),
                            child: Text(
                              item['link']!,
                              style: const TextStyle(
                                  color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            // Public Image / Reputation
            _buildSectionHeader(
                AppLocalizations.of(context)!.publicImageReputation,
                Icons.stars,
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.publicImageReputation,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            ... (publicPersonaData['Public Image / Reputation'] ?? []).map((item) {
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
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.fashionStyle,
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
                itemCount: (publicPersonaData['Fashion Style'] ?? []).length,
                itemBuilder: (context, index) {
                  final item = publicPersonaData['Fashion Style']![index];
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

            // Red Carpet Moments (MODIFIED to horizontal list with images)
            _buildSectionHeader(
                AppLocalizations.of(context)!.redCarpetMoments,
                Icons.movie_filter,
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.redCarpetMoments,
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
                itemCount: (publicPersonaData['Red Carpet Moments'] ?? []).length,
                itemBuilder: (context, index) {
                  final item = publicPersonaData['Red Carpet Moments']![index];
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

            // Quotes or Public Statements
            _buildSectionHeader(
                AppLocalizations.of(context)!.quotesPublicStatements,
                Icons.format_quote,
                defaultTextColor,
                    () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.quotesPublicStatements,
                      onAdd: (item) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  );
                }),
            ... (publicPersonaData['Quotes or Public Statements'] ?? []).map((item) {
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

  Widget _buildPersonalTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No personal data available."));
    }
    final celeb = user as CelebrityUser;
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
                  Color(0xFFD6AF0C),
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddRelationshipModal(
                        sectionTitle: AppLocalizations.of(context)!.family,
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                        },
                      ),
                    );
                  }),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.familyMembers.length,
                  itemBuilder: (context, index) {
                    final family = celeb.familyMembers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _showProfilePreviewModal(
                            context: context,
                            userName: family['name'], // Replace with actual name if available
                            userProfession: family['name'], // Replace with actual relationship type if available
                            userProfileImageUrl: family['imageUrl'],
                            onViewProfile: () {
                              // Add navigation to profile view here
                            },
                          );
                        },
                        child: ProfileAvatar(
                          radius: 30,
                          imageUrl: family['imageUrl'],
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
                  Color(0xFFD6AF0C),
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddRelationshipModal(
                        sectionTitle: AppLocalizations.of(context)!.relationships,
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                        },
                      ),
                    );
                  }),
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
                            userProfession: relationship['type'], // Replace with actual relationship type if available
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
                  Color(0xFFD6AF0C),
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddFunNicheModal(
                        sectionTitle: AppLocalizations.of(context)!.pets,
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                        },
                      ),
                    );
                  }),
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
                            userProfession: pet['type']!,
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
                  Color(0xFFD6AF0C),
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddEducationModal(
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                        },
                      ),
                    );
                  }),
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
                  Color(0xFFD6AF0C),
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddFunNicheModal(
                        sectionTitle: AppLocalizations.of(context)!.hobbies,
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                        },
                      ),
                    );
                  }),
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
                            imageUrl: celeb.hobbies[index]['imageUrl'],
                            title: celeb.hobbies[index]['name']!,
                            description: celeb.hobbies[index]['description'] ?? '', // Assuming description may be empty
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
                  defaultTextColor,
                      () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddPersonaModal(
                        sectionTitle: AppLocalizations.of(context)!.involvedCauses,
                        onAdd: (item) {
                          // TODO: Add logic to update dummy data
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.involvedCauses,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFFD6AF0C)),
                    tooltip: 'Add Involved Causes',
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        isDismissible: true,
                        enableDrag: true,
                        useSafeArea: true,
                        builder: (context) => PopScope(
                          canPop: true,
                          onPopInvoked: (didPop) {
                            if (!didPop) {
                              Navigator.pop(context);
                            }
                          },
                          child: AddPersonaModal(
                            sectionTitle: AppLocalizations.of(context)!.involvedCauses,
                            onAdd: (cause) {
                              // TODO: Add logic to update dummy data
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
                        // Icon here if needed
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

  Widget _buildFunNicheTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No fun & niche data available."));
    }
    final celeb = user as CelebrityUser;

    // Dummy data for Fun or Niche Details sections (MODIFIED with image URLs)

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
                itemCount: celeb.tattoos.length,
                itemBuilder: (context, index) {
                  final tattoo = celeb.tattoos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: tattoo['imageUrl'],
                          title: tattoo['name'],
                          description: tattoo['description'],
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
                itemCount: celeb.favouriteThings.length,
                itemBuilder: (context, index) {
                  final item = celeb.favouriteThings[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title:item['item'],
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
                itemCount: celeb.talents.length,
                itemBuilder: (context, index) {
                  final item = celeb.talents[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showItemPopupModal(
                          context: context,
                          imageUrl: item['imageUrl'],
                          title: item['name'],
                          description: item['name'],
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
}
