import 'package:celebrating/widgets/add_career_higlights_modal.dart';
import 'package:celebrating/widgets/add_wealth_item_modal.dart';
import 'package:celebrating/widgets/slideup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../widgets/add_education_modal.dart';
import '../widgets/add_persona_modal.dart';
import '../widgets/add_relationship_modal.dart';
import '../widgets/app_buttons.dart';
import '../widgets/comments_modal.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/image_optional_text.dart';

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
  List<Post> posts = [];
  bool isLoading = true;

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

  //TODO: Implement following code block when fetching logged in user
  /*** void fetchProfileUser() async {
      // If your User model has a role or type field:
      bool isCelebrity = loggedInUser.role == 'Celebrity';

      final user = await UserService.fetchUser(loggedInUser.id.toString(), isCelebrity: isCelebrity);

      setState(() {
      if (isCelebrity && user is CelebrityUser) {
      this.user = user;
      } else if (!isCelebrity && user is User) {
      this.user = user as User;
      }
      });
      } **/

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

  void _showProfilePreviewModal({
    required BuildContext context,
    required String userName,
    required String userProfession,
    String? userProfileImageUrl,
    VoidCallback? onViewProfile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
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

  @override
  void initState() {
    super.initState();
    // Call the method to fetch a celebrity user
    fetchProfileUser();
    _tabController = TabController(length: 5, vsync: this);
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
    // Removed unused appPrimaryColor here as it's not directly used in the Scaffold/AppBar
    final tabBackgroundColor =
    isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      // appBar: _buildAppBar(defaultTextColor), // Re-enable if you want an AppBar
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(defaultTextColor, secondaryTextColor),
            _buildActionButtons(),
            const SizedBox(height: 8,),
            _buildStatsRow(defaultTextColor, secondaryTextColor),
            _buildTabBar(isDark),
            Expanded(child: _buildTabs()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color defaultTextColor, Color secondaryTextColor) {
    final isCelebrity = user is CelebrityUser;
    final celeb = isCelebrity ? user as CelebrityUser : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null ? user!.fullName : '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  Text(
                    user != null ? user!.username : '',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCelebrity && celeb != null ? celeb.occupation : '',
                    style: TextStyle(color: defaultTextColor),
                  ),
                  Text(
                    isCelebrity && celeb != null ? celeb.nationality : '',
                    style: TextStyle(color: secondaryTextColor),
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
                        Icon(Icons.tiktok, size: 30, color: secondaryTextColor),
                        const SizedBox(width: 12),
                        Icon(Icons.camera_alt_outlined,
                            size: 30, color: secondaryTextColor),
                        const SizedBox(width: 12),
                        Icon(Icons.tiktok, size: 30, color: secondaryTextColor),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Padding(
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
    );
  }

  Widget _buildStatsRow(Color defaultTextColor, Color secondaryTextColor) {
    final localizations = AppLocalizations.of(context)!;
    int followers = 0;
    if (user is CelebrityUser) {
      followers = (user as CelebrityUser).followers;
    }
    return Padding(
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
                            color: Colors.orange),
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
                            onTapDown: (details) {},
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

  Widget _buildSocialIcons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final appPrimaryColor = Theme.of(context).primaryColor;
    if (user == null || user is! CelebrityUser) return const SizedBox.shrink();
    final celeb = user as CelebrityUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Socials Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.socials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: defaultTextColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: const Color(0xFFD6AF0C)),
              tooltip: 'Add Social',
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => WillPopScope(
                    onWillPop: () async => true,
                    child: AddPersonaModal(
                      sectionTitle: AppLocalizations.of(context)!.socials,
                      onAdd: (social) {
                        // TODO: Add logic to update dummy data
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                      _launchSocialLink(social['link']);
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

  Widget _buildPersonalTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor =
    isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No personal data available."));
    }
    final celeb = user as CelebrityUser;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign
              Text(
                '${AppLocalizations.of(context)!.zodiacSign}: ${celeb.zodiacSign}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 20),
              // Relationships Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family and relationships',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Relationship',
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
                          child: AddRelationshipModal(
                            onAdd: (relationship) {
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
                          if (user != null) {
                            _showProfilePreviewModal(
                              context: context,
                              userName: user!.fullName,
                              userProfession: user is CelebrityUser
                                  ? (user as CelebrityUser).occupation
                                  : '',
                              userProfileImageUrl: user!.profileImageUrl,
                              onViewProfile: () {
                                // Optionally handle view profile action
                              },
                            );
                          }
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

              // Education Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.education,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Education',
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
                          child: AddEducationModal(
                            onAdd: (education) {
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
              ...celeb.educationEntries.map((entry) {
                final university = entry['university'] ?? '';
                final degrees = (entry['degrees'] as List?)
                    ?.cast<Map<String, String>>() ??
                    [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row( // This is the main Row for the icon and text content
                    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the top
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school_outlined,
                            size: 35,
                            color: const Color(0xFFD6AF0C)),
                      ),
                      const SizedBox(width: 12), // Add spacing between icon and text
                      Expanded( // This Expanded widget ensures the text content takes up remaining space
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 2.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                            padding:
                                            const EdgeInsets.only(top: 2.0),
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

              // Hobbies Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hobbies,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Hobby',
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
                            sectionTitle: AppLocalizations.of(context)!.hobbies,
                            onAdd: (hobby) {
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
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.hobbies.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {},
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
              Text(
                AppLocalizations.of(context)!.lifestyle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: defaultTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Diet: ${celeb.diet}',
                style: TextStyle(fontSize: 14, color: defaultTextColor),
              ),
              Text(
                'Spirituality: ${celeb.spirituality}',
                style: TextStyle(fontSize: 14, color: defaultTextColor),
              ),
              const SizedBox(height: 20),

              // Involved Causes Section

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
                        color: const Color(0xFFD6AF0C)),
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
                            sectionTitle:
                            AppLocalizations.of(context)!.involvedCauses,
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

              // Pets Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pets,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Pet',
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
                          child: AddRelationshipModal(
                            sectionTitle: AppLocalizations.of(context)!.pets,
                            onAdd: (pet) {
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
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.pets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {},
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

              // Tattoos Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.tattoos,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Tattoo',
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
                            sectionTitle: AppLocalizations.of(context)!.tattoos,
                            onAdd: (tattoo) {
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
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.tattoos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {},
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

              // Favourites Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.favourites,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Favourite Place',
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
                            sectionTitle:
                            AppLocalizations.of(context)!.favourites,
                            onAdd: (place) {
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
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.favouritePlaces.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {},
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.talents,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: const Color(0xFFD6AF0C)),
                    tooltip: 'Add Talent',
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
                            sectionTitle: AppLocalizations.of(context)!.talents,
                            onAdd: (talent) {
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
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: celeb.talents.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTapDown: (details) {},
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

  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final appPrimaryColor = Theme.of(context).primaryColor;
    if (user == null || user is! CelebrityUser) {
      return const Center(child: Text("No public persona data available."));
    }
    final celeb = user as CelebrityUser;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Social Media Icons
            _buildSocialIcons(),
            const SizedBox(height: 20),
            Text(
              celeb.publicImageDescription,
              style: TextStyle(
                fontSize: 14,
                color: defaultTextColor,
              ),
            ),
            const SizedBox(height: 20),

            // Controversies Section
            Text(
              AppLocalizations.of(context)!.controversies,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: defaultTextColor,
              ),
            ),
            const SizedBox(height: 10),
            if (celeb.controversyMedia.isNotEmpty)
              _ControversyCarousel(
                controversyMedia: celeb.controversyMedia,
                defaultTextColor: defaultTextColor,
                cardColor: Theme.of(context).cardColor,
              )
            else
              const Center(child: Text("No controversies to display.")),
            const SizedBox(height: 20),

            // Fashion Style Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.fashionStyle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: const Color(0xFFD6AF0C)),
                  tooltip: 'Add Fashion Style',
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => true,
                        child: AddPersonaModal(
                          sectionTitle:
                          AppLocalizations.of(context)!.fashionStyle,
                          onAdd: (fashion) {
                            // TODO: Add logic to update dummy data
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10), // Spacing after Fashion Style title/button
            // Fashion Style Images
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

            // Fan Theories & Interactions Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle button tap
                  print('Fan Theories & Interactions tapped');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
            const SizedBox(height: 10), // Add some padding at the bottom
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
    final Color _defaultTextColor = defaultTextColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);
    final Color _secondaryTextColor = secondaryTextColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600);
    final Color _appPrimaryColor =
        appPrimaryColor ?? Theme.of(context).primaryColor;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileAvatar(
                radius: 30,
                imageUrl: userProfileImageUrl ?? 'https://via.placeholder.com/150'),
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
                      const Icon(Icons.verified, color: Colors.orange, size: 18),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      _currentIndex = (_currentIndex - 1 + widget.controversyMedia.length) %
          widget.controversyMedia.length;
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
    const double cardWidth = 120;
    const double cardHeight = 100;
    const double spacing = 8;

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
            ? Center(
            child: Icon(Icons.play_circle_fill,
                size: 50, color: Colors.grey[400])) // Adjusted icon color
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
              buildMediaBox(media[0].toString(),
                  isVideo: media[0].toString().endsWith('.mp4')),
              const SizedBox(width: spacing),
              buildMediaBox(media[1].toString(),
                  isVideo: media[1].toString().endsWith('.mp4')),
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
                  buildMediaBox(media[0].toString(),
                      isVideo: media[0].toString().endsWith('.mp4')),
                  const SizedBox(height: spacing),
                  buildMediaBox(media[1].toString(),
                      isVideo: media[1].toString().endsWith('.mp4')),
                ],
              ),
              const SizedBox(width: spacing),
              // Right column (one media, full height)
              // Ensure this Container correctly wraps the media box and fits its content
              SizedBox(
                width: cardWidth,
                height: cardHeight * 2 + spacing,
                child: buildMediaBox(media[2].toString(),
                    isVideo: media[2].toString().endsWith('.mp4')),
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
          style: TextStyle(
              fontSize: 14,
              color: widget.defaultTextColor,
              fontWeight: FontWeight.w600),
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