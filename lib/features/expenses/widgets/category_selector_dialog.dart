import 'package:flutter/material.dart';
import '../models/expense_category.dart';

class CategorySelectorDialog extends StatelessWidget {
  final ExpenseCategory currentCategory;

  const CategorySelectorDialog({
    super.key,
    required this.currentCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ExpenseCategory.values.length,
              itemBuilder: (context, index) {
                final category = ExpenseCategory.values[index];
                final isSelected = category == currentCategory;

                return ListTile(
                  leading: Icon(
                    category.icon,
                    color: category.color,
                    size: 28,
                  ),
                  title: Text(category.displayName),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  selected: isSelected,
                  onTap: () => Navigator.pop(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
