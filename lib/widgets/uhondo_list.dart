import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/uhondo.dart';

class TimelinePathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA726).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(10, 0)
      ..lineTo(10, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UhondoList extends StatelessWidget {
  final List<Uhondo> uhondos;
  final void Function(Uhondo)? onTap;

  const UhondoList({Key? key, required this.uhondos, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CustomPaint(
            painter: TimelinePathPainter(),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uhondos.length,
              itemBuilder: (context, index) {
                final post = uhondos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline dot
                        SizedBox(
                          width: 20,
                          child: Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFA726),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context.goNamed(
                                'webview',
                                queryParameters: {'url': post.blogLink},
                              );
                              if (onTap != null) onTap!(post);
                            },
                            child: Card(
                              elevation: 2.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and menu
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            post.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton<String>(
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
                                      ],
                                    ),
                                  ),
                                  // Image
                                  _UhondoImage(imageUrl: post.imageUrl),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UhondoImage extends StatelessWidget {
  final String imageUrl;
  const _UhondoImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.red),
          ),
        );
      },
    );
  }
}
