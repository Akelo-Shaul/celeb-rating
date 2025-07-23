import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:celebrating/l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../models/user.dart';
import '../services/search_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_search_bar.dart'; // Import your AppSearchBar here

class CelebratePage extends StatefulWidget {
  const CelebratePage({super.key});
  @override
  State<CelebratePage> createState() => _CelebratePageState();
}

class _CelebratePageState extends State<CelebratePage> {
  int _selectedIndex = 1; // Default to "Celebrate" as selected
  List<String> _localizedTabs(BuildContext context) => [
    AppLocalizations.of(context)!.flick,
    AppLocalizations.of(context)!.celebrate,
    AppLocalizations.of(context)!.stream,
    AppLocalizations.of(context)!.audio,
  ];
  String _categorySearch = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white, // Or your background
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCustomTabBar(context, isDark),
              const SizedBox(height: 40),
              Expanded(
                child: _buildTabView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context, bool isDark) {
    final tabs = _localizedTabs(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final bool selected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                    ? Colors.black.withOpacity(0.18)
                    : Colors.grey.shade400.withOpacity(0.38))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: Colors.black.withOpacity(selected ? 0.85 : 0.7),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabView() {
    switch (_selectedIndex) {
      case 0:
        return _flicksCelebrateTab();
      case 1:
        return _celebrateTab();
      case 2:
        return _streamCelebrateTab();
      case 3:
        return audioCelebrateTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _flicksCelebrateTab() {
    return _FlicksCameraTab();
  }
}

class _FlicksCameraTab extends StatefulWidget {
  @override
  State<_FlicksCameraTab> createState() => _FlicksCameraTabState();
}

class _FlicksCameraTabState extends State<_FlicksCameraTab> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Handle camera error
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController != null && !_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {}
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null && _isRecording) {
      try {
        final file = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _videoFile = file; // Set the recorded video for preview
        });
        // Dispose camera before playing video
        await _cameraController?.dispose();
        _cameraController = null;
        // Add a short delay to ensure file is ready
        await Future.delayed(const Duration(milliseconds: 300));
        _playVideo(file.path);
      } catch (e) {}
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _videoFile = picked;
      });
      _playVideo(picked.path);
    }
  }

  void _playVideo(String path) {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(path))
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  void _goToFlicksPostScreen() async {
    if (_videoFile != null && File(_videoFile!.path).existsSync()) {
      // Dispose camera before navigating
      await _cameraController?.dispose();
      _cameraController = null;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FlicksPostScreen(videoFile: _videoFile!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video to preview.')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_videoFile == null)
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : Container(color: Colors.black),
        if (_videoFile != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
        // Top-right Next button after video is selected or recorded
        if (_videoFile != null)
          Positioned(
            top: 40,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6AF0C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: _goToFlicksPostScreen,
              child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'gallery',
                backgroundColor: Colors.black54,
                child: const Icon(Icons.video_library, color: Colors.white),
                onPressed: _pickVideoFromGallery,
                tooltip: 'Pick Video from Gallery',
              ),
              FloatingActionButton(
                heroTag: 'record',
                backgroundColor: _isRecording ? Colors.red : Colors.black54,
                child: Icon(_isRecording ? Icons.stop : Icons.videocam, color: Colors.white),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                tooltip: _isRecording ? 'Stop Recording' : 'Record Video',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _celebrateTab() {
  return _CelebratePostTab();
}

class _CelebratePostTab extends StatefulWidget {
  @override
  State<_CelebratePostTab> createState() => _CelebratePostTabState();
}

class _CelebratePostTabState extends State<_CelebratePostTab> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();
  String _categorySearch = '';
  List<String> _categories = [];
  final List<String> _selectedCategories = [];
  List<XFile> _mediaFiles = [];
  List<bool> _isVideoList = [];

  // Tag user search variables
  List<User> _filteredUsers = [];
  bool _isLoadingUsers = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_onCaptionChanged);
  }

  void _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoadingUsers = true;
    });
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
        _isLoadingUsers = false;
      });
      return;
    }
    final users = await SearchService.searchUsers(query);
    setState(() {
      _filteredUsers = users;
      _isLoadingUsers = false;
    });
  }

  void _onCaptionChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _captionController.removeListener(_onCaptionChanged);
    _captionController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _showMediaPickerDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.addImages),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final images = await picker.pickMultiImage();
                if (images != null && images.isNotEmpty) {
                  setState(() {
                    _mediaFiles.addAll(images);
                    _isVideoList.addAll(List.filled(images.length, false));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(AppLocalizations.of(context)!.addVideo),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final video = await picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  setState(() {
                    _mediaFiles.add(video);
                    _isVideoList.add(true);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _getVideoThumbnail(String path) async {
    return await vt.VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: vt.ImageFormat.PNG,
      maxWidth: 120,
      quality: 60,
    );
  }

  Future<void> _openTagScreen() async {
    setState(() {
      _filteredUsers = [];
      _isLoadingUsers = false;
      _searchQuery = '';
    });
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: TagUserSearch(scrollController: scrollController),
            );
          },
        );
      },
    );
  }

  Future<void> _openCameraAndAddMedia() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraCapturePage()),
    );
    if (result != null && result['file'] != null) {
      setState(() {
        _mediaFiles.add(result['file']);
        _isVideoList.add(result['isVideo'] ?? false);
      });
    }
  }

  // New method to show media preview
  void _showMediaPreview(XFile file, bool isVideo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(file: file, isVideo: isVideo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Initialize _categories with localized values if empty
    if (_categories.isEmpty) {
      _categories = [
        localizations.lifestyle,
        localizations.fashionStyle,
        localizations.artCollection,
        localizations.cars,
        localizations.houses,
        localizations.wealthTab,
        localizations.careerTab,
        localizations.personalTab,
        localizations.publicPersonaTab,
        localizations.family,
      ];
    }
    final filtered = _categorySearch.isEmpty
        ? _categories
        : _categories.where((c) => c.toLowerCase().contains(_categorySearch.toLowerCase())).toList();
    final mid = (filtered.length / 2).ceil();
    final firstLine = filtered.take(mid).toList();
    final secondLine = filtered.skip(mid).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (_mediaFiles.isNotEmpty || _captionController.text.trim().isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('Caption: ${_captionController.text}');
                      print('Media Files: ${_mediaFiles.map((f) => f.path).toList()}');
                      print('Selected Categories: $_selectedCategories');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD6AF0C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    child: Text(localizations.post, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_mediaFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _mediaFiles.length,
                            itemBuilder: (context, idx) {
                        final file = _mediaFiles[idx];
                        final isVideo = _isVideoList[idx];
                              return Stack(
                            alignment: Alignment.topRight,
                            children: [
                                  // Wrap the media display with GestureDetector for preview
                              GestureDetector(
                                onTap: () => _showMediaPreview(file, isVideo),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                  child: isVideo
                                      ? FutureBuilder<Uint8List?>(
                                    future: _getVideoThumbnail(file.path),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 180,
                                            ),
                                                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                                          ],
                                        );
                                      } else {
                                        return Container(
                                                width: 120,
                                                height: 180,
                                          color: Colors.black12,
                                          child: const Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                    },
                                  )
                                      : Image.file(
                                    File(file.path),
                                    fit: BoxFit.cover,
                                          width: 120,
                                          height: 180,
                                  ),
                                ),
                              ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.red, size: 28),
                                    onPressed: () {
                                      setState(() {
                                        _mediaFiles.removeAt(idx);
                                        _isVideoList.removeAt(idx);
                                      });
                                    },
                                    tooltip: 'Remove',
                                  ),
                                ],
                              );
                            },
                ),
              ),
            ),
            Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: localizations.captionHint ?? 'What is on your mind?',
                          hintStyle: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _categorySearchController,
                obscureText: true,
                decoration: InputDecoration(labelText: localizations.searchCategoryHint,labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (value) {
                      setState(() {
                        _categorySearch = value;
                      });
                    },
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                  children: firstLine.map((cat) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedCategories.contains(cat)) {
                              _selectedCategories.remove(cat);
                            } else {
                              _selectedCategories.add(cat);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Chip(
                            label: Text(cat),
                            backgroundColor: _selectedCategories.contains(cat)
                            ? Colors.amber.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'gallery_pick',
                    backgroundColor: Colors.white,
                    // Not mini, so it's larger
                    mini: true,
                    onPressed: _openCameraAndAddMedia,
                    tooltip: 'Pick from Gallery',
                    child: const Icon(Icons.photo_library, size: 25, color: Color(0xFFD6AF0C)),
                  ),
                  FloatingActionButton(
                    heroTag: 'tag_users',
                    backgroundColor: Colors.white,
                    // Not mini, so it's larger
                    mini: true,
                    onPressed: _openTagScreen, //TODO: Implement function to Navigate to a new screen where user can search and tag users
                    tooltip: 'Tag Users',
                    child: const Icon(Icons.local_offer, size: 25, color: Color(0xFFD6AF0C)),
            ),
              ],
            ),
          ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}


