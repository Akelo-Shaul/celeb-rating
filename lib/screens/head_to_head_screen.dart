import 'package:flutter/material.dart';

import '../models/versus_user.dart';

class HeadToHead extends StatelessWidget {
  final VersusUser user1;
  final VersusUser user2;

  const HeadToHead({
    super.key,
    required this.user1,
    required this.user2,
  });

  @override
  Widget build(BuildContext context) {
    // Define a consistent width for the central column elements (Vs, Rankings, etc.)
    // This width needs to accommodate the widest central element (e.g., 'Interesting')
    // and provide enough horizontal padding.
    const double centerColumnWidth = 120.0; // Adjusted for better visual alignment

    return Scaffold(
      appBar: AppBar(
        title: const Text('Head to Head'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Avatars and Names Row with 'Vs'
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _UserColumn(user: user1, type: _UserColumnType.header)),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for 'Vs' section
                    child: Center(
                      child: Text(
                        'Vs',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(child: _UserColumn(user: user2, type: _UserColumnType.header)),
                ],
              ),
              const SizedBox(height: 8),

              // First row of Vote buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
                  const SizedBox(width: centerColumnWidth), // Match center column width
                  Expanded(child: Align(alignment: Alignment.center, child: _VoteButton())),
                ],
              ),
              const SizedBox(height: 16),

              // Rankings Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user1, type: _UserColumnType.ranking))),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for StatRow
                    child: _StatRow(icon: Icons.bar_chart, label: 'Rankings', value: ''),
                  ),
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user2, type: _UserColumnType.ranking))),
                ],
              ),
              const SizedBox(height: 16),

              // Followers Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user1, type: _UserColumnType.followers))),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for StatRow
                    child: _StatRow(icon: Icons.groups, label: 'Followers', value: ''),
                  ),
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user2, type: _UserColumnType.followers))),
                ],
              ),
              const SizedBox(height: 16),

              // Flow Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user1, type: _UserColumnType.flow))),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for StatRow
                    child: _StatRow(icon: Icons.alt_route, label: 'Flow', value: ''),
                  ),
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user2, type: _UserColumnType.flow))),
                ],
              ),
              const SizedBox(height: 16),

              // Comical Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user1, type: _UserColumnType.comical))),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for StatRow
                    child: _StatRow(icon: Icons.emoji_emotions, label: 'Comical', value: ''),
                  ),
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user2, type: _UserColumnType.comical))),
                ],
              ),
              const SizedBox(height: 16),

              // Interesting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user1, type: _UserColumnType.interesting))),
                  SizedBox(
                    width: centerColumnWidth, // Use fixed width for StatRow
                    child: _StatRow(icon: Icons.interests, label: 'Interesting', value: ''),
                  ),
                  Expanded(child: Align(alignment: Alignment.center, child: _UserColumn(user: user2, type: _UserColumnType.interesting))),
                ],
              ),
              const SizedBox(height: 16),

              // Star Ratings Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Align(alignment: Alignment.center, child: _StarRating(rating: 4))),
                  const SizedBox(width: centerColumnWidth), // Match center column width
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

// Define an enum to differentiate what _UserColumn should display
enum _UserColumnType {
  header,
  ranking,
  followers,
  flow,
  comical,
  interesting,
  none, // For cases where it's just a placeholder in the Row
}

class _UserColumn extends StatelessWidget {
  final VersusUser user;
  final _UserColumnType type;

  const _UserColumn({required this.user, this.type = _UserColumnType.none});

  @override
  Widget build(BuildContext context) {
    // Only display content if it's a header or a specific stat type
    if (type == _UserColumnType.header) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.grey.withOpacity(0.18),
              backgroundImage: user.imageUrl.isNotEmpty ? NetworkImage(user.imageUrl) : null,
            ),
          ),
          // Name
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (type == _UserColumnType.ranking) {
      return Container(
        width: 70, // Fixed width to match the image
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '4.6', // Hardcoded as per image
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (type == _UserColumnType.followers) {
      return Container(
        width: 70, // Fixed width to match the image
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '34.7k', // Hardcoded as per image
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (type == _UserColumnType.flow ||
        type == _UserColumnType.comical ||
        type == _UserColumnType.interesting) {
      return _VoteButton();
    }
    return const SizedBox(width: 80); // Placeholder for alignment
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value; // Value is empty, as it's handled by _UserColumn

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // The previous horizontal padding `24.0` was part of the problem.
    // By making the parent SizedBox fixed width, the content inside this
    // _StatRow can simply be centered.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center contents vertically within its space
      children: [
        Icon(icon, size: 28, color: Colors.black),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      ],
    );
  }
}