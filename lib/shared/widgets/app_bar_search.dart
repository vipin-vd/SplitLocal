import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic interface for search filter providers
abstract class SearchFilterNotifier<T> {
  T get state;
  String get searchQuery;
  void setSearchQuery(String query);
}

/// A modern app bar search widget that expands inline when activated.
class AppBarSearch<T extends SearchFilterNotifier>
    extends ConsumerStatefulWidget {
  final T Function(WidgetRef) getNotifier;
  final String hintText;
  final String? semanticsLabel;
  final int debounceMs;
  final ProviderListenable<String> queryProvider;

  const AppBarSearch({
    required this.getNotifier,
    required this.queryProvider,
    this.hintText = 'Search...',
    this.semanticsLabel,
    this.debounceMs = 250,
    super.key,
  });

  @override
  ConsumerState<AppBarSearch<T>> createState() => _AppBarSearchState<T>();
}

class _AppBarSearchState<T extends SearchFilterNotifier>
    extends ConsumerState<AppBarSearch<T>> with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  Timer? _debounceTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Animation setup for smooth transition
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuad,
    );

    // Sync initial state if needed, though usually starts collapsed
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _isExpanded = true);
    _animationController.forward();
    // Small delay to ensure widget is built before requesting focus
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapse() {
    if (!_isExpanded) return;

    _focusNode.unfocus();
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() => _isExpanded = false);
        _controller.clear();
        _updateQuery('');
      }
    });
  }

  void _clear() {
    _controller.clear();
    _updateQuery('');
    if (_isExpanded) {
      _focusNode.requestFocus();
    }
  }

  void _updateQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
      if (mounted) {
        widget.getNotifier(ref).setSearchQuery(query);
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isMetaF = event.logicalKey == LogicalKeyboardKey.keyF &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed);
      if (isMetaF && !_isExpanded) {
        _expand();
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_controller.text.isNotEmpty) {
          _clear();
        } else {
          _collapse();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuery = ref.watch(widget.queryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<String>(
      widget.queryProvider,
      (previous, next) {
        if (_controller.text != next) {
          _controller.text = next;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        // Removed auto-collapse on empty query
      },
    );

    // Handle back button to close search
    return PopScope(
      canPop: !_isExpanded,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _collapse();
      },
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Collapsed State (Search Icon)
              FadeTransition(
                opacity:
                    Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: widget.semanticsLabel ?? 'Search',
                    onPressed: _expand,
                  ),
                ),
              ),

              // Expanded State (Search Bar)
              SizeTransition(
                sizeFactor: _animation,
                axis: Axis.horizontal,
                axisAlignment: 1.0, // Expand from right to left
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: currentQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: _clear,
                                    tooltip: 'Clear',
                                  )
                                : null,
                          ),
                          style: theme.textTheme.bodyMedium,
                          onChanged: _updateQuery,
                          onSubmitted: (_) => _focusNode.unfocus(),
                          textInputAction: TextInputAction.search,
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                    // Close button outside the field for easier access
                    SizeTransition(
                      sizeFactor: _animation,
                      axis: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: TextButton(
                          onPressed: _collapse,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(48, 40),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
