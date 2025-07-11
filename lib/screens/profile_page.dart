import 'package:celebrating/widgets/slideup_dialog.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../widgets/app_buttons.dart';
import '../widgets/post_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/image_optional_text.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  CelebrityUser? user;
  List<Post> posts = [];
  bool isLoading = true;

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
    final fetchedUser = await UserService.fetchUser('456', isCelebrity: true);
    if (fetchedUser is CelebrityUser) {
      setState(() {
        user = fetchedUser;
        posts = fetchedUser.postsList ?? [];
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = Theme.of(context).primaryColor;
    final tabBackgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      appBar: _buildAppBar(defaultTextColor),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(defaultTextColor, secondaryTextColor),
                _buildActionButtons(),
                _buildStatsRow(defaultTextColor, secondaryTextColor),
                _buildTabBar(isDark),
                Expanded(child: _buildTabs()),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color defaultTextColor) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: defaultTextColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: defaultTextColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader(Color defaultTextColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user!.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                Text(
                  user!.username,
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user!.occupation,
                  style: TextStyle(color: defaultTextColor),
                ),
                Text(
                  user!.nationality,
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
            SizedBox(
              height: 120 + 14 + 5,
              width: 120,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: ProfileAvatar(
                      radius: 60,
                      imageUrl: user!.profileImageUrl,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: const Icon(Icons.verified, color:  const Color(0xFFD6AF0C), size: 30),
                  ),
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tiktok, size: 30, color: secondaryTextColor),
                          const SizedBox(width: 12),
                          Icon(Icons.camera_alt_outlined, size: 30, color: secondaryTextColor),
                          const SizedBox(width: 12),
                          Icon(Icons.tiktok, size: 30, color: secondaryTextColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          user!.bio,
          style: TextStyle(color: defaultTextColor),
        ),
        GestureDetector(
          onTap: () {
            print('Website link tapped: \\${user!.website}');
          },
          child: Text(
            user!.website,
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons() {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ResizableButton(
              text: localizations.follow,
              onPressed: () {},
              width: 100,
              height: 35,
            ),
            PostActionButton(
              icon: Icons.comment_outlined,
              onPressed: () {
                print("Routing to messaging");
              },
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
    );
  }

  Widget _buildStatsRow(Color defaultTextColor, Color secondaryTextColor) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            user != null && user!.followers != null ? '${formatCount(user!.followers)} ' : '0 ',
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
            user != null && user!.postsList != null ? '${user!.postsList!.length} ' : '0 ',
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
      labelColor: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF6F00),
      unselectedLabelColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3.0,
          color: isDark ? const Color(0xFFFFA726) : const Color(0xFFFF6F00),
        ),
        insets: EdgeInsets.zero,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      tabs: [
        Tab(text: localizations.postsTab),
        Tab(text: localizations.careerTab),
        Tab(text: localizations.wealthTab),
        Tab(text: localizations.personalTab),
        Tab(text: localizations.publicPersonaTab),
      ],
    );
  }

  Widget _buildTabs(){
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildCareerTab(),
          _buildWealthTab(),
          _buildPersonalTab(),
          _buildPublicPersonaTab()
        ],
      ),
    );
  }

  Widget _buildPostsTab(){
    if (posts.isEmpty) {
      return const Center(child: Text('No posts to display.'));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, i) => PostCard(post: posts[i], showFollowButton: false),
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
    final Map<String, List<Map<String, String>>> careerData = celeb.careerEntries;

    return ListView(
      children: careerData.entries
          .where((entry) => entry.value.isNotEmpty)
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
                    } else {
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
    final celeb = user as CelebrityUser;
    final Map<String, List<Map<String, String>>> wealthData = celeb.wealthEntries;
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
                          child: ImageWithOptionalText(
                            width: 100,
                            height: 150,
                            imageUrl: item['imageUrl'],
                            bottomText: item['name'],
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
    final celeb = user as CelebrityUser;
    return SingleChildScrollView(
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

            // Family Section
            Text(
              AppLocalizations.of(context)!.family,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: defaultTextColor,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: celeb.familyMembers.length,
                itemBuilder: (context, index) {
                  final member = celeb.familyMembers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        _showProfilePreviewModal(
                          context: context,
                          userName: member['name'] ?? '',
                          userProfession: member['relation'] ?? '',
                          userProfileImageUrl: member['imageUrl'] ?? 'https://via.placeholder.com/150',
                          onViewProfile: () {
                            // You can add navigation or more logic here
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      child: Column(
                        children: [
                          ProfileAvatar(
                            radius: 30,
                            imageUrl: member['imageUrl'] ?? 'https://via.placeholder.com/150',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            member['name'] ?? '',
                            style: TextStyle(fontSize: 12, color: defaultTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Relationships Section
            Text(
              AppLocalizations.of(context)!.relationships,
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
                    child: ProfileAvatar(
                      radius: 30,
                      imageUrl: celeb.relationships[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Education Section
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
                          entry['degree'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: defaultTextColor,
                          ),
                        ),
                        Text(
                          entry['university'] ?? '',
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

            // Hobbies Section
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
                    child: ImageWithOptionalText(
                      width: 100,
                      height: 150,
                      imageUrl: celeb.hobbies[index]['imageUrl'],
                      bottomText: celeb.hobbies[index]['name'],
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
                    child: ProfileAvatar(
                      radius: 30,
                      imageUrl: celeb.pets[index],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Tattoos Section
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
                    child: ImageWithOptionalText(
                      width: 100,
                      height: 150,
                      imageUrl: celeb.tattoos[index],
                      bottomText: null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Favourites Section
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.favourites,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Places',
                  icon: Icon(Icons.keyboard_arrow_down, color: secondaryTextColor),
                  underline: const SizedBox(),
                  style: TextStyle(color: secondaryTextColor, fontSize: 14),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: <String>['Places', 'Food', 'Movies', 'Books']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                    child: ImageWithOptionalText(
                      width: 100,
                      height: 150,
                      imageUrl: celeb.favouritePlaces[index]['imageUrl'],
                      bottomText: celeb.favouritePlaces[index]['name'],
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
                    child: ImageWithOptionalText(
                      width: 100,
                      height: 150,
                      imageUrl: celeb.talents[index]['imageUrl'],
                      bottomText: celeb.talents[index]['name'],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicPersonaTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = Theme.of(context).primaryColor;
    final celeb = user as CelebrityUser;

    // Social icon mapping (for demo, you can expand this)
    final Map<String, IconData> socialIcons = {
      'TikTok': Icons.music_note,
      'Reddit': Icons.reddit,
      'Spotify': Icons.music_video,
      'YouTube': Icons.ondemand_video,
      'Snapchat': Icons.chat_bubble_outline,
    };
    final Map<String, Color> socialColors = {
      'TikTok': Colors.black,
      'Reddit': Colors.orange,
      'Spotify': Colors.green,
      'YouTube': Colors.red,
      'Snapchat': Colors.yellow,
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Socials Section
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
                  final icon = socialIcons[social['title']] ?? Icons.link;
                  final color = socialColors[social['title']] ?? appPrimaryColor;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        // Open social['link']
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Public Image Section
            Text(
              AppLocalizations.of(context)!.publicImage,
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
              ),
            const SizedBox(height: 20),

            // Fashion Style Section
            Text(
              AppLocalizations.of(context)!.fashionStyle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: defaultTextColor,
              ),
            ),
            const SizedBox(height: 10),

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

            // Fan Theories & Interactions Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle button tap
                  print('Fan Theories & Interactions tapped');
                },
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
                      Icon(Icons.verified, color: Colors.orange, size: 18),
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
        const Expanded(
          child: SizedBox(),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _defaultTextColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userName,
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
    final cont = widget.controversyMedia[_currentIndex];
    final List media = cont['media'] ?? [];
    final String controversy = cont['controversy'] ?? '';
    final double cardWidth = 120;
    final double cardHeight = 100;
    final double spacing = 8;

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
            ? const Center(child: Icon(Icons.play_circle_fill, size: 50, color: Colors.grey))
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
        final url = media[0];
        final isVideo = url.toString().endsWith('.mp4');
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
              buildMediaBox(media[0], isVideo: media[0].toString().endsWith('.mp4')),
              SizedBox(width: spacing),
              buildMediaBox(media[1], isVideo: media[1].toString().endsWith('.mp4')),
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
                  buildMediaBox(media[0], isVideo: media[0].toString().endsWith('.mp4')),
                  SizedBox(height: spacing),
                  buildMediaBox(media[1], isVideo: media[1].toString().endsWith('.mp4')),
                ],
              ),
              SizedBox(width: spacing),
              // Right column (one media, full height)
              Container(
                width: cardWidth,
                height: cardHeight * 2 + spacing,
                child: buildMediaBox(media[2], isVideo: media[2].toString().endsWith('.mp4')),
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
