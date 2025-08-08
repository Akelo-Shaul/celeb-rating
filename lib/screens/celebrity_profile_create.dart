import 'package:celebrating/l10n/app_localizations.dart';
import 'package:celebrating/services/feed_service.dart';
import 'package:celebrating/models/user.dart';
import 'package:celebrating/widgets/add_persona_modal.dart';
import 'package:celebrating/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:celebrating/widgets/add_wealth_item_modal.dart';

import '../widgets/add_education_modal.dart';
import '../widgets/add_relationship_modal.dart';
import '../widgets/app_text_fields.dart';
import '../widgets/app_date_picker.dart';

class CelebrityProfileCreate extends StatefulWidget {
  const CelebrityProfileCreate({super.key});

  @override
  State<CelebrityProfileCreate> createState() => _CelebrityProfileCreateState();
}

class _CelebrityProfileCreateState extends State<CelebrityProfileCreate> {
  int _currentIndex = 0;

  // Celebrity fields list
  final List<String> _celebrityFields = [
    'Music',
    'Football',
    'Basketball',
    'Acting',
    'Comedy',
    'Art',
    'Fashion',
    'Politics',
    'Business',
    'Technology'
  ];
  
  String? _selectedCelebrityField;

  // Socials list
  List<Map<String, dynamic>> _socialsList = [];
  bool _isAddingSocial = false;

  // Additions for family search
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';
  bool _isLoadingUsers = false;

  // Education list
  List<Map<String, String>> _educationList = [];

  // For education degrees
  final List<Map<String, String>> _qualifications = [];
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();


  // Add Socials
  // final TextEditingController _socialPlatformController = TextEditingController();
  // final TextEditingController _socialLinkController = TextEditingController();

  // --- Profile Variables ---
  final GlobalKey<FormState> _formKeyUpdateProfile = GlobalKey<FormState>();
  String? _updateStageName;
  String? _updateSign;
  String? _updateSpirituality;
  String? _updateNetWorth;
  String? _updateCelebrityField;
  bool _isSubmitting = false;

