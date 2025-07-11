import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:celebrating/l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

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
        });
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

  @override
  void dispose() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _mediaFiles.isNotEmpty || _captionController.text.trim().isNotEmpty
                      ? () {
                    print('Caption: ${_captionController.text}');
                    print('Media Files: ${_mediaFiles.map((f) => f.path).toList()}');
                    print('Selected Categories: $_selectedCategories');
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
            AppSearchBar(
              controller: _categorySearchController,
              hintText: localizations.searchCategoryHint ?? 'Search Category...',
              onChanged: (value) {
                setState(() {
                  _categorySearch = value;
                });
              },
              onSearchPressed: () {
                setState(() {
                  _categorySearch = _categorySearchController.text;
                });
                FocusScope.of(context).unfocus();
              },
              onFilterPressed: () {
                // Implement filter logic if needed
              },
              showSearchButton: true,
              showFilterButton: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'gallery_celebrate',
                    backgroundColor: Colors.blue.withOpacity(0.13),
                    child: const Icon(Icons.local_offer, color: Colors.blue, size: 32),
                    onPressed: () {
                      print('Tag button pressed');
                    },
                    tooltip: 'Tag',
                  ),
                  FloatingActionButton(
                    heroTag: 'media_celebrate',
                    backgroundColor: Colors.orange.withOpacity(0.13),
                    child: const Icon(Icons.image, color: Colors.orange, size: 32),
                    onPressed: _showMediaPickerDialog,
                    tooltip: 'Pick from Gallery',
                  ),
                  FloatingActionButton(
                    heroTag: 'camera_celebrate',
                    backgroundColor: Colors.purple.withOpacity(0.13),
                    child: const Icon(Icons.camera_alt, color: Colors.purple, size: 32),
                    onPressed: _openCameraAndAddMedia,
                    tooltip: 'Open Camera',
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
          CameraPreview(_controller!),
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
          // New: Camera toggle button
          if (_cameras != null && _cameras!.length > 1) // Only show if multiple cameras available
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                onPressed: _isRecording ? null : _toggleCamera, // Disable if recording
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