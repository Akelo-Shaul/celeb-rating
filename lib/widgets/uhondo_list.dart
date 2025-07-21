import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../models/uhondo.dart';
import '../utils/route.dart';

class UhondoList extends StatelessWidget {
  final List<Uhondo> uhondos;
  final void Function(Uhondo)? onTap;

  const UhondoList({Key? key, required this.uhondos, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding to the Grid itself
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: (uhondos ?? []).map((post) {
            return StaggeredGridTile.fit(
              crossAxisCellCount: 1, // Each tile takes 1 column width
              child: GestureDetector(
                onTap: () async {
                  // Optionally open blog link if url_launcher is imported
                  context.go('${AppRoutes.webView}/${Uri.encodeComponent(post.blogLink)}');
                },
                child: Card(
                  elevation: 4.0,
                  clipBehavior: Clip.antiAlias, // Ensures content is clipped to card shape
                  child: Stack(
                    children: [
                      // Image (as the base layer)
                      Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.red));
                        },
                      ),
                      // Menu icon at top right
                      Positioned(
                        top: 3,
                        right: 3,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFFFFA726)),
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'why',
                              child: Text('Why am I seeing this?'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'not_interested',
                              child: Text('Not interested'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'why') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('This post is shown based on your interests.')),
                              );
                            } else if (value == 'not_interested') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('We will show you fewer posts like this.')),
                              );
                            }
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      // Title with blurred background (positioned at the bottom)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: Colors.black.withOpacity(0.45),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }


}
