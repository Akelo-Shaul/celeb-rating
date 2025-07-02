import 'package:flutter/material.dart';

import '../models/stream_category.dart';
import '../utils/constants.dart';

class StreamCategoryCard extends StatelessWidget {
  final StreamCategory category;
  final VoidCallback? onTap;
  final ValueChanged<String>? onTagTap;

  const StreamCategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Image.network(
              category.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${formatCount(category.streamCount)} Streams',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (category.tags.isNotEmpty) ...{
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: category.tags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        onTagTap?.call(tag);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
