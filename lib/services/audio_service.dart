import '../models/audio_post.dart';
import '../models/user.dart';

class AudioService {
  static final List<AudioPost> dummyAudioPosts = [
    AudioPost(
      id: 'a1',
      title: 'Chill Beats',
      description: 'Relax and enjoy these chill beats.',
      audio: AudioMedia(
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        type: 'mp3',
        duration: Duration(minutes: 5, seconds: 2),
      ),
      thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
      from: User(
        id: 1,
        username: 'audiomaster',
        password: '',
        email: 'audiomaster@example.com',
        role: 'User',
        fullName: 'Audio Master',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/10.jpg',
        createdAt: DateTime.now(),
      ),
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      initialRating: 4,
      categories: ['Music', 'Chill'],
      hashtags: ['#chill', '#beats'],
      likes: [],
      comments: [],
      location: 'Berlin, Germany',
    ),
    AudioPost(
      id: 'a2',
      title: 'Nature Sounds',
      description: 'Soothing sounds of nature for relaxation.',
      audio: AudioMedia(
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        type: 'mp3',
        duration: Duration(minutes: 6, seconds: 7),
      ),
      thumbnailUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      from: User(
        id: 2,
        username: 'naturefan',
        password: '',
        email: 'naturefan@example.com',
        role: 'User',
        fullName: 'Nature Fan',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/11.jpg',
        createdAt: DateTime.now(),
      ),
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      initialRating: 5,
      categories: ['Nature', 'Relax'],
      hashtags: ['#nature', '#relax'],
      likes: [],
      comments: [],
      location: 'Oslo, Norway',
    ),
  ];

  static Future<List<AudioPost>> fetchAudioPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyAudioPosts;
  }
}
