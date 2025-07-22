import 'package:flutter/material.dart';

class ProfileActionPopup extends StatelessWidget {
  // final VoidCallback onFavorite;
  final VoidCallback onReview;
  // final VoidCallback onFollow;
  final VoidCallback onSalute;
  final ValueChanged<int> onRate;
  final int currentRating;

  const ProfileActionPopup({
    Key? key,
    // required this.onFavorite,
    required this.onReview,
    // required this.onFollow,
    required this.onSalute,
    required this.onRate,
    this.currentRating = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.97),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.thumb_up, color: Colors.white),
                SizedBox(width: 8),
                Icon(Icons.bookmark, color: Colors.white),
                SizedBox(width: 8),
                Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
            // SizedBox(height: 12),
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.symmetric(vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[900],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Center(
            //     child: GestureDetector(
            //       onTap: onFavorite,
            //       child: Text(
            //         '+ Favorite',
            //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon(
                    Icons.star,
                    color: i < currentRating ? Color(0xFFD6AF0C) : Colors.grey,
                  ),
                  onPressed: () => onRate(i + 1),
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                )),
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(icon: Icons.rate_review, label: 'Review', onTap: onReview),
                // _ActionButton(icon: Icons.bookmark, label: 'Follow', onTap: onFollow),
                _ActionButton(icon: Icons.thumb_up, label: 'Like', onTap: onSalute),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
