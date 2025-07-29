import '../models/leaderboard_entry.dart';

class LeaderboardService {
  // Filter options
  static const List<String> locationOptions = [
    'All Locations',
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Portugal',
    'Argentina',
    'Brazil',
    'Mexico',
    'Australia',
    'Japan',
    'South Korea',
    'China',
    'India',
    'Nigeria',
    'South Africa',
    'Kenya',
  ];

  static const List<String> categoryOptions = [
    'All Categories',
    'Music',
    'Acting',
    'Sports',
    'Business',
    'Entertainment',
    'Fashion',
    'Technology',
    'Politics',
    'Science',
    'Art',
  ];

  // Dummy celebrity data for leaderboard
  static final List<LeaderboardEntry> _celebrities = [
    LeaderboardEntry(
      name: 'Taylor Swift',
      category: 'Music',
      country: 'United States',
      followers: '250.5M',
      score: 98,
      trend: 'up',
      image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Beyoncé',
      category: 'Music',
      country: 'United States',
      followers: '232.1M',
      score: 97,
      trend: 'up',
      image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Dwayne Johnson',
      category: 'Acting',
      country: 'United States',
      followers: '210.7M',
      score: 95,
      trend: 'neutral',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Ariana Grande',
      category: 'Music',
      country: 'United States',
      followers: '190.3M',
      score: 93,
      trend: 'down',
      image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Cristiano Ronaldo',
      category: 'Sports',
      country: 'Portugal',
      followers: '187.8M',
      score: 92,
      trend: 'up',
      image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Kylie Jenner',
      category: 'Business',
      country: 'United States',
      followers: '182.4M',
      score: 90,
      trend: 'down',
      image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Selena Gomez',
      category: 'Music',
      country: 'United States',
      followers: '178.9M',
      score: 89,
      trend: 'up',
      image: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Justin Bieber',
      category: 'Music',
      country: 'Canada',
      followers: '165.2M',
      score: 87,
      trend: 'neutral',
      image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Kim Kardashian',
      category: 'Business',
      country: 'United States',
      followers: '158.7M',
      score: 85,
      trend: 'down',
      image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    LeaderboardEntry(
      name: 'Leo Messi',
      category: 'Sports',
      country: 'Argentina',
      followers: '152.3M',
      score: 84,
      trend: 'up',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
  ];

  // Get all celebrities
  static List<LeaderboardEntry> getAllCelebrities() {
    return List.from(_celebrities);
  }

  // Get filtered celebrities
  static List<LeaderboardEntry> getFilteredCelebrities({
    String? selectedLocation,
    String? selectedCategory,
  }) {
    return _celebrities.where((celebrity) {
      bool locationMatch = selectedLocation == null || 
          selectedLocation == 'All Locations' ||
          celebrity.country == selectedLocation;
      bool categoryMatch = selectedCategory == null || 
          selectedCategory == 'All Categories' ||
          celebrity.category == selectedCategory;
      return locationMatch && categoryMatch;
    }).toList();
  }

  // Get location options
  static List<String> getLocationOptions() {
    return List.from(locationOptions);
  }

  // Get category options
  static List<String> getCategoryOptions() {
    return List.from(categoryOptions);
  }

  // Get title based on filters
  static String getTitle({
    String? selectedLocation,
    String? selectedCategory,
  }) {
    List<String> titleParts = ['Celebrity Leaderboard'];
    
    if (selectedLocation != null && selectedLocation != 'All Locations') {
      titleParts.add('in $selectedLocation');
    }
    
    if (selectedCategory != null && selectedCategory != 'All Categories') {
      titleParts.add('- $selectedCategory');
    }
    
    return titleParts.join(' ');
  }

  // Get subtitle based on filters
  static String getSubtitle({
    String? selectedLocation,
    String? selectedCategory,
  }) {
    if (selectedLocation != null && selectedLocation != 'All Locations' &&
        selectedCategory != null && selectedCategory != 'All Categories') {
      return 'Top $selectedCategory celebrities in $selectedLocation';
    } else if (selectedLocation != null && selectedLocation != 'All Locations') {
      return 'Top celebrities in $selectedLocation';
    } else if (selectedCategory != null && selectedCategory != 'All Categories') {
      return 'Top $selectedCategory celebrities worldwide';
    } else {
      return 'Tracking the most influential celebrities worldwide';
    }
  }
} 