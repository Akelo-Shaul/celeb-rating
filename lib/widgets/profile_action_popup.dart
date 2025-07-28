import 'package:flutter/material.dart';

class ProfileActionPopup extends StatefulWidget {
  // final VoidCallback onFavorite;
  final VoidCallback onReview;
  // final VoidCallback onFollow;
  final VoidCallback onSalute;
  final VoidCallback onPreview;
  final ValueChanged<int> onRate;
  final int currentRating;

  const ProfileActionPopup({
    Key? key,
    // required this.onFavorite,
    required this.onReview,
    // required this.onFollow,
    required this.onSalute,
    required this.onPreview,
    required this.onRate,
    this.currentRating = 0,
  }) : super(key: key);

  @override
  State<ProfileActionPopup> createState() => _ProfileActionPopupState();
}

class _ProfileActionPopupState extends State<ProfileActionPopup> {
  bool _isSaluted = false;

  @override
  void initState() {
    super.initState();
    // Initialize salute state - you can add logic here to check if user has already saluted
    _isSaluted = false;
  }

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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSaluted = !_isSaluted;
                    });
                    widget.onSalute();
                  },
                  child: Image.asset(
                    _isSaluted ? 'assets/icons/saluted.png' : 'assets/icons/salute.png',
                    width: 24,
                    height: 24,
                  ),
                ),
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
                     color: i < widget.currentRating ? Color(0xFFD6AF0C) : Colors.grey,
                   ),
                   onPressed: () => widget.onRate(i + 1),
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
                _ActionButton(icon: Icons.rate_review, label: 'Review', onTap: widget.onReview),
                _ActionButton(icon: Icons.preview, label: 'Preview', onTap: widget.onPreview),
                _ActionButton(
                  imageAsset: _isSaluted ? 'assets/icons/saluted.png' : 'assets/icons/salute.png', 
                  label: 'Salute', 
                  onTap: () {
                    setState(() {
                      _isSaluted = !_isSaluted;
                    });
                    widget.onSalute();
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final String label;
  final VoidCallback onTap;
  
  const _ActionButton({
    this.icon,
    this.imageAsset,
    required this.label,
    required this.onTap,
  }) : assert(icon != null || imageAsset != null, 'Either icon or imageAsset must be provided');
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          if (icon != null)
            Icon(icon, color: Colors.white)
          else if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: 24,
              height: 24,
            ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
