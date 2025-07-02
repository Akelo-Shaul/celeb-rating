import 'package:celebrating/models/comment.dart';
import 'package:celebrating/models/like.dart';
import 'package:celebrating/models/user.dart';
import 'package:celebrating/services/api_service.dart';
import 'package:celebrating/models/post.dart';

class FeedService{
  static Future<List<Post>> getFeed(Map<String, dynamic> data){
    // For now, return dummy data for demonstration
    return Future.value(generateDummyPosts());
  }

  static List<Post> generateDummyPosts() {
    // Dummy Users
    final User user1 = User(
      id: 1,
      username: 'brumm_h',
      fullName: 'Brumm Halaberry',
      profileImageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80',
      password: 'dummy_password',
      email: 'brumm@example.com',
      role: 'Musician',
      createdAt: DateTime.now(),
    );

    final User user2 = User(
      id: 2,
      username: 'jane_d',
      fullName: 'Jane Doe',
      profileImageUrl: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80',
      password: 'dummy_password',
      email: 'jane@example.com',
      role: 'Photographer',
      createdAt: DateTime.now(),
    );

    final User user3 = User(
      id: 3,
      username: 'code_m',
      fullName: 'Code Master',
      profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=facearea&w=200&h=200&facepad=2&q=80',
      password: 'dummy_password',
      email: 'code@example.com',
      role: 'Engineer',
      createdAt: DateTime.now(),
    );

    // Dummy Comments with replies
    final Comment reply1 = Comment(
      id: 'r_001',
      user: user3,
      content: 'That\'s awesome! Keep up the great work!',
      likes: 2,
      replies: [],
    );

    final Comment comment1 = Comment(
      id: 'c_001',
      user: user2,
      content: 'Amazing post, Brumm! Really inspiring content.',
      likes: 15,
      replies: [reply1],
    );

    final Comment comment2 = Comment(
      id: 'c_002',
      user: user3,
      content: 'Loved the media on this one. Very well put together.',
      likes: 8,
      replies: [],
    );

    return [
      Post(
        id: 'post_000',
        content: 'Check out this amazing event! Here are some highlights in photos and a video.',
        from: user1,
        categories: ['Events', 'Highlights'],
        hashtags: ['#event', '#highlights', '#fun'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        mediaLink: 'https://example.com/media/0',
        timeAgo: '1 day ago',
        media: [
          MediaItem(url: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80', type: 'image'),
          MediaItem(url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', type: 'video'),
          MediaItem(url: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80', type: 'image'),
          MediaItem(url: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80', type: 'image'),
        ],
        initialRating: 4,
        likes: [Like(userId: user2.id.toString(), likedAt: DateTime.now())],
        comments: [comment1],
        location: 'New York, USA',
      ),
      Post(
        id: 'post_001',
        content: 'This is a very long post content to demonstrate the "read more" functionality. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
        from: user1,
        categories: ['Music', 'Public Speaking'],
        hashtags: ['#inspiration', '#musiclife'],
        timestamp: DateTime.now().subtract(const Duration(days: 210)),
        mediaLink: 'https://example.com/media/1',
        timeAgo: '7 mo',
        media: [
          MediaItem(url: 'https://picsum.photos/id/237/800/450', type: 'image'),
          MediaItem(url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', type: 'video'),
          MediaItem(url: 'https://picsum.photos/id/238/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/239/800/450', type: 'image'),
        ],
        initialRating: 3,
        likes: [Like(userId: user2.id.toString(), likedAt: DateTime.now())],
        comments: [comment1, comment2],
        location: 'London, UK',
      ),
      Post(
        id: 'post_002',
        content: 'Enjoying the breathtaking views from the mountain top! #travel #nature #mountains #adventure #photography This is a shorter post content to show how the "more" button won\'t appear if the text is short enough.',
        from: user2,
        categories: ['Travel', 'Photography'],
        hashtags: ['#mountains', '#nature'],
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        mediaLink: 'https://example.com/media/2',
        timeAgo: '2 days ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/240/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/241/800/450', type: 'image'),
        ],
        initialRating: 0,
        likes: [Like(userId: user1.id.toString(), likedAt: DateTime.now()), Like(userId: user3.id.toString(), likedAt: DateTime.now())],
        comments: [],
        location: 'Cape Town, South Africa',
      ),
      Post(
        id: 'post_003',
        content: 'Just launched my new open-source project! Check it out on GitHub. It\'s built with Flutter and Dart, focusing on performance and clean architecture. I\'m really excited about the community feedback so far!',
        from: user3,
        categories: ['Tech', 'Coding'],
        hashtags: ['#flutter', '#opensource'],
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        mediaLink: 'https://example.com/media/3',
        timeAgo: '1 week ago',
        media: [
          MediaItem(url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', type: 'video'),
        ],
        initialRating: 5,
        likes: [],
        comments: [comment1],
        location: 'Berlin, Germany',
      ),
      Post(
        id: 'post_004',
        content: 'A quick thought for the day: "The only way to do great work is to love what you do." - Steve Jobs',
        from: user1,
        categories: ['Inspiration'],
        hashtags: ['#quotes', '#motivation'],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        mediaLink: 'https://example.com/media/4',
        timeAgo: '5 hours ago',
        media: [],
        initialRating: 4,
        likes: [Like(userId: user2.id.toString(), likedAt: DateTime.now())],
        comments: [],
        location: 'San Francisco, USA',
      ),
      Post(
        id: 'post_005',
        content: 'Exploring the vibrant streets and amazing food of Bangkok.',
        from: user2,
        categories: ['Travel', 'Food'],
        hashtags: ['#bangkok', '#streetfood'],
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        mediaLink: 'https://example.com/media/5',
        timeAgo: '3 days ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/242/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/243/800/450', type: 'image'),
        ],
        initialRating: 0,
        likes: [],
        comments: [],
        location: 'Bangkok, Thailand',
      ),
      Post(
        id: 'post_006',
        content: 'The best way to predict the future is to invent it. - Alan Kay',
        from: user3,
        categories: ['Inspiration', 'Tech'],
        hashtags: ['#alan_kay', '#innovation'],
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        mediaLink: 'https://example.com/media/6',
        timeAgo: '10 days ago',
        media: [],
        initialRating: 5,
        likes: [Like(userId: user1.id.toString(), likedAt: DateTime.now())],
        comments: [],
        location: 'Mountain View, USA',
      ),
      Post(
        id: 'post_007',
        content: 'Had an amazing time at the beach this weekend. The sound of the waves and the sunset view were just incredible.',
        from: user1,
        categories: ['Relaxation', 'Nature'],
        hashtags: ['#beach', '#sunset'],
        timestamp: DateTime.now().subtract(const Duration(days: 14)),
        mediaLink: 'https://example.com/media/7',
        timeAgo: '2 weeks ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/244/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/245/800/450', type: 'image'),
        ],
        initialRating: 4,
        likes: [Like(userId: user2.id.toString(), likedAt: DateTime.now())],
        comments: [comment2],
        location: 'Malibu, USA',
      ),
      Post(
        id: 'post_008',
        content: 'Diving deep into the ocean blue. The underwater life is just mesmerizing.',
        from: user2,
        categories: ['Adventure', 'Nature'],
        hashtags: ['#diving', '#underwater'],
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        mediaLink: 'https://example.com/media/8',
        timeAgo: '1 month ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/246/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/247/800/450', type: 'image'),
        ],
        initialRating: 5,
        likes: [],
        comments: [],
        location: 'Great Barrier Reef, Australia',
      ),
      Post(
        id: 'post_009',
        content: 'Rediscovering the beauty of nature with a peaceful hike in the mountains.',
        from: user3,
        categories: ['Health', 'Nature'],
        hashtags: ['#hiking', '#mountains'],
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
        mediaLink: 'https://example.com/media/9',
        timeAgo: '2 months ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/248/800/450', type: 'image'),
          MediaItem(url: 'https://picsum.photos/id/249/800/450', type: 'image'),
        ],
        initialRating: 4,
        likes: [Like(userId: user1.id.toString(), likedAt: DateTime.now())],
        comments: [],
        location: 'Yosemite National Park, USA',
      ),
      Post(
        id: 'post_010',
        content: 'A throwback to my graduation day. Proud to be an alumnus of XYZ University.',
        from: user1,
        categories: ['Education', 'Milestones'],
        hashtags: ['#graduation', '#alumni'],
        timestamp: DateTime.now().subtract(const Duration(days: 365)),
        mediaLink: 'https://example.com/media/10',
        timeAgo: '1 year ago',
        media: [
          MediaItem(url: 'https://picsum.photos/id/250/800/450', type: 'image'),
        ],
        initialRating: 5,
        likes: [Like(userId: user2.id.toString(), likedAt: DateTime.now())],
        comments: [],
        location: 'XYZ University, USA',
      ),
    ];
  }
}