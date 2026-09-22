import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../tasks/presentation/widgets/swipeable_task_tile.dart';
import '../providers/search_filter_provider.dart';
import 'filter_sheet.dart';
import 'sort_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(filterSortProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(filterSortProvider);
    final tasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tasks, notes...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(filterSortProvider.notifier).setQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            ref.read(filterSortProvider.notifier).setQuery(val);
            setState(() {});
          },
        ),
        actions: [
          // Filter Button
          IconButton(
            icon: Badge(
              isLabelVisible: filterState.hasActiveFilters,
              child: const Icon(Icons.filter_list_rounded),
            ),
            tooltip: 'Filter',
            onPressed: () => FilterSheet.show(context),
          ),
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort',
            onPressed: () => SortSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filter chip indicators
          if (filterState.hasActiveFilters) ...[
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (filterState.priority != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Priority: ${filterState.priority!.label}'),
                        onDeleted: () => ref
                            .read(filterSortProvider.notifier)
                            .setPriority(null),
                      ),
                    ),
                  if (filterState.isCompleted != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(
                          filterState.isCompleted!
                              ? 'Completed'
                              : 'Active',
                        ),
                        onDeleted: () => ref
                            .read(filterSortProvider.notifier)
                            .setIsCompleted(null),
                      ),
                    ),
                  if (filterState.startDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: const Text('Date Filter Active'),
                        onDeleted: () => ref
                            .read(filterSortProvider.notifier)
                            .setDateRange(null, null),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Results list
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No matching tasks found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Try adjusting your search or filters'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return SwipeableTaskTile(
                      task: task,
                      onTap: () => context.push('/tasks/${task.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
