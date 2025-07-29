import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/hall_of_famer.dart';
import '../services/hall_of_fame_service.dart';

class HallOfFame extends StatefulWidget {
  const HallOfFame({super.key});

  @override
  State<HallOfFame> createState() => _HallOfFameState();
}

class _HallOfFameState extends State<HallOfFame> {
  final CarouselController _carouselController = CarouselController();
  final HallOfFameService _service = HallOfFameService();
  Timer? _timer;
  int _currentIndex = 0;
  List<HallOfFamer> _hallOfFamers = [];
  bool _loading = true;
  
  // Filter state
  String _selectedLocation = 'All Locations';
  String _selectedTime = 'Today';
  String _selectedCategory = 'All Categories';
  
  // Filter options
  final List<String> _locationOptions = [
    'All Locations',
    'Africa',
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Australia',
    'Antarctica',
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Netherlands',
    'Belgium',
    'Switzerland',
    'Austria',
    'Sweden',
    'Norway',
    'Denmark',
    'Finland',
    'Poland',
    'Czech Republic',
    'Hungary',
    'Romania',
    'Bulgaria',
    'Greece',
    'Turkey',
    'Russia',
    'Ukraine',
    'Belarus',
    'Latvia',
    'Lithuania',
    'Estonia',
    'China',
    'Japan',
    'South Korea',
    'India',
    'Pakistan',
    'Bangladesh',
    'Sri Lanka',
    'Nepal',
    'Bhutan',
    'Myanmar',
    'Thailand',
    'Vietnam',
    'Laos',
    'Cambodia',
    'Malaysia',
    'Singapore',
    'Indonesia',
    'Philippines',
    'Taiwan',
    'Hong Kong',
    'Macau',
    'Mongolia',
    'Kazakhstan',
    'Uzbekistan',
    'Kyrgyzstan',
    'Tajikistan',
    'Turkmenistan',
    'Afghanistan',
    'Iran',
    'Iraq',
    'Syria',
    'Lebanon',
    'Jordan',
    'Israel',
    'Palestine',
    'Saudi Arabia',
    'Yemen',
    'Oman',
    'United Arab Emirates',
    'Qatar',
    'Bahrain',
    'Kuwait',
    'Egypt',
    'Libya',
    'Tunisia',
    'Algeria',
    'Morocco',
    'Sudan',
    'South Sudan',
    'Ethiopia',
    'Eritrea',
    'Djibouti',
    'Somalia',
    'Kenya',
    'Uganda',
    'Tanzania',
    'Rwanda',
    'Burundi',
    'Democratic Republic of Congo',
    'Republic of Congo',
    'Central African Republic',
    'Cameroon',
    'Chad',
    'Niger',
    'Nigeria',
    'Benin',
    'Togo',
    'Ghana',
    'Ivory Coast',
    'Liberia',
    'Sierra Leone',
    'Guinea',
    'Guinea-Bissau',
    'Senegal',
    'Gambia',
    'Mauritania',
    'Mali',
    'Burkina Faso',
    'Niger',
    'Chad',
    'Algeria',
    'Tunisia',
    'Libya',
    'Egypt',
    'Sudan',
    'South Sudan',
    'Ethiopia',
    'Eritrea',
    'Djibouti',
    'Somalia',
    'Kenya',
    'Uganda',
    'Tanzania',
    'Rwanda',
    'Burundi',
    'Democratic Republic of Congo',
    'Republic of Congo',
    'Central African Republic',
    'Cameroon',
    'Chad',
    'Niger',
    'Nigeria',
    'Benin',
    'Togo',
    'Ghana',
    'Ivory Coast',
    'Liberia',
    'Sierra Leone',
    'Guinea',
    'Guinea-Bissau',
    'Senegal',
    'Gambia',
    'Mauritania',
    'Mali',
    'Burkina Faso',
    'Mexico',
    'Guatemala',
    'Belize',
    'El Salvador',
    'Honduras',
    'Nicaragua',
    'Costa Rica',
    'Panama',
    'Colombia',
    'Venezuela',
    'Guyana',
    'Suriname',
    'French Guiana',
    'Brazil',
    'Ecuador',
    'Peru',
    'Bolivia',
    'Paraguay',
    'Uruguay',
    'Argentina',
    'Chile',
    'New Zealand',
    'Fiji',
    'Papua New Guinea',
    'Solomon Islands',
    'Vanuatu',
    'New Caledonia',
    'French Polynesia',
    'Samoa',
    'Tonga',
    'Tuvalu',
    'Kiribati',
    'Marshall Islands',
    'Micronesia',
    'Palau',
    'Nauru',
  ];
  
