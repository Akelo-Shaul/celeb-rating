import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color indicatorColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    final Color selectedIconColor = Theme.of(context).colorScheme.primary;
    final Color unselectedIconColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color selectedLabelColor = isDark ? Colors.white : Colors.black;
    final Color unselectedLabelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final localizations = AppLocalizations.of(context)!;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: indicatorColor,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: selectedLabelColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            } else {
              return TextStyle(
                color: unselectedLabelColor,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              );
            }
          },
        ),
      ),
      child: NavigationBar(
        height: 64,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: unselectedIconColor),
            selectedIcon: Icon(Icons.home, color: selectedIconColor),
            // label: localizations.home,
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, color: unselectedIconColor),
            selectedIcon: Icon(Icons.search, color: selectedIconColor),
            // label: localizations.search,
            label: 'Search'
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined, color: unselectedIconColor),
            selectedIcon: Icon(Icons.add_box, color: selectedIconColor),
            // label: localizations.celebrate,
            label: 'Celebrate'
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined, color: unselectedIconColor),
            selectedIcon: Icon(Icons.movie, color: selectedIconColor),
            // label: localizations.flick,
            label: 'Flick'
          ),
          NavigationDestination(
            icon: Icon(Icons.live_tv_outlined, color: unselectedIconColor),
            selectedIcon: Icon(Icons.live_tv, color: selectedIconColor),
            // label: localizations.stream,
            label: 'Stream'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: unselectedIconColor),
            selectedIcon: Icon(Icons.person, color: selectedIconColor),
            // label: localizations.profile,
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
