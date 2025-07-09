import 'package:celebrating/l10n/app_localizations.dart';
import 'package:celebrating/services/feed_service.dart';
import 'package:celebrating/models/user.dart';
import 'package:celebrating/utils/route.dart';
import 'package:celebrating/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:celebrating/widgets/add_family_member_modal.dart';
import 'package:celebrating/widgets/add_wealth_item_modal.dart';

import '../widgets/app_text_fields.dart';

class CelebrityProfileCreate extends StatefulWidget {
  const CelebrityProfileCreate({super.key});

  @override
  State<CelebrityProfileCreate> createState() => _CelebrityProfileCreateState();
}

class _CelebrityProfileCreateState extends State<CelebrityProfileCreate> {
  int _currentIndex = 0;

  // Additions for family search
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';
  bool _isLoadingUsers = false;

  // Education list
  List<Map<String, String>> _educationList = [];

  // For education degrees
  final List<Map<String, String>> _degrees = [];
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add timeout to auto-advance from _celebrateYou to _addFamily
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentIndex == 0) {
        setState(() {
          _currentIndex = 1;
        });
      }
    });
    _fetchDummyUsers();
  }

  void _fetchDummyUsers() async {
    setState(() { _isLoadingUsers = true; });
    final posts = FeedService.generateDummyPosts();
    // Extract unique users from posts
    final users = <int, User>{};
    for (var post in posts) {
      users[post.from.id ?? 0] = post.from;
    }
    setState(() {
      _allUsers = users.values.toList();
      _filteredUsers = _allUsers;
      _isLoadingUsers = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _allUsers.where((user) {
        final q = query.toLowerCase();
        return user.fullName.toLowerCase().contains(q) || user.username.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _goToNextTab() {
    setState(() {
      if (_currentIndex < 3) {
        _currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFD6AF0C);
    final textColorLight = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_currentIndex == 0)
              _celebrateYou(),
            if (_currentIndex == 1)
              _addFamily(),
            if (_currentIndex == 2)
              _addWealth(),
            if (_currentIndex == 3)
              _addEducation(),
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Container(
                padding: const EdgeInsetsDirectional.only(start: 30, end: 30, bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return _currentIndex == index
                        ? Container(
                      margin: const EdgeInsetsDirectional.all(10),
                      padding: const EdgeInsetsDirectional.all(10),
                      height: 10,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: primaryColor,
                        border: Border.all(color: primaryColor),
                      ),
                    )
                        : Container(
                      margin: const EdgeInsetsDirectional.all(10),
                      padding: const EdgeInsetsDirectional.all(10),
                      height: 10,
                      width: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: textColorLight,
                        border: Border.all(color: textColorLight),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _celebrateYou() {
    return Stack(
      children:[
        Positioned.fill(
          child: Lottie.asset(
            'assets/animations/celebrating.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.celebrateYou,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.welcomeAudienceAwaits),
              const SizedBox(height: 40),
            ],
          ),
        )
      ],
    );
  }

  Widget _addFamily() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.addFamily,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.searchAndAddFamily, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByNameOrUsername,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _onSearchChanged,
            ),

            const SizedBox(height: 8),
            _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _searchQuery.isEmpty
                        ? const SizedBox.shrink() // Don't show any list until user types
                        : _filteredUsers.isEmpty
                            ? ListView(
                                children: [
                                  ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.person_add)),
                                    title: Text(_searchQuery),
                                    subtitle: Text(AppLocalizations.of(context)!.notFound),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(AppLocalizations.of(context)!.inviteSent(_searchQuery))),
                                        );
                                      },
                                      child: Text(AppLocalizations.of(context)!.invite),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user.profileImageUrl != null
                                          ? NetworkImage(user.profileImageUrl!)
                                          : null,
                                      child: user.profileImageUrl == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(user.fullName),
                                    subtitle: Text('@${user.username}'),
                                    trailing: SizedBox(
                                      width: 110,
                                      child: AppButton(
                                        text: AppLocalizations.of(context)!.add,
                                        icon: Icons.person_add,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(AppLocalizations.of(context)!.addedFamilyMember(user.fullName))),
                                          );
                                        },
                                        backgroundColor: const Color(0xFFD6AF0C),
                                        textColor: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
            const SizedBox(height: 8),
            AppButton(
              text: AppLocalizations.of(context)!.addManually,
              icon: Icons.group_add,
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddFamilyMemberModal(
                    onAdd: (member) {
                      Navigator.of(context).pop(member);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.addedFamilyMember(member['fullName']))),
                      );
                    },
                  ),
                );
                if (result != null) {
                  // Optionally update your state with the new member
                }
              },
            ),
            const SizedBox(height: 50),

            Align(
              alignment: Alignment.bottomRight,
              child: AppTextButton(
                text: AppLocalizations.of(context)!.skip,
                onPressed: () {
                  _goToNextTab();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addWealth() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.addWealth,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.addWealthInfo, textAlign: TextAlign.center),

            const SizedBox(height: 8),
            const Spacer(),
            const SizedBox(height: 8),
            AppButton(
              text: AppLocalizations.of(context)!.addManually,
              icon: Icons.group_add,
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddWealthItemModal(
                    onAdd: (item) {
                      Navigator.of(context).pop(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.addedWealthItem(item['name']))),
                      );
                    },
                  ),
                );
                if (result != null) {
                  // Optionally update your state with the new wealth item
                }
              },
            ),
            const SizedBox(height: 50),

            Align(
              alignment: Alignment.bottomRight,
              child: AppTextButton(
                text: AppLocalizations.of(context)!.skip,
                onPressed: () {
                  _goToNextTab();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addEducation() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? textColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.addEducation,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.addEducationInfo, textAlign: TextAlign.center),

            const SizedBox(height: 8),
            const SizedBox(height: 24),
            AppTextFormField(
              controller: _degreeController,
              labelText: AppLocalizations.of(context)!.degreeLabel,
              icon: Icons.school,
              validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterDegree : null,
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _universityController,
              labelText: AppLocalizations.of(context)!.certifyingUniversity,
              icon: Icons.account_balance,
              validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterUniversity : null,
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              controller: _yearController,
              labelText: AppLocalizations.of(context)!.yearOfCompletion,
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterYear : null,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: AppLocalizations.of(context)!.addDegree,
              icon: Icons.add,
              onPressed: () {
                final degree = _degreeController.text.trim();
                final university = _universityController.text.trim();
                final year = _yearController.text.trim();
                if (degree.isEmpty || university.isEmpty || year.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFieldsToAddDegree)),
                  );
                  return;
                }
                setState(() {
                  _degrees.add({
                    'degree': degree,
                    'university': university,
                    'year': year,
                  });
                  _degreeController.clear();
                  _universityController.clear();
                  _yearController.clear();
                });
              },
            ),
            const SizedBox(height: 24),
            if (_degrees.isNotEmpty)
              SizedBox(
                height: 220, // Adjust height as needed
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.addedDegrees,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._degrees.map((deg) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(
                          deg['degree'] ?? '',
                          style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
                        ),
                        subtitle: Text(
                          '${deg['university']} (${deg['year']})',
                          style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            const Spacer(),
            const SizedBox(height: 50),

            Align(
              alignment: Alignment.bottomRight,
              child: AppTextButton(
                text: AppLocalizations.of(context)!.finish,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, feedScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}