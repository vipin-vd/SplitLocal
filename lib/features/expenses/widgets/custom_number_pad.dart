import 'package:flutter/material.dart';

class CustomNumberPad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  const CustomNumberPad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 250 + bottomPadding,
      padding:
          EdgeInsets.only(top: 8, bottom: bottomPadding + 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withAlpha(245),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionButton(Icons.add, () => onKeyPressed('+'),
                    isPrimary: true,),
                _buildKey('.'),
                _buildKey('0'),
                _buildActionButton(Icons.backspace_outlined, onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((k) => _buildKey(k)).toList(),
      ),
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Builder(builder: (context) {
          return FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),),
              padding: EdgeInsets.zero,
              elevation: 1,
            ),
            onPressed: () => onKeyPressed(label),
            child: Text(
              label,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.normal),
            ),
          );
        },),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed,
      {bool isPrimary = false,}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Builder(builder: (context) {
          if (isPrimary) {
            return FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),),
                padding: EdgeInsets.zero,
                elevation: 1,
              ),
              onPressed: onPressed,
              child: Icon(icon, size: 28),
            );
          }
          return FilledButton.tonal(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),),
              padding: EdgeInsets.zero,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              elevation: 1,
            ),
            onPressed: onPressed,
            child: Icon(icon,
                size: 26, color: Theme.of(context).colorScheme.onSurface,),
          );
        },),
      ),
    );
  }
}
