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
  final CarouselController _carouselController = CarouselController(initialItem: 1);
  final HallOfFameService _service = HallOfFameService();
  late Timer _timer;
  int _currentIndex = 0;
  List<HallOfFamer> _hallOfFamers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _service.fetchHallOfFamers();
    setState(() {
      _hallOfFamers = data;
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_carouselController.hasClients && _hallOfFamers.isNotEmpty) {
        _carouselController.animateToItem(_currentIndex);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _goToNextItem();
    });
  }

  void _goToNextItem() {
    if (_hallOfFamers.isEmpty) return;
    final int totalItems = _hallOfFamers.length;
    setState(() {
      _currentIndex = (_currentIndex + 1) % totalItems;
    });
    _carouselController.animateToItem(_currentIndex);
  }

  void _goToPreviousItem() {
    if (_hallOfFamers.isEmpty) return;
    final int totalItems = _hallOfFamers.length;
    setState(() {
      _currentIndex = (_currentIndex - 1 + totalItems) % totalItems;
    });
    _carouselController.animateToItem(_currentIndex);
  }

  void _pauseAutoScroll() {
    if (!_loading && _timer.isActive) {
      _timer.cancel();
    }
  }

  void _resumeAutoScroll() {
    if (!_loading && (_hallOfFamers.isNotEmpty)) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        _goToNextItem();
      });
    }
  }

  @override
  void dispose() {
    if (!_loading) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Today Hall Of Fame",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black87),
            onPressed: (){
              //TODO: Add Location Filtering
            },
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
                    child: _hallOfFamers.isNotEmpty
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
                                    _hallOfFamers[_currentIndex].imageUrl,
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
                                        text: _hallOfFamers[_currentIndex].achievement.toUpperCase(),
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
                                          _hallOfFamers[_currentIndex].username.toUpperCase(),
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
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
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