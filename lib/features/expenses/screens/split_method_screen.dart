import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/split_mode.dart';
import '../../groups/models/user.dart';
import '../../../../shared/utils/formatters.dart';

class SplitMethodScreen extends ConsumerStatefulWidget {
  final List<User> members;
  final SplitMode initialMode;
  final Map<String, double> initialSplits;
  final double totalAmount;
  final String deviceOwnerId;

  const SplitMethodScreen({
    super.key,
    required this.members,
    required this.initialMode,
    required this.initialSplits,
    required this.totalAmount,
    required this.deviceOwnerId,
  });

  @override
  ConsumerState<SplitMethodScreen> createState() => _SplitMethodScreenState();
}

class _SplitMethodScreenState extends ConsumerState<SplitMethodScreen> {
  late SplitMode _splitMode;
  late Map<String, double> _splits;
  late Set<String> _selectedMembers; // For equal split selection
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _splitMode = widget.initialMode;
    _splits = Map.from(widget.initialSplits);
    
    // Initialize selected members based on initial splits
    // Check if we have ANY data (including explicit zeros)
    final hasAnyData = widget.initialSplits.isNotEmpty;
    final hasNonZeroValues = widget.initialSplits.values.any((v) => v > 0);
    
    if (!hasAnyData || !hasNonZeroValues) {
      // No data yet - default to all members selected
      _selectedMembers = Set.from(widget.members.map((m) => m.id));
    } else {
      // We have data with some non-zero values
      // Members with value > 0 are selected, others are explicitly unselected
      _selectedMembers = widget.initialSplits.entries
          .where((e) => e.value > 0)
          .map((e) => e.key)
          .toSet();
    }
    
    // Initialize controllers for all members
    for (final member in widget.members) {
      _controllers[member.id] = TextEditingController(
        text: _splits[member.id]?.toStringAsFixed(2) ?? '0.00',
      );
    }
    
