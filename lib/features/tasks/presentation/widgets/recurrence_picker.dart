import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/recurrence_model.dart';

class RecurrencePicker extends StatefulWidget {
  final RecurrenceRule initialRule;
  final ValueChanged<RecurrenceRule> onRuleChanged;

  const RecurrencePicker({
    super.key,
    required this.initialRule,
    required this.onRuleChanged,
  });

  @override
  State<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends State<RecurrencePicker> {
  late RecurrenceType _selectedType;
  late int _interval;
  late List<int> _daysOfWeek;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialRule.type;
    _interval = widget.initialRule.interval;
    _daysOfWeek = List<int>.from(widget.initialRule.daysOfWeek);
    _endDate = widget.initialRule.endDate;
  }

  void _notifyChange() {
    final updated = RecurrenceRule(
      type: _selectedType,
      interval: _interval,
      daysOfWeek: _daysOfWeek,
      endDate: _endDate,
    );
    widget.onRuleChanged(updated);
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_daysOfWeek.contains(day)) {
        _daysOfWeek.remove(day);
      } else {
        _daysOfWeek.add(day);
        _daysOfWeek.sort();
      }
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const weekdaysLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<RecurrenceType>(
          initialValue: _selectedType,
          decoration: InputDecoration(
            labelText: 'Repeat',
            prefixIcon: const Icon(Icons.repeat_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: RecurrenceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedType = val;
              });
              _notifyChange();
            }
          },
        ),

        // If Weekly or Custom, show weekday chips
        if (_selectedType == RecurrenceType.weekly ||
            _selectedType == RecurrenceType.custom) ...[
          const SizedBox(height: 16),
          Text(
            'Repeat On',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1; // 1 = Mon, 7 = Sun
              final isSelected = _daysOfWeek.contains(dayIndex);
              return GestureDetector(
                onTap: () => _toggleWeekday(dayIndex),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      weekdaysLabels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],

        // If Custom interval
        if (_selectedType == RecurrenceType.custom) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Every'),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: TextFormField(
                  initialValue: _interval.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      _interval = parsed;
                      _notifyChange();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Text('days'),
            ],
          ),
        ],

        // Optional End Date
        if (_selectedType != RecurrenceType.none) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _endDate == null
                      ? 'Never ends'
                      : 'Ends on: ${DateFormatter.formatShortDate(_endDate!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              TextButton.icon(
                icon: Icon(
                  _endDate == null
                      ? Icons.event_rounded
                      : Icons.close_rounded,
                  size: 16,
                ),
                label: Text(_endDate == null ? 'Set End Date' : 'Clear'),
                onPressed: () async {
                  if (_endDate != null) {
                    setState(() {
                      _endDate = null;
                    });
                    _notifyChange();
                  } else {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                      _notifyChange();
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
