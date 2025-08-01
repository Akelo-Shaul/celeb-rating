
import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class ProfilePreviewModalContent extends StatefulWidget {
  final String userName;
  final String userProfession;
  final String? userProfileImageUrl;
  final VoidCallback? onViewProfile;
  final Color? defaultTextColor;
  final Color? secondaryTextColor;
  final Color? appPrimaryColor;
  final Function()? onReview;
  final Function()? onShare;
  final Function()? onSalute;
  final bool isOwnProfile;

  const ProfilePreviewModalContent({
    Key? key,
    required this.userName,
    required this.userProfession,
    this.userProfileImageUrl,
    this.onViewProfile,
    this.defaultTextColor,
    this.secondaryTextColor,
    this.appPrimaryColor,
    this.onReview,
    this.onShare,
    this.onSalute,
    this.isOwnProfile = false,
  }) : super(key: key);

  @override
  State<ProfilePreviewModalContent> createState() => _ProfilePreviewModalContentState();
}

class _ProfilePreviewModalContentState extends State<ProfilePreviewModalContent> {
  bool _isSaluted = false;
  int _currentRating = 0;
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color _defaultTextColor = widget.defaultTextColor ?? (isDark ? Colors.white : Colors.black);
    final Color _secondaryTextColor = widget.secondaryTextColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final Color _appPrimaryColor = widget.appPrimaryColor ?? Theme.of(context).primaryColor;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileAvatar(radius: 30, imageUrl: widget.userProfileImageUrl ?? 'https://via.placeholder.com/150'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _defaultTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.orange, size: 18), // Added const
                    ],
                  ),
                  Text(
                    widget.userProfession,
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: widget.onViewProfile ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _appPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                localizations.viewProfile,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: _defaultTextColor.withOpacity(0.05),
                  image: DecorationImage(
                    image: NetworkImage(widget.userProfileImageUrl ?? 'https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) => const AssetImage('assets/images/profile_placeholder.png'),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!widget.isOwnProfile) ...[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _defaultTextColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentRating = index + 1;
                      _hasRated = true;
                      widget.onReview?.call();
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You rated ${widget.userName} ${index + 1} stars!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.star_rounded,
                      color: index < _currentRating ? const Color(0xFFD6AF0C) : Colors.grey[400],
                      size: 30,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _defaultTextColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  onTap: (){},
                  icon: Icons.rate_review_outlined,
                  label: _hasRated ? '$_currentRating ★' : 'Comment',
                  isActive: _hasRated,
                ),
                _ActionButton(
                  imageAsset: _isSaluted ? 'assets/icons/saluted.png' : 'assets/icons/salute.png',
                  label: _isSaluted ? 'Saluted' : 'Salute',
                  isActive: _isSaluted,
                  onTap: () {
                    setState(() {
                      _isSaluted = !_isSaluted;
                    });
                    widget.onSalute?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isSaluted ? 'Saluted ${widget.userName}' : 'Removed salute'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    widget.onShare?.call();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.copy),
                              title: const Text('Copy Link'),
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied to clipboard')),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Share Profile'),
                              onTap: () {
                                Navigator.pop(context);
                                // Implement system share
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        // ...existing code...
        if (widget.isOwnProfile) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement edit profile logic or navigation
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile tapped')),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: Text(AppLocalizations.of(context)!.edit ?? 'Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement delete profile logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete profile tapped')),
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(AppLocalizations.of(context)!.delete ?? 'Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}


class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    Key? key,
    this.icon,
    this.imageAsset,
    required this.label,
    required this.onTap,
    this.isActive = false,
  }) : assert(icon != null || imageAsset != null, 'Either icon or imageAsset must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isActive ? const Color(0xFFD6AF0C) : defaultColor,
                size: 24,
              )
            else if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: 24,
                height: 24,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFD6AF0C) : defaultColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}