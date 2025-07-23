import 'dart:math';

import 'package:celebrating/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/versus_user.dart';
import '../services/search_service.dart';
import '../services/versus_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/search_user_card.dart';


class VersusScreen extends StatefulWidget {
  const VersusScreen({super.key});

  @override
  State<VersusScreen> createState() => _VersusScreenState();
}

class _VersusScreenState extends State<VersusScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<VersusUser> _allUsers = [];
  List<VersusUser> _searchUserResults = [];

  VersusUser? _selectedUser1;
  VersusUser? _selectedUser2;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with dummy users from SearchService, converting User to VersusUser
    _allUsers = SearchService.dummyUsers.map((u) => VersusUser.fromUser(u)).toList();
    _searchUserResults = List.from(_allUsers); // Start with all users as initial search results
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
    });
    SearchService.searchUsers(query).then((results) {
      setState(() {
        final users = results.map(VersusUser.fromUser).toList();
        if (_selectedUser1 == null) {
          _searchUserResults = users;
        } else {
          // Filter out the first selected user for second selection
          _searchUserResults = users.where((u) => u.id != _selectedUser1!.id).toList();
        }
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _searchUserResults = [];
      });
      print('Error searching users: $error');
    });
  }

  // Removed _performSecondUserSearch

  void _selectUser1(VersusUser user) {
    setState(() {
      _selectedUser1 = user;
      _searchController.clear();
      _searchUserResults = _allUsers.where((u) => u.id != user.id).toList(); // Prepare for second user selection
    });
  }

  void _selectUser2(VersusUser user) {
    setState(() {
      _selectedUser2 = user;
    });
  }

  Widget _buildSelectedUserContainers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_selectedUser1 != null)
          _UserImageContainer(user: _selectedUser1!, context: context),
        if (_selectedUser1 != null && _selectedUser2 == null)
          _QuestionMarkContainer(context: context),
        if (_selectedUser2 != null)
          _UserImageContainer(user: _selectedUser2!, context: context),
      ],
    );
  }

  Widget _buildInitialTrendingUsers() {
    // Show all possible versus pairs from _allUsers
    final List<Widget> versusPairs = [];
    for (int i = 0; i < _allUsers.length; i++) {
      for (int j = 0; j < _allUsers.length; j++) {
        if (i != j) {
          final user1 = _allUsers[i];
          final user2 = _allUsers[j];
          versusPairs.add(
            _VersusUserPairListItem(
              user1: user1,
              user2: user2,
              onTap: () {
                _selectUser1(user1);
                _selectUser2(user2);
              },
            ),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Trending',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 0),
            children: versusPairs,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstUserSearchResults() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _searchUserResults.length,
      itemBuilder: (context, i) {
        final versusUser = _searchUserResults[i];
        // Assuming SearchService.dummyUsers has the full User object
        final user = SearchService.dummyUsers.firstWhere(
              (u) => u.id.toString() == versusUser.id,
          // You might want to use .firstWhereOrNull or provide a fallback
          // if there's a chance the user won't be found.
          // For this example, assuming it will always be found.
        );
        return GestureDetector(
          onTap: () => _selectUser1(versusUser),
          child: SearchUserCard(user: user),
        );
      },
    );
  }

  Widget _buildSecondUserSelection() {
    // Use _searchUserResults for second user selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Suggested Versus',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _searchUserResults.length,
            padding: const EdgeInsets.symmetric(vertical: 0),
            itemBuilder: (context, i) {
              final user = _searchUserResults[i];
              return _VersusUserPairListItem(
                user1: _selectedUser1!,
                user2: user,
                onTap: () => _selectUser2(user),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedVersusDisplay() {
    // This state is reached only when both users are selected
    final left = _selectedUser1!;
    final right = _selectedUser2!;
    final fields = [
      {'label': 'Age', 'key': 'age'},
      {'label': 'Spouse', 'key': 'spouse'},
      {'label': 'Children', 'key': 'children'},
      {'label': 'Profession', 'key': 'profession'},
      {'label': 'Birthplace', 'key': 'birthplace'},
      {'label': 'Net Worth', 'key': 'netWorth'},
    ];
    String getValue(VersusUser user, String key) {
      if (user.extraAttributes != null && user.extraAttributes!.containsKey(key)) {
        return user.extraAttributes![key] ?? '';
      }
      return '';
    }
    LinearGradient _buildRandomizedGradient(Color baseColor, {bool reverse = false}) {
      final Random random = Random();
      final Color startColor = baseColor.withOpacity(0.8 - (random.nextDouble() * 0.2));
      final Color endColor = baseColor.withOpacity(0.6 + (random.nextDouble() * 0.2));
      return LinearGradient(
        colors: reverse ? [endColor, startColor] : [startColor, endColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    final Color leftCol = const Color(0xFF3B5E1F);
    final Color rightCol = const Color(0xFF6A1B1A);
    final Color labelCol = const Color(0xFF4B2067);
    final Color labelText = Colors.white;
    final Color leftText = Colors.white;
    final Color rightText = Colors.white;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Selected Versus',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          // Top row: Avatars/images only
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: left.imageUrl.isNotEmpty
                      ? Image.network(
                          left.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error_outline, size: 50));
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: right.imageUrl.isNotEmpty
                      ? Image.network(
                          right.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error_outline, size: 50));
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Names and VS row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  left.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  right.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Table with gradient columns and alternating rows
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: List.generate(fields.length, (index) {
                    final field = fields[index];
                    final baseColor = leftCol;
                    final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 != 0);
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: gradient,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        getValue(left, field['key']!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              // Label column
              Container(
                width: 110,
                child: Column(
                  children: List.generate(fields.length, (index) {
                    final field = fields[index];
                    final baseColor = labelCol;
                    final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 == 0);
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: gradient,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        field['label']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
              // Right column
              Expanded(
                child: Column(
                  children: List.generate(fields.length, (index) {
                    final field = fields[index];
                    final baseColor = rightCol;
                    final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 != 0);
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: gradient,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        getValue(right, field['key']!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Vote buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
              const SizedBox(width: 40),
              Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
            ],
          ),
          const SizedBox(height: 24),
          // Star ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Align(alignment: Alignment.center, child: _StarRating(rating: 4))),
              const SizedBox(width: 40),
              Expanded(child: Align(alignment: Alignment.center, child: _StarRating(rating: 4))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppSearchBar(
              controller: _searchController,
              hintText: AppLocalizations.of(context)!.searchHint,
              onChanged: (value) {
                _performSearch(value);
              },
              onSearchPressed: () {
                FocusScope.of(context).unfocus();
                _performSearch(_searchController.text);
              },
              onFilterPressed: () {
                print('Filter button pressed');
              },
              showSearchButton: true,
              showFilterButton: false,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            ),
            const SizedBox(height: 8),
            // Only show user containers if a user is selected
            if (_selectedUser1 != null) ...[
              _buildSelectedUserContainers(),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: _selectedUser1 == null
                  ? (_searchController.text.isEmpty
                  ? _buildInitialTrendingUsers()
                  : _buildFirstUserSearchResults())
                  : (_selectedUser2 == null
                  ? _buildSecondUserSelection()
                  : _buildSelectedVersusDisplay()),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for displaying user images in selected containers
class _UserImageContainer extends StatelessWidget {
  final VersusUser user;
  final BuildContext context;

  const _UserImageContainer({
    required this.user,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD6AF0C)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(user.imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

// Helper widget for displaying user list items (for trending/first search)
class _UserListItem extends StatelessWidget {
  final VersusUser user;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(user.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              flex: 3,
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StarRating extends StatelessWidget {
  final int rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
          size: 22,
        );
      }),
    );
  }
}

class _VoteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        side: const BorderSide(color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      child: const Text('VOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

// Helper widget for displaying the two users for versus selection/display
class _VersusUserPairListItem extends StatelessWidget {
  final VersusUser user1;
  final VersusUser user2;
  final VoidCallback onTap;

  const _VersusUserPairListItem({
    required this.user1,
    required this.user2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(user1.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            // Left name
            Expanded(
              flex: 3,
              child: Text(
                user1.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Vs
            const Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Vs',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
            ),
            // Right name
            Expanded(
              flex: 3,
              child: Text(
                user2.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Right avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(user2.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Container with a question mark for the second user placeholder
class _QuestionMarkContainer extends StatelessWidget {
  final BuildContext context;

  const _QuestionMarkContainer({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.15),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}