import 'package:flutter/widgets.dart';

/// A minimal VisibilityDetector for scroll-based video activation.
/// Replace with the `visibility_detector` package for production.
class VisibilityInfo {
  final double visibleFraction;
  VisibilityInfo({required this.visibleFraction});
}

typedef VisibilityChangedCallback = void Function(VisibilityInfo info);

class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final VisibilityChangedCallback onVisibilityChanged;

  const VisibilityDetector({required this.key, required this.child, required this.onVisibilityChanged}) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyVisibility());
  }

  void _notifyVisibility() {
    // Always report fully visible for this minimal stub
    widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
