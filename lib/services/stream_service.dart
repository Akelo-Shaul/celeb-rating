import '../models/stream_category.dart';
import '../models/live_stream.dart';
import '../models/user.dart';
import 'user_service.dart';

class StreamService {
  // Dummy users for linking
  static final List<User> _users = [
    User(
      id: 1,
      username: 'streamer1',
      password: '',
      email: 'streamer1@example.com',
      role: 'User',
      fullName: 'Streamer One',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    User(
      id: 2,
      username: 'streamer2',
      password: '',
      email: 'streamer2@example.com',
      role: 'User',
      fullName: 'Streamer Two',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
  ];

  // Dummy categories
  static final List<StreamCategory> _categories = [
    StreamCategory(
      id: '1',
      name: 'Music',
      description: 'Live music performances, concerts, and DJ sets.',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80',
      streamCount: 120,
      followerCount: 5400,
      coverUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
      tags: ['#music', '#dj', '#concert', '#live'],
    ),
    StreamCategory(
      id: '2',
      name: 'Gaming',
      description: 'Watch top gamers play the latest games live.',
      imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=400&q=80',
      streamCount: 200,
      followerCount: 12000,
      coverUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      tags: ['#gaming', '#esports', '#tournament', '#stream'],
    ),
    StreamCategory(
      id: '3',
      name: 'Education',
      description: 'Live classes, tutorials, and workshops.',
      imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      streamCount: 80,
      followerCount: 3200,
      coverUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=800&q=80',
      tags: ['#education', '#learning', '#class', '#tutorial'],
    ),
  ];

  static final List<StreamCategory> _allCategories = [..._categories];

  static List<StreamCategory> getCategories() => _allCategories;
  static List<LiveStream> getStreams() => _streams;

  static final List<LiveStream> _streams = [
    LiveStream(
      id: 'live1',
      title: 'Live DJ Set',
      description: 'Join the party with Streamer One spinning live!',
      streamer: _users[0],
      // streamUrl: 'https://video-previews.elements.envatousercontent.com/2d5ccd85-b4f2-4349-8a2f-aba2913b94f4/watermarked_preview/watermarked_preview.mp4', // working mp4
      streamUrl: 'https://video-previews.elements.envatousercontent.com/2d5ccd85-b4f2-4349-8a2f-aba2913b94f4/watermarked_preview/watermarked_preview.mp4', // working mp4
      thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80',
      viewerCount: 1200,
      isLive: true,
      startedAt: DateTime.now().subtract(Duration(minutes: 30)),
      categories: [_categories[0]],
      tags: ['#music', '#dj', '#party'],
      language: 'en',
      location: 'Berlin, Germany',
    ),
    LiveStream(
      id: 'live2',
      title: 'Pro Gamer Tournament',
      description: 'Watch Streamer Two compete in a live gaming tournament!',
      streamer: _users[1],
      streamUrl: 'https://samplelib.com/mp4/sample-5s.mp4', // working mp4
      thumbnailUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=400&q=80',
      viewerCount: 3400,
      isLive: true,
      startedAt: DateTime.now().subtract(Duration(minutes: 10)),
      categories: [_categories[1]],
      tags: ['#gaming', '#tournament'],
      language: 'en',
      location: 'New York, USA',
    ),
    LiveStream(
      id: 'rec1',
      title: 'Math Class Replay',
      description: 'Replay of a live math class for high school students.',
      streamer: _users[0],
      streamUrl: 'https://www.w3schools.com/html/movie.mp4', // working mp4
      thumbnailUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      viewerCount: 150,
      isLive: false,
      startedAt: DateTime.now().subtract(Duration(days: 1, hours: 2)),
      categories: [_categories[2]],
      tags: ['#education', '#math'],
      language: 'en',
      location: 'London, UK',
    ),
    LiveStream(
      id: 'rec2',
      title: 'What it is Replay',
      description: 'How are we to do this for you guys.',
      streamer: _users[1],
      streamUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4', // working mp4
      thumbnailUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      viewerCount: 150,
      isLive: false,
      startedAt: DateTime.now().subtract(Duration(days: 1, hours: 2)),
      categories: [_categories[2]],
      tags: ['#education', '#math'],
      language: 'en',
      location: 'London, UK',
    ),
  ];
}
