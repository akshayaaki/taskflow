import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/priority_enum.dart';
import '../../lists/providers/lists_provider.dart';
import '../providers/search_filter_provider.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(filterSortProvider);
    final notifier = ref.read(filterSortProvider.notifier);
    final lists = ref.watch(listsStreamProvider).value ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (filter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    notifier.resetFilters();
                  },
                  child: const Text('Reset All'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority Filter
          const Text(
            'Priority',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: filter.priority == null,
                onSelected: (_) => notifier.setPriority(null),
              ),
              ...TaskPriority.values.map((p) {
                final isSelected = filter.priority == p;
                return FilterChip(
                  label: Text(p.label),
                  selected: isSelected,
                  selectedColor: p.color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? p.color : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    notifier.setPriority(selected ? p : null);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // List Filter
          const Text(
            'List / Project',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All Lists'),
                selected: filter.listId == null,
                onSelected: (_) => notifier.setListId(null),
              ),
              ...lists.map((l) {
                final isSelected = filter.listId == l.id;
                final color = Color(l.colorValue);
                return FilterChip(
                  label: Text(l.name),
                  selected: isSelected,
                  selectedColor: color.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    notifier.setListId(selected ? l.id : null);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Completion Status
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter.isCompleted == null,
                onSelected: (_) => notifier.setIsCompleted(null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Active'),
                selected: filter.isCompleted == false,
                onSelected: (_) => notifier.setIsCompleted(false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Completed'),
                selected: filter.isCompleted == true,
                onSelected: (_) => notifier.setIsCompleted(true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Range
          Row(
            children: [
              Expanded(
                child: Text(
                  filter.startDate == null
                      ? 'No date range'
                      : '${DateFormatter.formatShortDate(filter.startDate!)} - ${DateFormatter.formatShortDate(filter.endDate!)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.date_range_rounded, size: 16),
                label: Text(
                  filter.startDate == null ? 'Set Date Range' : 'Clear',
                ),
                onPressed: () async {
                  if (filter.startDate != null) {
                    notifier.setDateRange(null, null);
                  } else {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      notifier.setDateRange(picked.start, picked.end);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
