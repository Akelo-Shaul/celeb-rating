import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/live_stream.dart';
import '../utils/live_stream_video_manager.dart';

class LiveStreamOverlay extends StatefulWidget {
  final LiveStream stream;
  final VoidCallback onClose;
  const LiveStreamOverlay({super.key, required this.stream, required this.onClose});

  @override
  State<LiveStreamOverlay> createState() => _LiveStreamOverlayState();
}

class _LiveStreamOverlayState extends State<LiveStreamOverlay> {
  late VideoPlayerController _controller;
  final videoManager = LiveStreamVideoManager();
  bool _muted = false;
  bool _showControls = true;
  final TextEditingController _chatController = TextEditingController();
  final List<String> _chatMessages = [
    'User1: Hello!',
    'User2: Welcome to the stream!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = videoManager.getController(widget.stream.streamUrl, widget.stream.id);
    _controller.setLooping(true);
    _controller.play();
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      _controller.setVolume(_muted ? 0.0 : 1.0);
    });
  }

  void _rotateAndFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _sendChat() {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _chatMessages.add('Me: $text');
        _chatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final videoHeight = mediaQuery.size.width * 9 / 16;
    final bottomPadding = mediaQuery.padding.bottom;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      top: 0,
      left: 0,
      right: 0,
      bottom: 0, // Cover the whole screen
      child: Material(
        color: Colors.black.withOpacity(0.97),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GestureDetector(
                      onTap: () => setState(() => _showControls = !_showControls),
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          if (_showControls)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                                    onPressed: _toggleMute,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cast, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.screen_rotation, color: Colors.white),
                                    onPressed: _rotateAndFullscreen,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: widget.onClose,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.stream.streamer.profileImageUrl ?? ''),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.stream.streamer.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(widget.stream.title, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Subscribe'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Follow'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, idx) => ListTile(
                      title: Text(_chatMessages[idx], style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: EdgeInsets.only(left: 8, right: 8, bottom: mediaQuery.viewInsets.bottom + bottomPadding + 4, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add to live chat...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendChat(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendChat,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
