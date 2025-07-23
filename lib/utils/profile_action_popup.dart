import 'package:flutter/material.dart';
import '../widgets/profile_action_popup.dart';

void showProfileActionPopup({
  required BuildContext context,
  required Offset globalPosition,
  // required VoidCallback onFavorite,
  required VoidCallback onReview,
  // required VoidCallback onFollow,
  required VoidCallback onSalute,
  required VoidCallback onPreview,
  required ValueChanged<int> onRate,
  int currentRating = 0,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  final screenSize = MediaQuery.of(context).size;
  double left = globalPosition.dx;
  double top = globalPosition.dy;
  const popupWidth = 340.0;
  const popupHeight = 210.0;

  if (left + popupWidth > screenSize.width) {
    left = screenSize.width - popupWidth - 8;
  }
  if (top + popupHeight > screenSize.height) {
    top = screenSize.height - popupHeight - 8;
  }

  entry = OverlayEntry(
    builder: (context) => GestureDetector(
      onTap: () => entry.remove(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: ProfileActionPopup(
              // onFavorite: () {
              //   entry.remove();
              //   onFavorite();
              // },
              onReview: () {
                entry.remove();
                onReview();
              },
              // onFollow: () {
              //   entry.remove();
              //   onFollow();
              // },
              onSalute: () {
                entry.remove();
                onSalute();
              },
              onRate: (rating) {
                entry.remove();
                onRate(rating);
              },
              onPreview: (){
                entry.remove();
                onPreview();
              },
              currentRating: currentRating,
            ),
          ),
        ],
      ),
    ),
  );
  overlay.insert(entry);
}
