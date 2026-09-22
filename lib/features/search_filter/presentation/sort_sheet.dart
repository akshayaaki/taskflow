import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/search_filter_provider.dart';

class SortSheet extends ConsumerWidget {
  const SortSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SortSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(filterSortProvider);
    final notifier = ref.read(filterSortProvider.notifier);

    final sortOptions = [
      {'key': 'dueDate', 'label': 'Due Date', 'icon': Icons.calendar_today_rounded},
      {'key': 'priority', 'label': 'Priority', 'icon': Icons.flag_rounded},
      {'key': 'title', 'label': 'Title (Alphabetical)', 'icon': Icons.sort_by_alpha_rounded},
      {'key': 'createdAt', 'label': 'Date Created', 'icon': Icons.access_time_rounded},
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort Tasks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  filter.ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
                tooltip: filter.ascending ? 'Ascending' : 'Descending',
                onPressed: () {
                  notifier.setSort(filter.sortBy, !filter.ascending);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortOptions.map((opt) {
            final isSelected = filter.sortBy == opt['key'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  opt['icon'] as IconData,
                  color: isSelected ? AppColors.primary : null,
                ),
                title: Text(
                  opt['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  notifier.setSort(opt['key'] as String, filter.ascending);
                  context.pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
