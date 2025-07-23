import 'dart:math';

import 'package:flutter/material.dart';

import '../models/versus_user.dart';

class HeadToHead extends StatelessWidget {
  final VersusUser user1;
  final VersusUser user2;
  const HeadToHead({Key? key, required this.user1, required this.user2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VersusUser left = user1;
    final VersusUser right = user2;

    final fields = [
      {'label': 'Age', 'key': 'age'},
      {'label': 'Spouse', 'key': 'spouse'},
      {'label': 'Children', 'key': 'children'},
      {'label': 'Profession', 'key': 'profession'},
      {'label': 'Birthplace', 'key': 'birthplace'},
      {'label': 'Net Worth', 'key': 'netWorth'},
    ];

    String getValue(VersusUser user, String key) {
      if (user.extraAttributes != null && user.extraAttributes!.containsKey(key)) {
        return user.extraAttributes![key] ?? '';
      }
      return '';
    }

    // Define a helper function to generate a slightly randomized gradient
    LinearGradient _buildRandomizedGradient(Color baseColor, {bool reverse = false}) {
      final Random random = Random();
      // Adjust opacity to reduce sharpness
      final Color startColor = baseColor.withOpacity(0.8 - (random.nextDouble() * 0.2)); // 0.6 - 0.8 opacity
      final Color endColor = baseColor.withOpacity(0.6 + (random.nextDouble() * 0.2));   // 0.6 - 0.8 opacity

      return LinearGradient(
        colors: reverse ? [endColor, startColor] : [startColor, endColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }

    // Colors for the table
    final Color leftCol = const Color(0xFF3B5E1F);
    final Color rightCol = const Color(0xFF6A1B1A);
    final Color labelCol = const Color(0xFF4B2067); // Deep purple for label
    final Color labelText = Colors.white;
    final Color leftText = Colors.white;
    final Color rightText = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Head to Head'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              // Top row: Avatars/images only
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: left.imageUrl.isNotEmpty
                          ? Image.network(
                              left.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error_outline, size: 50));
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.person, size: 50, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: right.imageUrl.isNotEmpty
                          ? Image.network(
                              right.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error_outline, size: 50));
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.person, size: 50, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Names and VS row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      left.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 80,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      right.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Table with gradient columns and alternating rows
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: List.generate(fields.length, (index) {
                        final field = fields[index];
                        final baseColor = const Color(0xFF3B5E1F); // Your original leftCol
                        final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 != 0); // Alternate gradient direction
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: gradient,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getValue(left, field['key']!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16), // White text for better contrast on gradient
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Label column
                  Container(
                    width: 110,
                    child: Column(
                      children: List.generate(fields.length, (index) {
                        final field = fields[index];
                        final baseColor = const Color(0xFF4B2067); // Your original labelCol
                        final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 == 0); // Alternate gradient direction
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: gradient,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            field['label']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16), // White text for better contrast
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Right column
                  Expanded(
                    child: Column(
                      children: List.generate(fields.length, (index) {
                        final field = fields[index];
                        final baseColor = const Color(0xFF6A1B1A); // Your original rightCol
                        final gradient = _buildRandomizedGradient(baseColor, reverse: index % 2 != 0); // Alternate gradient direction
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: gradient,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getValue(right, field['key']!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16), // White text for better contrast
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Vote buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
                  const SizedBox(width: 40),
                  Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
                ],
              ),
              const SizedBox(height: 24),
              // Star ratings
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _StarRating(rating: 4))),
                  const SizedBox(width: 40),
                  Expanded(child: Align(alignment: Alignment.center, child: _StarRating(rating: 4))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        side: const BorderSide(color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      child: const Text('VOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
          size: 22,
        );
      }),
    );
  }
}