class CameraCapturePage extends StatefulWidget {
  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  Future<void> _pickFromGallery() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Image'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Pick Video'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );
    if (result == 'image') {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        Navigator.pop(context, {'file': image, 'isVideo': false});
      }
    } else if (result == 'video') {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        Navigator.pop(context, {'file': video, 'isVideo': true});
      }
    }
  }
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isCameraReady = false;
  int _selectedCameraIndex = 0; // New: To keep track of the selected camera index

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Initialize with the selected camera
        _controller = CameraController(_cameras![_selectedCameraIndex], ResolutionPreset.high);
        await _controller!.initialize();
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print("Error initializing camera: $e");
      // Handle camera error (e.g., show a message to the user)
    }
  }

  // New: Function to toggle between front and back cameras
  Future<void> _toggleCamera() async {
    // Cannot toggle if no cameras, only one camera, or currently recording
    if (_cameras == null || _cameras!.length <= 1 || _isRecording) {
      return;
    }

    setState(() {
      _isCameraReady = false; // Set to false while camera is re-initializing
    });

    // Dispose the current controller
    await _controller?.dispose();

    // Toggle camera index
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

    // Re-initialize camera with the new index
    await _initCamera();
  }

  Future<void> _takePhoto() async {
    if (!_isRecording && _controller != null && _controller!.value.isInitialized) {
      try {
        final file = await _controller!.takePicture();
        if (mounted) {
          Navigator.pop(context, {'file': file, 'isVideo': false});
        }
      } catch (e) {
        print("Error taking photo: $e");
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller != null && !_isRecording && _controller!.value.isInitialized) {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print("Error starting video recording: $e");
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller != null && _isRecording) {
      try {
        final file = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        if (mounted) {
          Navigator.pop(context, {'file': file, 'isVideo': true});
        }
      } catch (e) {
        print("Error stopping video recording: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraReady && _controller != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                // Single gallery pick button
                Positioned(
                  bottom: 40,
                  left: 30,
                  child: FloatingActionButton(
                    heroTag: 'gallery_pick',
                    backgroundColor: Colors.white,
                    // Not mini, so it's larger
                    onPressed: _pickFromGallery,
                    tooltip: 'Pick from Gallery',
                    child: const Icon(Icons.photo_library, size: 38, color: Color(0xFFD6AF0C)),
                  ),
                ),
                // Camera capture button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: GestureDetector(
                      onTap: () {
                        if (_isRecording) {
                          _stopVideoRecording();
                        } else {
                          _takePhoto();
                        }
                      },
                      onLongPress: () {
                        if (!_isRecording) {
                          _startVideoRecording();
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.camera_alt,
                          color: _isRecording ? Colors.white : Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () {
                      if (_isRecording) {
                        _stopVideoRecording();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                // Camera toggle button
                if (_cameras != null && _cameras!.length > 1)
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                      onPressed: _isRecording ? null : _toggleCamera,
                      tooltip: 'Toggle Camera',
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}


// New MediaPreviewScreen Widget
class MediaPreviewScreen extends StatefulWidget {
  final XFile file;
  final bool isVideo;

  const MediaPreviewScreen({
    Key? key,
    required this.file,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoPlayerController = VideoPlayerController.file(File(widget.file.path));
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize().then((_) {
        _videoPlayerController!.setLooping(true); // Loop video
        _videoPlayerController!.play(); // Play video
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose(); // Dispose video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full screen preview on black background
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: widget.isVideo
            ? FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              );
            } else {
              // You can customize this loading indicator
              return const CircularProgressIndicator(color: Colors.white);
            }
          },
        )
            : Image.file(
          File(widget.file.path),
          fit: BoxFit.contain, // Fit entire image without cropping
        ),
      ),
    );
  }
}

// Reusable widget for tagging users
class TagUserSearch extends StatefulWidget {
  final void Function(User user)? onUserTag;
  final String? inviteLabel;
  final String? tagLabel;
  final String? notFoundLabel;
  final String? searchHint;
  final ScrollController? scrollController;
  const TagUserSearch({
    Key? key,
    this.onUserTag,
    this.inviteLabel,
    this.tagLabel,
    this.notFoundLabel,
    this.searchHint,
    this.scrollController,
  }) : super(key: key);

  @override
  State<TagUserSearch> createState() => _TagUserSearchState();
}

class _TagUserSearchState extends State<TagUserSearch> {
  List<User> _filteredUsers = [];
  bool _isLoadingUsers = false;
  String _searchQuery = '';

  void _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoadingUsers = true;
    });
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
        _isLoadingUsers = false;
      });
      return;
    }
    final users = await SearchService.searchUsers(query);
    setState(() {
      _filteredUsers = users;
      _isLoadingUsers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inviteLabel = widget.inviteLabel ?? localizations.invite;
    final tagLabel = widget.tagLabel ?? localizations.tag;
    final notFoundLabel = widget.notFoundLabel ?? localizations.notFound;
    final searchHint = widget.searchHint ?? localizations.searchByNameOrUsername;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 12.0),
          child: TextField(
            style: const TextStyle(
              color: Colors.grey, // Example: Dark purple text
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _searchQuery.isEmpty
                  ? Center(child: Text(localizations.searchByNameOrUsername, style: const TextStyle(color: Colors.grey)))
                  : _filteredUsers.isEmpty
                      ? Center(child: Text(notFoundLabel, style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: widget.scrollController,
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null,
                                child: user.profileImageUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(user.fullName, style: TextStyle(color: Colors.black),),
                              subtitle: Text('@${user.username}', style: TextStyle(color: Colors.black)),
                              trailing: SizedBox(
                                width: 110,
                                child: AppButton(
                                  text: tagLabel,
                                  icon: Icons.person_add,
                                  onPressed: widget.onUserTag != null ? () => widget.onUserTag!(user) : null,
                                  backgroundColor: const Color(0xFFD6AF0C),
                                  textColor: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

// New: FlicksPostScreen for adding caption and tagging people after video selection
class FlicksPostScreen extends StatefulWidget {
  final XFile videoFile;
  const FlicksPostScreen({Key? key, required this.videoFile}) : super(key: key);

  @override
  State<FlicksPostScreen> createState() => _FlicksPostScreenState();
}

class _FlicksPostScreenState extends State<FlicksPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _categorySearchController = TextEditingController();
  String _categorySearch = '';
  List<String> _categories = [];
  final List<String> _selectedCategories = [];
  final List<User> _taggedUsers = [];

  @override
  void dispose() {
    _captionController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _openTagScreen() async {
    final User? tagged = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: TagUserSearch(
                scrollController: scrollController,
                onUserTag: (user) {
                  Navigator.of(context).pop(user);
                },
              ),
            );
          },
        );
      },
    );
    if (tagged != null && !_taggedUsers.any((u) => u.id == tagged.id)) {
      setState(() {
        _taggedUsers.add(tagged);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Initialize _categories with localized values if empty
    if (_categories.isEmpty) {
      _categories = [
        localizations.lifestyle,
        localizations.fashionStyle,
        localizations.artCollection,
        localizations.cars,
        localizations.houses,
        localizations.wealthTab,
        localizations.careerTab,
        localizations.personalTab,
        localizations.publicPersonaTab,
        localizations.family,
      ];
    }
    final filtered = _categorySearch.isEmpty
        ? _categories
        : _categories.where((c) => c.toLowerCase().contains(_categorySearch.toLowerCase())).toList();
    final mid = (filtered.length / 2).ceil();
    final firstLine = filtered.take(mid).toList();
    final secondLine = filtered.skip(mid).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(localizations.flick),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Handle post action
              print('Caption:  [${_captionController.text}]');
              print('Video File:  [${widget.videoFile.path}]');
              print('Selected Categories: $_selectedCategories');
              print('Tagged Users: ${_taggedUsers.map((u) => u.username).toList()}');
            },
            child: Text(localizations.post, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video preview
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: AspectRatio(
                      aspectRatio: 12 / 9,
                      child: VideoPlayerWidget(file: widget.videoFile),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Caption input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: localizations.captionHint ?? 'What is on your mind?',
                      hintStyle: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                // Category search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _categorySearchController,
                    decoration: InputDecoration(
                      labelText: localizations.searchCategoryHint,
                      labelStyle: const TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _categorySearch = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Category chips (first line)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: firstLine.map((cat) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedCategories.contains(cat)) {
                              _selectedCategories.remove(cat);
                            } else {
                              _selectedCategories.add(cat);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Chip(
                            label: Text(cat),
                            backgroundColor: _selectedCategories.contains(cat)
                                ? Colors.amber.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Category chips (second line, if any)
                if (secondLine.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: secondLine.map((cat) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedCategories.contains(cat)) {
                                _selectedCategories.remove(cat);
                              } else {
                                _selectedCategories.add(cat);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Chip(
                              label: Text(cat),
                              backgroundColor: _selectedCategories.contains(cat)
                                  ? Colors.amber.withOpacity(0.7)
                                  : Colors.grey.withOpacity(0.13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Tag users chips
                if (_taggedUsers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      spacing: 6,
                      children: _taggedUsers.map((user) => Chip(
                        label: Text('@${user.username}'),
                        onDeleted: () {
                          setState(() {
                            _taggedUsers.removeWhere((u) => u.id == user.id);
                          });
                        },
                      )).toList(),
                    ),
                  ),
                // Tag users button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: 'tag_users',
                        backgroundColor: Colors.white,
                        mini: true,
                        onPressed: _openTagScreen,
                        tooltip: 'Tag Users',
                        child: const Icon(Icons.local_offer, size: 25, color: Color(0xFFD6AF0C)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for video preview in FlicksPostScreen
class VideoPlayerWidget extends StatefulWidget {
  final XFile file;
  const VideoPlayerWidget({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path));
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      _controller!.setLooping(true);
      _controller!.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Widget _streamCelebrateTab() {
  return Builder(
    builder: (context) => Center(child: Text(AppLocalizations.of(context)!.streamTab)),
  );
}

Widget audioCelebrateTab() {
  return Builder(
    builder: (context) => Center(child: Text(AppLocalizations.of(context)!.audioTab)),
  );
}
