import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../groups/models/user.dart';
import '../../../../shared/utils/formatters.dart';

class PaidByScreen extends ConsumerStatefulWidget {
  final List<User> members;
  final Map<String, double> initialPayers;
  final double totalAmount;
  final String deviceOwnerId;

  const PaidByScreen({
    super.key,
    required this.members,
    required this.initialPayers,
    required this.totalAmount,
    required this.deviceOwnerId,
  });

  @override
  ConsumerState<PaidByScreen> createState() => _PaidByScreenState();
}

class _PaidByScreenState extends ConsumerState<PaidByScreen> {
  late Map<String, double> _payers;
  late Map<String, TextEditingController> _controllers;
  bool _isMultiplePayers = false;
  String? _selectedSinglePayer;

  @override
  void initState() {
    super.initState();
    _payers = Map.from(widget.initialPayers);
    _controllers = {};
    
    // Initialize controllers for all members
    for (final member in widget.members) {
      final amount = _payers[member.id] ?? 0.0;
      _controllers[member.id] = TextEditingController(
        text: amount > 0 ? amount.toStringAsFixed(2) : '',
      );
      _controllers[member.id]!.addListener(() => _updatePayers(member.id));
    }
    
    // Determine if we have multiple payers
    if (_payers.length > 1) {
      _isMultiplePayers = true;
    } else if (_payers.length == 1) {
      _selectedSinglePayer = _payers.keys.first;
    } else {
      // Default to device owner
      _selectedSinglePayer = widget.deviceOwnerId;
      _payers[widget.deviceOwnerId] = widget.totalAmount;
    }
  }

  void _updatePayers(String memberId) {
    final text = _controllers[memberId]?.text ?? '';
    if (text.isEmpty) {
      _payers.remove(memberId);
    } else {
      final amount = CurrencyFormatter.parse(text);
      if (amount > 0) {
        _payers[memberId] = amount;
      } else {
        _payers.remove(memberId);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSave() {
    if (_isMultiplePayers) {
      // Validate that payers total matches amount
      final payersTotal = _payers.values.fold(0.0, (sum, amount) => sum + amount);
      if ((payersTotal - widget.totalAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payers total must equal total amount'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    Navigator.pop(context, _payers);
  }

  @override
  Widget build(BuildContext context) {
    final currentTotal = _payers.values.fold(0.0, (sum, amount) => sum + amount);
    final remaining = widget.totalAmount - currentTotal;
    final isValid = remaining.abs() < 0.01;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Paid?'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _handleSave,
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Single or Multiple Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Single Person'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Multiple People'),
                  icon: Icon(Icons.people),
                ),
              ],
              selected: {_isMultiplePayers},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _isMultiplePayers = selection.first;
                  if (!_isMultiplePayers) {
                    // Reset to single payer
                    _payers.clear();
                    final payerId = _selectedSinglePayer ?? widget.deviceOwnerId;
                    _payers[payerId] = widget.totalAmount;
                    // Clear all controllers
                    for (final controller in _controllers.values) {
                      controller.text = '';
                    }
                  } else {
                    // Initialize with empty payers for manual entry
                    _payers.clear();
                    // Clear all controllers
                    for (final controller in _controllers.values) {
                      controller.text = '';
                    }
                  }
                });
              },
            ),
          ),

          // Remaining Amount Indicator (only for multiple payers)
          if (_isMultiplePayers) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isValid
                  ? Colors.green.withOpacity(0.1)
                  : remaining > 0
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isValid
                            ? 'All set! ✓'
                            : remaining > 0
                                ? 'Remaining to assign'
                                : 'Over the total amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: isValid
                              ? Colors.green.shade700
                              : remaining > 0
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(currentTotal),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (!isValid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: remaining > 0
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${remaining > 0 ? '+' : ''}${CurrencyFormatter.format(remaining.abs())}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final isDeviceOwner = member.id == widget.deviceOwnerId;
                
                if (_isMultiplePayers) {
                  // Multiple payers mode - show all members with input fields
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDeviceOwner ? 'You' : member.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isDeviceOwner && member.name != 'You')
                                Text(
                                  member.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 130,
                          child: TextField(
                            controller: _controllers[member.id],
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              hintText: '0.00',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Single payer mode - show radio buttons
                  return RadioListTile<String>(
                    title: Text(
                      isDeviceOwner ? 'You' : member.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: isDeviceOwner && member.name != 'You'
                        ? Text(
                            member.name,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    value: member.id,
                    groupValue: _selectedSinglePayer,
                    onChanged: (value) {
                      setState(() {
                        _selectedSinglePayer = value;
                        _payers.clear();
                        if (value != null) {
                          _payers[value] = widget.totalAmount;
                        }
                      });
                    },
                  );
                }
              },
            ),
          ),

          // Summary for multiple payers
          if (_isMultiplePayers && _payers.isNotEmpty) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
