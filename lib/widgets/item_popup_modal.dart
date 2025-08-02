import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_fun_niche_modal.dart';
import 'add_persona_modal.dart';
import 'add_wealth_item_modal.dart';

class ItemPopupModal extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String sectionType;
  final String sectionTitle;
  final Function()? onReview;
  final Function()? onShare;
  final Function()? onSalute;
  final bool isOwnProfile;

  const ItemPopupModal({
    super.key,
    this.onReview, this.onShare, this.onSalute,
    this.isOwnProfile = false,
    required this.itemData,
    required this.sectionType, required this.sectionTitle,
  });

  @override
  State<ItemPopupModal> createState() => _ItemPopupModalState();
}

class _ItemPopupModalState extends State<ItemPopupModal> {

  bool _isSaluted = false;
  int _currentRating = 0;
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.itemData['title'] ?? widget.itemData['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: defaultTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: defaultTextColor.withOpacity(0.05),
                    image: DecorationImage(
                      image: NetworkImage(widget.itemData['imageUrl'] ?? 'https://via.placeholder.com/150'),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => const AssetImage('assets/images/profile_placeholder.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.itemData['description'] ?? widget.itemData['reason'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          if (!widget.isOwnProfile) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: defaultTextColor.withOpacity(0.05),
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
                          content: Text('You rated ${widget.itemData['title']} ${index + 1} stars!'),
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
                color: defaultTextColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    onTap: (){},
                    icon: Icons.rate_review_outlined,
                    label: _hasRated ? '$_currentRating ★' : 'Review',
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
                          content: Text(_isSaluted ? 'Saluted ${widget.itemData['title']}' : 'Removed salute'),
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

          if (widget.isOwnProfile) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        final initialData = widget.itemData;
                        final title = widget.sectionTitle;
                        if (title == AppLocalizations.of(context)!.editWealth) {
                          // Wealth modal
                          return AddWealthItemModal(
                            sectionTitle: widget.sectionTitle,
                            onAdd: (editedItem) {
                              // TODO: Update wealth entry logic here
                            },
                          );
                        } else if (title == AppLocalizations.of(context)!.editPublicPersona) {
                          // Persona modal
                          return AddPersonaModal(
                            sectionTitle: widget.sectionTitle,
                            onAdd: (editedItem) {
                              // TODO: Update persona entry logic here
                            },
                          );
                        } else {
                          // Default to fun & niche modal
                          return AddFunNicheModal(
                            sectionType: widget.sectionType,
                            initialData: initialData,
                            sectionTitle: widget.sectionTitle,
                            isEdit: true,
                            onAdd: (editedItem) {
                              // TODO: Update fun & niche entry logic here
                            },
                          );
                        }
                      },
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
      ),
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