    // Only recalculate if we have no meaningful data
    if (!hasNonZeroValues) {
      _calculateSplits();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateSplits() {
    if (widget.totalAmount <= 0) return;

    switch (_splitMode) {
      case SplitMode.equal:
        // Only split among selected members
        if (_selectedMembers.isEmpty) {
          _splits.clear();
        } else {
          final perPerson = widget.totalAmount / _selectedMembers.length;
          _splits.clear();
          for (final memberId in _selectedMembers) {
            _splits[memberId] = perPerson;
            _controllers[memberId]?.text = perPerson.toStringAsFixed(2);
          }
          // Set unselected members to 0
          for (final member in widget.members) {
            if (!_selectedMembers.contains(member.id)) {
              _splits[member.id] = 0.0;
              _controllers[member.id]?.text = '0.00';
            }
          }
        }
        break;

      case SplitMode.unequal:
        // Keep existing splits or initialize to 0
        for (final member in widget.members) {
          if (!_splits.containsKey(member.id)) {
            _splits[member.id] = 0.0;
            _controllers[member.id]?.text = '0.00';
          }
        }
        break;

      case SplitMode.percent:
        // Keep existing percentages or distribute equally
        final hasValidPercentages = _splits.isNotEmpty && 
            _splits.values.any((v) => v > 0);
        
        if (!hasValidPercentages) {
          final equalPercent = 100.0 / widget.members.length;
          for (final member in widget.members) {
            _splits[member.id] = equalPercent;
            _controllers[member.id]?.text = equalPercent.toStringAsFixed(2);
          }
        }
        break;

      case SplitMode.shares:
        // Keep existing shares or set to 1 each
        final hasValidShares = _splits.isNotEmpty && 
            _splits.values.any((v) => v > 0);
        
        if (!hasValidShares) {
          for (final member in widget.members) {
            _splits[member.id] = 1.0;
            _controllers[member.id]?.text = '1';
          }
        }
        break;
    }
    
    setState(() {});
  }

  Map<String, double> _getFinalSplits() {
    final finalSplits = <String, double>{};
    
    switch (_splitMode) {
      case SplitMode.equal:
        // Include ALL members - selected get their share, unselected get 0
        // This preserves the selection state
        if (_selectedMembers.isEmpty) return {};
        final perPerson = widget.totalAmount / _selectedMembers.length;
        for (final member in widget.members) {
          if (_selectedMembers.contains(member.id)) {
            finalSplits[member.id] = perPerson;
          } else {
            finalSplits[member.id] = 0.0;
          }
        }
        break;

      case SplitMode.unequal:
        // Return the exact amounts entered (including zeros for all members)
        for (final member in widget.members) {
          finalSplits[member.id] = _splits[member.id] ?? 0.0;
        }
        break;

      case SplitMode.percent:
        // Convert percentages to amounts
        for (final member in widget.members) {
          final percent = _splits[member.id] ?? 0.0;
          finalSplits[member.id] = widget.totalAmount * (percent / 100.0);
        }
        break;

      case SplitMode.shares:
        // Convert shares to amounts
        final totalShares = _splits.values.fold(0.0, (sum, shares) => sum + shares);
        for (final member in widget.members) {
          if (totalShares > 0) {
            final shares = _splits[member.id] ?? 0.0;
            finalSplits[member.id] = widget.totalAmount * (shares / totalShares);
          } else {
            finalSplits[member.id] = 0.0;
          }
        }
        break;
    }
    
    return finalSplits;
  }

  bool _validateSplits() {
    switch (_splitMode) {
      case SplitMode.equal:
        return _selectedMembers.isNotEmpty;

      case SplitMode.unequal:
        final total = _splits.values.fold(0.0, (sum, amount) => sum + amount);
        return (total - widget.totalAmount).abs() < 0.01;

      case SplitMode.percent:
        final total = _splits.values.fold(0.0, (sum, percent) => sum + percent);
        return (total - 100.0).abs() < 0.01;

      case SplitMode.shares:
        return _splits.values.any((shares) => shares > 0);
    }
  }

  void _handleSave() {
    if (!_validateSplits()) {
      String errorMessage;
      switch (_splitMode) {
        case SplitMode.unequal:
          errorMessage = 'Amounts must add up to ${CurrencyFormatter.format(widget.totalAmount)}';
          break;
        case SplitMode.percent:
          errorMessage = 'Percentages must add up to 100%';
          break;
        case SplitMode.shares:
          errorMessage = 'At least one share must be greater than 0';
          break;
        case SplitMode.equal:
          errorMessage = 'Please select at least one person';
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = {
      'mode': _splitMode,
      'splits': _getFinalSplits(),
    };
    
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final totalSplitValue = _splits.values.fold(0.0, (sum, val) => sum + val);
    final isValid = _validateSplits();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Method'),
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
          // Split Mode Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Split By',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Equally'),
                      avatar: const Icon(Icons.people, size: 18),
                      selected: _splitMode == SplitMode.equal,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _splitMode = SplitMode.equal;
                            _calculateSplits();
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Unequally'),
                      avatar: const Icon(Icons.edit, size: 18),
                      selected: _splitMode == SplitMode.unequal,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _splitMode = SplitMode.unequal;
                            _calculateSplits();
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('By Percentage'),
                      avatar: const Icon(Icons.percent, size: 18),
                      selected: _splitMode == SplitMode.percent,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _splitMode = SplitMode.percent;
                            _calculateSplits();
                          });
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('By Shares'),
                      avatar: const Icon(Icons.pie_chart, size: 18),
                      selected: _splitMode == SplitMode.shares,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _splitMode = SplitMode.shares;
                            _calculateSplits();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Members Split List
          Expanded(
            child: ListView.builder(
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                final isDeviceOwner = member.id == widget.deviceOwnerId;
                
                if (_splitMode == SplitMode.equal) {
                  // Equal mode - show checkboxes for selection
                  final isSelected = _selectedMembers.contains(member.id);
                  
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedMembers.add(member.id);
                        } else {
                          _selectedMembers.remove(member.id);
                        }
                        _calculateSplits();
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      isDeviceOwner ? 'You' : member.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: isDeviceOwner && member.name != 'You'
                        ? Text(member.name, style: const TextStyle(fontSize: 12))
                        : null,
                  );
                }
                
                // Other modes - show input fields
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    isDeviceOwner ? 'You' : member.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: isDeviceOwner && member.name != 'You'
                      ? Text(member.name, style: const TextStyle(fontSize: 12))
                      : null,
                  trailing: SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _controllers[member.id],
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(),
                        suffix: Text(
                          _splitMode == SplitMode.percent
                              ? '%'
                              : _splitMode == SplitMode.shares
                                  ? 'shares'
                                  : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        prefix: _splitMode == SplitMode.unequal
                            ? const Text('\$ ')
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _splits[member.id] = CurrencyFormatter.parse(value);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Summary
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_splitMode == SplitMode.equal) ...[
                  // For equal split, show amount per person
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(
                          _selectedMembers.isEmpty ? 0 : widget.totalAmount / _selectedMembers.length
                        )}/person',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isValid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isValid
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          '${_selectedMembers.length} ${_selectedMembers.length == 1 ? 'person' : 'people'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isValid
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // For other modes, show total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _splitMode == SplitMode.percent
                            ? 'Total Percentage:'
                            : _splitMode == SplitMode.shares
                                ? 'Total Shares:'
                                : 'Total Amount:',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _splitMode == SplitMode.percent
                            ? '${totalSplitValue.toStringAsFixed(2)}%'
                            : _splitMode == SplitMode.shares
                                ? totalSplitValue.toStringAsFixed(0)
                                : CurrencyFormatter.format(totalSplitValue),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isValid ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      _splitMode == SplitMode.percent
                          ? 'Must equal 100%'
                          : _splitMode == SplitMode.unequal
                              ? 'Must equal ${CurrencyFormatter.format(widget.totalAmount)}'
                              : 'Invalid split',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