  void _submitUpdates() async {
    if (!_formKeyUpdateProfile.currentState!.validate()) return;
    _formKeyUpdateProfile.currentState!.save();
    setState(() { _isSubmitting = true; });
    // Simulate a network call or save logic
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isSubmitting = false; });
    _goToNextTab();
    // Removed snackbar with missing localization key
  }

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
    final users = <String, User>{};
    for (var post in posts) {
      users[post.from.id ?? ''] = post.from;
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
      // There are 6 steps: 0,1,2,3,4,5 (3 is skipped in build)
      if (_currentIndex < 5) {
        _currentIndex++;
      }
    });
  }

  void _goToPreviousTab() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFD6AF0C);
    final textColorLight = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? textColor;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_currentIndex == 0)
              _celebrateYou(),
            if (_currentIndex == 1)
              Column(
                children: [
                  Expanded(child: _updateProfile()),
                  // Profile summary
                  if (_updateStageName != null || _updateSign != null || _updateSpirituality != null || _updateNetWorth != null)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(AppLocalizations.of(context)!.updateProfile),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_updateStageName != null && _updateStageName!.isNotEmpty)
                              Text('${AppLocalizations.of(context)!.stageName}: $_updateStageName'),
                            if (_updateSign != null && _updateSign!.isNotEmpty)
                              Text('${AppLocalizations.of(context)!.zodiacSign}: $_updateSign'),
                            if (_updateSpirituality != null && _updateSpirituality!.isNotEmpty)
                              Text('${AppLocalizations.of(context)!.spirituality}: $_updateSpirituality'),
                            if (_updateNetWorth != null && _updateNetWorth!.isNotEmpty)
                              Text('${AppLocalizations.of(context)!.netWorth}: $_updateNetWorth'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            if (_currentIndex == 2)
              Column(
                children: [
                  Expanded(child: _addSocials()),
                  // Family summary (example, you may want to store added family in state)
                  // if (_addedFamily.isNotEmpty) ...
                ],
              ),
            if (_currentIndex == 3)
              Column(
                children: [
                  Expanded(child: _addFamily()),
                  // Family summary (example, you may want to store added family in state)
                  // if (_addedFamily.isNotEmpty) ...
                ],
              ),
            if (_currentIndex == 4)
              Column(
                children: [
                  Expanded(child: _addWealth()),
                  // Wealth summary (example, you may want to store added wealth in state)
                  // if (_addedWealth.isNotEmpty) ...
                ],
              ),
            if (_currentIndex == 5)
              Column(
                children: [
                  Expanded(child: _addEducation()),
                  if (_qualifications.isNotEmpty)
                    SizedBox.shrink(),
                ],
              ),
            if (_currentIndex == 6)
              Column(
                children: [
                  Expanded(child: _addSocials()),
                  if (_socialsList.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Added Social Media',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _socialsList.length,
                              itemBuilder: (context, index) {
                                final social = _socialsList[index];
                                return ListTile(
                                  leading: const Icon(Icons.link),
                                  title: Text(social['platform'] ?? ''),
                                  subtitle: Text(social['link'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _socialsList.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          ..._qualifications.map((deg) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.school),
                              title: Text(
                                '${deg['university']} (${deg['year']})',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                              ),
                              subtitle: Text(
                                deg['degree'] ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                ],
              ),
            // Progress indicator row remains here
            PositionedDirectional(
              bottom: 10,
              start: 0,
              end: 0,
              child: Container(
                padding: const EdgeInsetsDirectional.only(start: 30, end: 30, bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
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

  Widget _updateProfile(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKeyUpdateProfile,
              child: ListView(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context)!.updateProfile,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text('Update your profile information', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.stageName,
                      prefixIcon: Icon(Icons.mic),
                    ),
                    onSaved: (v) => _updateStageName = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.zodiacSign,
                      prefixIcon: Icon(Icons.assignment_ind_outlined),
                    ),
                    onSaved: (v) => _updateSign = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.celebrityField,
                      prefixIcon: Icon(Icons.military_tech),
                    ),
                    onSaved: (v) => _updateCelebrityField = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.spirituality,
                      prefixIcon: Icon(Icons.back_hand_outlined),
                    ),
                    onSaved: (v) => _updateSpirituality = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.netWorth,
                      prefixIcon: Icon(Icons.money),
                    ),
                    onSaved: (v) => _updateNetWorth = v,
                  ),
                ],
              ),
            ),
          ),
          _BottomActions(
            mainButton: AppButton(
              text: AppLocalizations.of(context)!.submit,
              isLoading: _isSubmitting,
              onPressed: _submitUpdates,
            ),
            secondaryButton: AppTextButton(
              text: AppLocalizations.of(context)!.skip,
              onPressed: _goToNextTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addSocials() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Add Social Media',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Add your social media platforms and links.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _BottomActions(
            mainButton: AppButton(
              text: AppLocalizations.of(context)!.addManually,
              icon: Icons.group_add,
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddPersonaModal(
                    sectionTitle: AppLocalizations.of(context)!.socials,
                    sectionType: 'Social Media Presence',
                    onAdd: (social) {
                      // TODO: Add logic to update dummy data
                    },
                  ),
                );
                if (result != null) {
                  // Optionally update your state with the new member
                }
              },
            ),
            secondaryButton: AppTextButton(
              text: AppLocalizations.of(context)!.skip,
              onPressed: _goToNextTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFamily() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
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
                    : (_searchQuery.isEmpty
                    ? const SizedBox.shrink()
                    : _filteredUsers.isEmpty
                    ? ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                )
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          _BottomActions(
            mainButton: AppButton(
              text: AppLocalizations.of(context)!.addManually,
              icon: Icons.group_add,
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddRelationshipModal(
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
            secondaryButton: AppTextButton(
              text: AppLocalizations.of(context)!.skip,
              onPressed: _goToNextTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addWealth() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
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
              ],
            ),
          ),
          _BottomActions(
            mainButton: AppButton(
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
                    }, sectionType: '',
                  ),
                );
                if (result != null) {
                  // Optionally update your state with the new wealth item
                }
              },
            ),
            secondaryButton: AppTextButton(
              text: AppLocalizations.of(context)!.skip,
              onPressed: _goToNextTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addEducation() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? textColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.addEducation,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Add Education Information', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _institutionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.certifyingInstitution,
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterUniversity : null,
                ),
                // Replace custom AppTextFormField with standard TextFormField
                const SizedBox(height: 14),

                TextFormField(
                  controller: _qualificationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.qualificationLabel,
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterDegree : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.yearOfCompletion,
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await CustomDatePicker.show(context);
                    if (picked != null) {
                      setState(() {
                        _yearController.text = picked.year.toString();
                      });
                    }
                  },
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterYear : null,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: AppLocalizations.of(context)!.addEducation,
                  icon: Icons.add,
                  onPressed: () {
                    final degree = _qualificationController.text.trim();
                    final institution = _institutionController.text.trim();
                    final year = _yearController.text.trim();
                    if (degree.isEmpty || institution.isEmpty || year.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFieldsToAddQualification)),
                      );
                      return;
                    }
                    setState(() {
                      _qualifications.add({
                        'degree': degree,
                        'institution': institution,
                        'year': year,
                      });
                      _qualificationController.clear();
                      _institutionController.clear();
                      _yearController.clear();
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (_qualifications.isNotEmpty)
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
                        ..._qualifications.map((deg) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.school),
                            title: Text(
                              '${deg['institution']} (${deg['year']})',
                              style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                            ),
                            subtitle: Text(
                              deg['degree'] ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _BottomActions(
            secondaryButton: AppTextButton(
              text: AppLocalizations.of(context)!.finish,
              onPressed: () {
                context.goNamed('feed');
              },
            ), mainButton: null,
          ),
        ],
      ),
    );
  }


}

class _BottomActions extends StatelessWidget {
  final Widget? mainButton;
  final Widget? secondaryButton;
  const _BottomActions({required this.mainButton, this.secondaryButton});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?mainButton,
            if (secondaryButton != null) ...[
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: secondaryButton!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}