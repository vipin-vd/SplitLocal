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
    extends ConsumerState<AppBarSearch<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _isExpanded = false;

    // Collapse when focus is lost (e.g., screen switch or tap outside)
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isExpanded) {
        if (mounted) {
          setState(() {
            _isExpanded = false;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(AppBarSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Collapse when the widget updates (e.g., screen change in navigation)
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _isExpanded = true);
    _focusNode.requestFocus();
  }

  void _collapse() {
    setState(() => _isExpanded = false);
    _focusNode.unfocus();
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
      widget.getNotifier(ref).setSearchQuery(query);
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
        } else if (_isExpanded) {
          _collapse();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuery = ref.watch(widget.queryProvider);

    ref.listen<String>(
      widget.queryProvider,
      (previous, next) {
        if (_controller.text != next) {
          _controller.text = next;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        if (next.isEmpty && _isExpanded) {
          _collapse();
        }
      },
    );

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: _isExpanded
            ? SizedBox(
                key: const ValueKey('expanded'),
                width: double.infinity,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clear,
                            tooltip: 'Clear',
                          )
                        : IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: _collapse,
                            tooltip: 'Close',
                          ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: _updateQuery,
                  onSubmitted: (_) => _focusNode.unfocus(),
                  textInputAction: TextInputAction.search,
                ),
              )
            : Align(
                key: const ValueKey('collapsed'),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: widget.semanticsLabel ?? 'Search',
                  onPressed: _expand,
                ),
              ),
      ),
    );
  }

  @override
  void deactivate() {
    if (_isExpanded) {
      _isExpanded = false;
      _focusNode.unfocus();
    }
    super.deactivate();
  }
}
