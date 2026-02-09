import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Different styles of success messages
enum SuccessMessageStyle {
  /// Bottom floating snackbar (current behavior)
  bottomSnackbar,

  /// Top floating toast - doesn't cover bottom navigation
  topToast,

  /// Material Banner below app bar
  materialBanner,

  /// Minimal - just haptic feedback + brief overlay
  minimalOverlay,
}

/// Current active style - change this to switch between styles
SuccessMessageStyle _currentStyle = SuccessMessageStyle.minimalOverlay;

/// Get/Set the current success message style
SuccessMessageStyle get currentSuccessStyle => _currentStyle;
set currentSuccessStyle(SuccessMessageStyle style) => _currentStyle = style;

/// Shows a success message using the currently selected style
void showSuccessMessage(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle,
  Duration duration = const Duration(seconds: 2),
}) {
  // Clear any existing messages first
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).clearMaterialBanners();

  switch (_currentStyle) {
    case SuccessMessageStyle.bottomSnackbar:
      _showBottomSnackbar(context, message, icon, duration);
    case SuccessMessageStyle.topToast:
      _showTopToast(context, message, icon, duration);
    case SuccessMessageStyle.materialBanner:
      _showMaterialBanner(context, message, icon, duration);
    case SuccessMessageStyle.minimalOverlay:
      _showMinimalOverlay(context, message, icon, duration);
  }
}

/// Style 1: Bottom floating snackbar (original)
void _showBottomSnackbar(
  BuildContext context,
  String message,
  IconData icon,
  Duration duration,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Style 2: Top floating toast
void _showTopToast(
  BuildContext context,
  String message,
  IconData icon,
  Duration duration,
) {
  // Add haptic feedback
  HapticFeedback.lightImpact();

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _TopToastWidget(
      message: message,
      icon: icon,
      duration: duration,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

/// Style 3: Material Banner
void _showMaterialBanner(
  BuildContext context,
  String message,
  IconData icon,
  Duration duration,
) {
  HapticFeedback.lightImpact();

  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade50,
      padding: const EdgeInsets.all(16),
      leadingPadding: EdgeInsets.zero,
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: const Text('DISMISS'),
        ),
      ],
    ),
  );

  // Auto dismiss after duration
  Future.delayed(duration, () {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  });
}

/// Style 4: Minimal overlay with haptic
void _showMinimalOverlay(
  BuildContext context,
  String message,
  IconData icon,
  Duration duration,
) {
  HapticFeedback.mediumImpact();

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _MinimalOverlayWidget(
      message: message,
      icon: icon,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

/// Top Toast Widget with animation
class _TopToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.green.shade600,
            child: InkWell(
              onTap: _dismiss,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(Icons.close, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal Overlay Widget - centered checkmark that fades
class _MinimalOverlayWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;

  const _MinimalOverlayWidget({
    required this.message,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_MinimalOverlayWidget> createState() => _MinimalOverlayWidgetState();
}

class _MinimalOverlayWidgetState extends State<_MinimalOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Increased from 800ms
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
