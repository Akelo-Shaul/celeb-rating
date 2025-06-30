import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/search_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/search_user_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<User> _searchResults = [];
  bool _isLoading = false;

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });
    final results = await SearchService.searchUsers(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "Search",
            ),
            const SizedBox(height: 5,),
            AppSearchBar(
              controller: _searchController,
              hintText: 'Search...',
              onChanged: (value) {
                _performSearch(value);
              },
              onSearchPressed: () {
                _performSearch(_searchController.text);
                FocusScope.of(context).unfocus();
              },
              onFilterPressed: () {
                print('Filter button pressed');
              },
              showSearchButton: true,
              showFilterButton: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, i) =>
                          SearchUserCard(user: _searchResults[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