  final List<String> _timeOptions = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Yesterday',
    'Last Week',
    'Last Month',
    'Last Year',
    'Past 7 Days',
    'Past 30 Days',
    'Past 3 Months',
    'Past 6 Months',
    'Past Year',
    'All Time',
  ];
  
  final List<String> _categoryOptions = [
    'All Categories',
    'Sports',
    'Music',
    'Art',
    'Science',
    'Technology',
    'Politics',
    'Entertainment',
    'Business',
    'Literature',
    'Film',
    'Fashion',
    'Culinary',
    'Education',
    'Medicine',
    'Engineering',
    'Architecture',
    'Philosophy',
    'Religion',
    'Military',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0; // Ensure we start at index 0
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });
    
    // Pass filter parameters to the service
    final data = await _service.fetchHallOfFamers(
      location: _selectedLocation,
      timePeriod: _selectedTime,
      category: _selectedCategory,
    );
    
    setState(() {
      _hallOfFamers = data;
      _loading = false;
      // Reset current index to 0 when data changes
      _currentIndex = 0;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_carouselController.hasClients && _hallOfFamers.isNotEmpty) {
        _carouselController.animateToItem(_currentIndex);
      }
    });
    
    // Reset timer with new data
    _timer?.cancel();
    if (_hallOfFamers.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        _goToNextItem();
      });
    }
  }

  void _goToNextItem() {
    if (_hallOfFamers.isEmpty || _currentIndex >= _hallOfFamers.length) return;
    final int totalItems = _hallOfFamers.length;
    setState(() {
      _currentIndex = (_currentIndex + 1) % totalItems;
    });
    if (_carouselController.hasClients) {
      _carouselController.animateToItem(_currentIndex);
    }
  }

  void _goToPreviousItem() {
    if (_hallOfFamers.isEmpty || _currentIndex >= _hallOfFamers.length) return;
    final int totalItems = _hallOfFamers.length;
    setState(() {
      _currentIndex = (_currentIndex - 1 + totalItems) % totalItems;
    });
    if (_carouselController.hasClients) {
      _carouselController.animateToItem(_currentIndex);
    }
  }

  void _pauseAutoScroll() {
    if (!_loading && _timer?.isActive == true) {
      _timer?.cancel();
    }
  }

  void _resumeAutoScroll() {
    if (!_loading && _hallOfFamers.isNotEmpty) {
      _timer?.cancel(); // Cancel existing timer if any
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        _goToNextItem();
      });
    }
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              title: Text(
                'Filter Hall of Fame',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedLocation,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: _locationOptions.map((String location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLocation = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Time Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Period',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedTime,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: _timeOptions.map((String time) {
                              return DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTime = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Category Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: _categoryOptions.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Apply filters and refresh data
                    this.setState(() {
                      // Update the main state with selected filters
                      _selectedLocation = _selectedLocation;
                      _selectedTime = _selectedTime;
                      _selectedCategory = _selectedCategory;
                    });
                    Navigator.of(context).pop();
                    _fetchData(); // Refresh data with new filters
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getFilteredTitle() {
    return '$_selectedTime Hall of Fame';
  }

  String _getFilteredSubtitle() {
    List<String> filters = [];
    
    if (_selectedCategory != 'All Categories') {
      filters.add(_selectedCategory);
    }
    
    if (_selectedLocation != 'All Locations') {
      filters.add(_selectedLocation);
    }
    
    return filters.join(', ');
  }

  HallOfFamer? _getCurrentHallOfFamer() {
    if (_hallOfFamers.isEmpty || _currentIndex < 0 || _currentIndex >= _hallOfFamers.length) {
      return null;
    }
    return _hallOfFamers[_currentIndex];
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Hall of Famers Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Reset filters to default
              setState(() {
                _selectedLocation = 'All Locations';
                _selectedTime = 'Today';
                _selectedCategory = 'All Categories';
              });
              _fetchData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFilteredTitle(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_getFilteredSubtitle().isNotEmpty)
              Text(
                _getFilteredSubtitle(),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black87),
            onPressed: _showFilterDialog,
          )
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _getCurrentHallOfFamer() != null
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) {
                              final box = context.findRenderObject() as RenderBox;
                              final localPosition = box.globalToLocal(details.globalPosition);
                              final width = box.size.width;
                              if (localPosition.dx < width / 2) {
                                _goToPreviousItem();
                              } else {
                                _goToNextItem();
                              }
                            },
                            onLongPressStart: (_) {
                              _pauseAutoScroll();
                            },
                            onLongPressEnd: (_) {
                              _resumeAutoScroll();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Image.network(
                                    _getCurrentHallOfFamer()!.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/profile_placeholder.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  // Gradient overlay at the bottom for text readability
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 120,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black87,
                                            Colors.black,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Username and achievement overlay
                                  // Achievement in gold bar above username
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 90,
                                    child: Center(
                                      child: _GoldBarLabel(
                                        text: _getCurrentHallOfFamer()!.achievement.toUpperCase(),
                                      ),
                                    ),
                                  ),
                                  // Username below achievement
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 48,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32),
                                        child: Text(
                                          _getCurrentHallOfFamer()!.username.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32,
                                            letterSpacing: 1.5,
                                            fontFamily: 'RobotoMono', // Use a square/monospace font
                                            shadows: [Shadow(blurRadius: 6, color: Colors.black87, offset: Offset(1,2))],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _buildEmptyState(),
                  ),
                  const SizedBox(height: 10),
                  if (_hallOfFamers.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: CarouselView.weighted(
                        controller: _carouselController,
                        shrinkExtent: 200,
                        flexWeights: [2, 7, 3, 2],
                        children: _hallOfFamers.asMap().entries.map((entry) {
                          final famer = entry.value;
                          final isCurrent = entry.key == _currentIndex;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Blurred background image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                  child: Image.network(
                                    famer.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/profile_placeholder.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Positioned(
                                  right: 16,
                                  bottom: 12,
                                  child: Text(
                                    famer.username.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                      fontFamily: 'RobotoMono',
                                      shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1,1))],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// Remove _BlurredGoldLabel and add this at the bottom:
class _GoldBarLabel extends StatelessWidget {
  final String text;
  const _GoldBarLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFBFA23A),
              Color(0xFFFFD700),
              Color(0xFFBFA23A),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
            fontFamily: 'RobotoMono',
            shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1,1))],
          ),
          textAlign: TextAlign.center,
          maxLines: null,
          softWrap: true,
        ),
      ),
    );
  }
}