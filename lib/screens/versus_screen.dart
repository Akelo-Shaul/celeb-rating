import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/search_service.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/search_user_card.dart';

class VersusScreen extends StatefulWidget {
  const VersusScreen({super.key});

  @override
  State<VersusScreen> createState() => _VersusScreenState();
}

class _VersusScreenState extends State<VersusScreen> {
  final TextEditingController _searchController1 = TextEditingController();
  final TextEditingController _searchController2 = TextEditingController();
  List<User> _searchUserResults = [];
  bool _isLoading = false;

  bool _isSearchResults = false;

  @override
  void dispose() {
    _searchController1.dispose();
    _searchController2.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _isSearchResults = true;
    });
    final results = await SearchService.searchUsers(query);
    setState(() {
      _isLoading = false;
      _searchUserResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController1,
                    hintText: AppLocalizations.of(context)!.searchHint,
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    onSearchPressed: () {
                      FocusScope.of(context).unfocus();
                      _performSearch(_searchController1.text);
                    },
                    onFilterPressed: () {
                      print('Filter button pressed');
                    },
                    showSearchButton: true,
                    showFilterButton: false,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController2,
                    hintText: AppLocalizations.of(context)!.searchHint,
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    onSearchPressed: () {
                      FocusScope.of(context).unfocus();
                      _performSearch(_searchController2.text);
                    },
                    onFilterPressed: () {
                      print('Filter button pressed');
                    },
                    showSearchButton: true,
                    showFilterButton: false,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red)
                  ),
                  child: Text('Hello'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red)
                  ),
                  child: Text('Hello'),
                ),
              ],
            ),
            Expanded(
              child: (_searchController1.text.isEmpty && _searchController2.text.isEmpty)
                  ? Column(
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
                          child: ListView.builder(
                            itemCount: 8,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                                      child: const Icon(
                                          Icons.person, color: Colors.black38),
                                    ),
                                    const SizedBox(width: 8),
                                    // Left name
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Bruam Halaberry',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Vs
                                    const Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          'Vs',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    // Right name
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Chuck Hankey',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500, fontSize: 15),
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
                                      child: const Icon(
                                          Icons.person, color: Colors.black38),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _searchUserResults.length,
                          itemBuilder: (context, i) =>
                              SearchUserCard(user: _searchUserResults[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
