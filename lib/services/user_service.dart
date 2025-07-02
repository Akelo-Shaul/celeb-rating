import 'package:celebrating/services/api_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class UserService {
  static Future<String> login(String username, String password) async {
    final response = await ApiService.post('auth/login', {
      'username': username,
      'password': password,
    }, (json) => json['token'] as String);
    return response;
  }

  static Future<User> register(User user) async {
    final response = await ApiService.post('auth/register', user.toJson(), (json) => User.fromJson(json));
    return response;
  }

  static Future<User> fetchUser(String userId, {bool isCelebrity = false}) async {
    // Dummy comments
    List<Comment> comments = [
      Comment(
        id: '1',
        user: User(
          id: 2,
          username: 'fan_1',
          password: '',
          email: 'fan1@example.com',
          role: 'User',
          fullName: 'Fan One',
        ),
        content: 'Amazing post!',
        likes: 3,
        replies: [
          Comment(
            id: '1-1',
            user: User(
              id: 4,
              username: 'reply_guy',
              password: '',
              email: 'reply@example.com',
              role: 'User',
              fullName: 'Reply Guy',
            ),
            content: 'Totally agree!',
            likes: 1,
            replies: [],
          ),
        ],
      ),
      Comment(
        id: '2',
        user: User(
          id: 3,
          username: 'fan_2',
          password: '',
          email: 'fan2@example.com',
          role: 'User',
          fullName: 'Fan Two',
        ),
        content: 'Love this!',
        likes: 2,
        replies: [],
      ),
    ];

    // Dummy posts
    List<Post> postsList = [
      Post(
        id: '1',
        content: 'This is my first post! Excited to share with you all.',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['General'],
        hashtags: ['#welcome'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        mediaLink: '',
        timeAgo: '1d',
        media: [
          MediaItem(url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80', type: 'image'),
          MediaItem(url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', type: 'video'),
        ],
        initialRating: 4,
        likes: [],
        comments: comments,
        location: 'Los Angeles, USA',
      ),
      Post(
        id: '2',
        content: 'Backstage moments before the big show!',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Events'],
        hashtags: ['#backstage'],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        mediaLink: '',
        timeAgo: '5h',
        media: [
          MediaItem(url: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80', type: 'image'),
        ],
        initialRating: 5,
        likes: [],
        comments: [],
        location: 'New York, USA',
      ),
      Post(
        id: '3',
        content: 'Thank you all for the amazing support at last night’s concert!',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Music'],
        hashtags: ['#concert', '#thankyou'],
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        mediaLink: '',
        timeAgo: '2d',
        media: [
          MediaItem(url: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80', type: 'image'),
        ],
        initialRating: 5,
        likes: [],
        comments: [],
        location: 'Berlin, Germany',
      ),
      Post(
        id: '4',
        content: 'Behind the scenes: prepping for the next big event!',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Behind the Scenes'],
        hashtags: ['#bts'],
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        mediaLink: '',
        timeAgo: '3d',
        media: [],
        initialRating: 4,
        likes: [],
        comments: [],
        location: 'London, UK',
      ),
      Post(
        id: '5',
        content: 'Q&A session coming up! Drop your questions below.',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Q&A'],
        hashtags: ['#askme'],
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        mediaLink: '',
        timeAgo: '4d',
        media: [
          MediaItem(url: 'https://picsum.photos/id/240/800/450', type: 'image'),
        ],
        initialRating: 3,
        likes: [],
        comments: [],
        location: 'Paris, France',
      ),
      Post(
        id: '6',
        content: 'Throwback to my favorite performance of the year!',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Throwback'],
        hashtags: ['#tbt'],
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        mediaLink: '',
        timeAgo: '5d',
        media: [
          MediaItem(url: 'https://picsum.photos/id/241/800/450', type: 'image'),
        ],
        initialRating: 5,
        likes: [],
        comments: [],
        location: 'Tokyo, Japan',
      ),
      Post(
        id: '7',
        content: 'Announcing my next tour dates soon. Stay tuned!',
        from: User(
          id: int.tryParse(userId) ?? 1,
          username: isCelebrity ? 'celeb_user' : 'dummy_user',
          fullName: isCelebrity ? 'Celebrity User' : 'Dummy User',
          profileImageUrl: isCelebrity
              ? 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80'
              : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
          password: '',
          email: isCelebrity ? 'celeb@example.com' : 'dummy@example.com',
          role: isCelebrity ? 'Celebrity' : 'User',
        ),
        categories: ['Announcement'],
        hashtags: ['#tour'],
        timestamp: DateTime.now().subtract(const Duration(days: 6)),
        mediaLink: '',
        timeAgo: '6d',
        media: [],
        initialRating: 4,
        likes: [],
        comments: [],
        location: 'Sydney, Australia',
      ),
    ];

    if (!isCelebrity) {
      // Return a dummy common user
      return User(
        id: int.tryParse(userId) ?? 0,
        username: 'dummy_user',
        fullName: 'Dummy User',
        profileImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&h=200&fit=crop&auto=format',
        password: 'dummy_password',
        email: 'dummy@example.com',
        role: 'User',
        createdAt: DateTime.now(),
        postsList: postsList,
      );
    } else {
      // Dummy data for Career tab
      final Map<String, List<Map<String, String>>> careerEntries = {
        'Profession': [
          {'title': 'Musician, Public Speaker'},
        ],
        'Debut Work': [
          {'title': 'Lead Actor', 'subtitle': 'The Last of Us'},
        ],
        'Awards': [
          {'title': 'Lead Actor, The Last of Us','award': 'Emmy Awards'},
          {'title': 'Sting on the view','award': 'Grammy Awards'},
          {'title': 'Best Upcoming Artist','award': 'MTV Awards'},
        ],
        'Collaborations': [
          {'title': 'Horror on the Moves', 'subtitle': 'ft Chunk Molksey', 'type': 'Song'},
          {'title': 'Sting on the view','subtitle': 'ft Alice Mahone', 'type': 'Song'}
        ],
      };

      // Dummy data for Wealth tab
      final Map<String, List<Map<String, String>>> wealthEntries = {
        'Cars': [
          {'imageUrl': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=400&q=80', 'name': 'Lamborghini Aventador'},
          {'imageUrl': 'https://images.unsplash.com/photo-1461632830798-3adb3034e4c8?auto=format&fit=crop&w=400&q=80', 'name': 'Ferrari 488'},
          {'imageUrl': 'https://images.unsplash.com/photo-1511918984145-48de785d4c4e?auto=format&fit=crop&w=400&q=80', 'name': 'Rolls Royce Phantom'},
          {'imageUrl': 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=400&q=80', 'name': 'Porsche 911'},
          {'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80', 'name': 'Tesla Model S'},
        ],
        'Houses': [
          {'imageUrl': 'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=400&q=80', 'name': 'Malibu Mansion'},
          {'imageUrl': 'https://images.unsplash.com/photo-1460518451285-97b6aa326961?auto=format&fit=crop&w=400&q=80', 'name': 'NYC Penthouse'},
          {'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80', 'name': 'Lake House'},
          {'imageUrl': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80', 'name': 'Paris Apartment'},
          {'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80', 'name': 'Dubai Villa'},
        ],
        'Art Collection': [
          {'imageUrl': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80', 'name': 'Van Gogh Painting'},
          {'imageUrl': 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?auto=format&fit=crop&w=400&q=80', 'name': 'Picasso Sculpture'},
          {'imageUrl': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=400&q=80', 'name': 'Modern Abstract'},
          {'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=400&q=80', 'name': 'Classic Portrait'},
          {'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80', 'name': 'Street Art'},
        ],
        'Watch Collection': [
          {'imageUrl': 'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?auto=format&fit=crop&w=400&q=80', 'name': 'Rolex Daytona'},
          {'imageUrl': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80', 'name': 'Patek Philippe'},
          {'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80', 'name': 'Audemars Piguet'},
          {'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80', 'name': 'Omega Seamaster'},
          {'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80', 'name': 'Tag Heuer'},
        ],
      };

      // Dummy data for Socials
      final List<Map<String, dynamic>> socials = [
        {'title': 'TikTok', 'icon': 'tiktok', 'link': 'https://www.tiktok.com/@celeb'},
        {'title': 'Reddit', 'icon': 'reddit', 'link': 'https://www.reddit.com/user/celeb'},
        {'title': 'Spotify', 'icon': 'spotify', 'link': 'https://open.spotify.com/artist/celeb'},
        {'title': 'YouTube', 'icon': 'youtube', 'link': 'https://www.youtube.com/c/celeb'},
        {'title': 'Snapchat', 'icon': 'snapchat', 'link': 'https://www.snapchat.com/add/celeb'},
      ];

      final String publicImageDescription = 'Known for philanthropy and well spoken. A public Icon with a great following and fans';

      final List<Map<String, dynamic>> controversyMedia = [
        {
          'controversy': 'Beef with Richard Holgrain',
          'media': [
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          ],
        },
        {
          'controversy': 'Dispute with Label XYZ',
          'media': [
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          ],
        },
        {
          'controversy': 'Scammed users',
          'media': [
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          ],
        },
        {
          'controversy': 'Fraud',
          'media': [
            'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
          ],
        },
      ];

      final Map<String, List<Map<String, dynamic>>> fashionStyle = {
        'vintage': [
          {'imageUrl': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=200&q=80'},
        ],
        'street': [
          {'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=200&q=80'},
          {'imageUrl': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=200&q=80'},
        ],
      };

      // Additional dummy data for new fields
      final String zodiacSign = 'Libra';
      final List<Map<String, dynamic>> familyMembers = [
        {'name': 'Father', 'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=facearea&w=200&h=200&q=80'},
        {'name': 'Grand Father', 'imageUrl': 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&q=80'},
        {'name': 'Mother', 'imageUrl': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=facearea&w=200&h=200&q=80'},
        {'name': 'Spouse', 'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=facearea&w=200&h=200&q=80'},
        {'name': 'Brother', 'imageUrl': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=facearea&w=200&h=200&q=80'},
        {'name': 'Sister', 'imageUrl': 'https://images.unsplash.com/photo-1461632830798-3adb3034e4c8?auto=format&fit=facearea&w=200&h=200&q=80'},
      ];
      final List<String> relationships = [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=facearea&w=200&h=200&q=80',
      ];
      final List<Map<String, dynamic>> hobbies = [
        {'name': 'Basketball', 'imageUrl': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Skiing', 'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Sky Diving', 'imageUrl': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Swimming', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Fishing', 'imageUrl': 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?auto=format&fit=crop&w=200&q=80'},
      ];
      final List<String> pets = [
        'https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1518715308788-3005759c41c8?auto=format&fit=facearea&w=200&h=200&q=80',
        'https://images.unsplash.com/photo-1518715308788-3005759c41c8?auto=format&fit=facearea&w=200&h=200&q=80',
      ];
      final List<String> tattoos = [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=200&q=80',
        'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=200&q=80',
      ];
      final List<Map<String, dynamic>> favouritePlaces = [
        {'name': 'Vienna', 'imageUrl': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Seattle', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80'},
        {'name': 'New York', 'imageUrl': 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Lagos', 'imageUrl': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Kenya', 'imageUrl': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=200&q=80'},
      ];
      final List<Map<String, dynamic>> talents = [
        {'name': 'Basketball', 'imageUrl': 'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Skiing', 'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=200&q=80'},
        {'name': 'Sky Diving', 'imageUrl': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=200&q=80'},
      ];

      // Dummy data for Education, Diet, Spirituality, and Involved Causes
      final List<Map<String, String>> educationEntries = [
        {'degree': "Bachelor's degree in Sociology", 'university': 'Princeton University'},
        {'degree': "Bachelor's degree in Psychology", 'university': 'Princeton University'},
      ];
      final String diet = 'Vegan';
      final String spirituality = 'Buddhist';
      final List<Map<String, String>> involvedCauses = [
        {'name': 'Getrude Childrens Mission', 'role': 'Donor'},
        {'name': 'All Sales Funds', 'role': 'Manager'},
      ];

      // Return a dummy celebrity user with extra fields
      return CelebrityUser(
        id: int.tryParse(userId) ?? 1,
        username: 'celeb_user',
        fullName: 'Celebrity User',
        profileImageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80',
        password: 'celeb_password',
        email: 'celeb@example.com',
        role: 'Celebrity',
        createdAt: DateTime.now(),
        occupation: 'Musician, Public Speaker',
        nationality: 'Kenyan',
        bio: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        website: 'https://www.lpsum.com/',
        followers: 23700,
        posts: 50,
        netWorth: ' 2.5M USD',
        wealthEntries: wealthEntries,
        postsList: postsList,
        careerEntries: careerEntries,
        zodiacSign: zodiacSign,
        familyMembers: familyMembers,
        relationships: relationships,
        educationEntries: educationEntries,
        hobbies: hobbies,
        diet: diet,
        spirituality: spirituality,
        involvedCauses: involvedCauses,
        pets: pets,
        tattoos: tattoos,
        favouritePlaces: favouritePlaces,
        talents: talents,
        socials: socials,
        publicImageDescription: publicImageDescription,
        controversyMedia: controversyMedia,
        fashionStyle: fashionStyle,
      );
    }
  }
}