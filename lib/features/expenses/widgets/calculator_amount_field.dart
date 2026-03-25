import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/utils/math_evaluator.dart';
import 'custom_number_pad.dart';

class CalculatorAmountField extends StatefulWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final VoidCallback onCurrencySelect;
  final String? Function(String?)? validator;
  final ValueChanged<bool>? onKeyboardToggle;
  final Widget? bottomSheetAccessory;

  const CalculatorAmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    required this.onCurrencySelect,
    this.validator,
    this.onKeyboardToggle,
    this.bottomSheetAccessory,
  });

  @override
  State<CalculatorAmountField> createState() => _CalculatorAmountFieldState();
}

class _CalculatorAmountFieldState extends State<CalculatorAmountField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _exprController;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _editableTextKey =
      GlobalKey(); // Preserves focus when reparenting
  String? _errorText;
  String _liveResult = '';

  OverlayEntry? _overlayEntry;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _exprController = TextEditingController(text: widget.controller.text);
    _liveResult = widget.controller.text;

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic));

    // Listen to focus changes to trigger UI updates for InputDecorator and keyboard overlay
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showKeyboard();
      } else {
        _hideKeyboard();
      }
      setState(() {});
    });
  }

  void _showKeyboard() {
    if (_overlayEntry != null) return;
    widget.onKeyboardToggle?.call(true);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.bottomSheetAccessory != null)
                  SizedBox(
                    width: double.infinity,
                    child: widget.bottomSheetAccessory!,
                  ),
                CustomNumberPad(
                  onKeyPressed: _insertText,
                  onDelete: _deleteContent,
                  onDone: () => _focusNode.unfocus(),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _animController.forward();
  }

  void _hideKeyboard() {
    if (_overlayEntry != null) {
      widget.onKeyboardToggle?.call(false);
      _animController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _animController.dispose();
    _focusNode.dispose();
    _exprController.dispose();
    super.dispose();
  }

  void _insertText(String text) {
    final textEdit = _exprController.text;
    final selection = _exprController.selection;

    // Guard against consecutive operators or decimals
    if (text == '+' || text == '.') {
      if (textEdit.isEmpty) {
        if (text == '+') return; // Don't start with +
      } else {
        int checkPos =
            selection.start > 0 ? selection.start - 1 : textEdit.length - 1;
        if (checkPos >= 0 &&
            (textEdit[checkPos] == '+' || textEdit[checkPos] == '.')) {
          return; // Ignore consecutive operators/decimals
        }
      }

      // Guard against multiple decimals in the same number segment
      if (text == '.') {
        String currentSegment = '';
        int pos =
            selection.start > 0 ? selection.start - 1 : textEdit.length - 1;
        while (pos >= 0 && textEdit[pos] != '+') {
          currentSegment = textEdit[pos] + currentSegment;
          pos--;
        }
        if (currentSegment.contains('.')) {
          return; // Already has a decimal in this segment
        }
      }
    }

    if (selection.start >= 0 && selection.end >= 0) {
      final newText =
          textEdit.replaceRange(selection.start, selection.end, text);
      _exprController.value = TextEditingValue(
        text: newText,
        selection:
            TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      final newText = textEdit + text;
      _exprController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    _onExpressionChanged(_exprController.text);
  }

  void _deleteContent() {
    final textEdit = _exprController.text;
    final selection = _exprController.selection;
    if (selection.start < 0 || selection.end < 0) return;

    if (selection.start != selection.end) {
      final newText = textEdit.replaceRange(selection.start, selection.end, '');
      _exprController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    } else if (selection.start > 0) {
      final newText =
          textEdit.replaceRange(selection.start - 1, selection.start, '');
      _exprController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    }
    _onExpressionChanged(_exprController.text);
  }

  void _onExpressionChanged(String val) {
    if (val.isEmpty) {
      _liveResult = '';
      _errorText = null;
      widget.controller.text = '';
      setState(() {});
      return;
    }

    String sanitized = val.replaceAll(RegExp(r'[^0-9+ .]'), '');

    if (val != sanitized) {
      _exprController.text = sanitized;
      _exprController.selection =
          TextSelection.collapsed(offset: sanitized.length);
    }

    final double? result = MathEvaluator.evaluate(sanitized);

    setState(() {
      if (result != null) {
        if (result > 999999999.0) {
          _errorText = 'Amount is too large';
          _liveResult = '';
          widget.controller.text = '';
        } else {
          _errorText = null;
          // Format nicely - max 2 decimals, avoiding unnecessary .00
          String formatted = result.toStringAsFixed(2);
          if (formatted.endsWith('.00')) {
            formatted = formatted.substring(0, formatted.length - 3);
          }
          _liveResult = formatted;
          widget.controller.text = formatted;
        }
      } else {
        _errorText = 'Invalid math syntax';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> field) {
        final hasError = field.hasError || _errorText != null;
        final errorMsg = _errorText ?? field.errorText;

        final hasMath = _exprController.text.contains('+');

        // The true input field that shifts location without losing focus
        final inputWidget = EditableText(
          key: _editableTextKey,
          controller: _exprController,
          focusNode: _focusNode,
          style: hasMath
              ? theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                )
              : theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
          cursorColor: theme.colorScheme.primary,
          backgroundCursorColor: Colors.grey,
          // Hide native keyboard and purely use the custom keypad
          keyboardType: TextInputType.none,
          readOnly: true,
          showCursor: true,
          enableSuggestions: false,
          autocorrect: false,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+.]')),
          ],
          textInputAction: TextInputAction.done,
          onChanged: (val) {
            _onExpressionChanged(val);
            field.didChange(widget.controller.text);
          },
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Total Amount',
                hintText: _focusNode.hasFocus ? 'e.g., 50.00' : null,
                errorText: errorMsg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                prefixIcon: InkWell(
                  onTap: widget.onCurrencySelect,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.currencySymbol,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              isFocused: _focusNode.hasFocus,
              isEmpty: _exprController.text.isEmpty,
              child: GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: hasMath
                      ? Text(
                          _exprController.text.isEmpty
                              ? '0.00'
                              : (_liveResult.isNotEmpty ? _liveResult : '...'),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: hasError
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : inputWidget,
                ),
              ),
            ),

            // Glassmorphic External Box for Math
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: hasMath
                  ? _buildGlassBox(context, inputWidget)
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassBox(BuildContext context, Widget inputWidget) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calculate_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: inputWidget),
          ],
        ),
      ),
    );
  }
}
