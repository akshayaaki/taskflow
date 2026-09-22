import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/task_model.dart';
import '../providers/tasks_provider.dart';
import 'task_edit_sheet.dart';
import 'widgets/swipeable_task_tile.dart';

class SmartViewsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const SmartViewsScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<SmartViewsScreen> createState() => _SmartViewsScreenState();
}

class _SmartViewsScreenState extends ConsumerState<SmartViewsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayTasksAsync = ref.watch(todayTasksStreamProvider);
    final upcomingTasksAsync = ref.watch(upcomingTasksStreamProvider);
    final overdueTasksAsync = ref.watch(overdueTasksStreamProvider);
    final completedTasksAsync = ref.watch(completedTasksStreamProvider);
    final allTasksAsync = ref.watch(allTasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Views'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          tabs: [
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.today_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Today'),
                  if (todayTasksAsync.value?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                      count: todayTasksAsync.value!.length,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.upcoming_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Upcoming'),
                  if (upcomingTasksAsync.value?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                      count: upcomingTasksAsync.value!.length,
                      color: AppColors.info,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Overdue'),
                  if (overdueTasksAsync.value?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                      count: overdueTasksAsync.value!.length,
                      color: AppColors.error,
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 16),
                  const SizedBox(width: 6),
                  const Text('Completed'),
                  if (completedTasksAsync.value?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 6),
                    _CountBadge(
                      count: completedTasksAsync.value!.length,
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Row(
                children: [
                  Icon(Icons.list_alt_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('All Tasks'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => TaskEditSheet.show(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskListTab(
            tasksAsync: todayTasksAsync,
            emptyTitle: 'No tasks due today',
            emptySubtitle: 'Enjoy your free time or add a new task',
            emptyIcon: Icons.sunny,
          ),
          _TaskListTab(
            tasksAsync: upcomingTasksAsync,
            emptyTitle: 'No upcoming tasks',
            emptySubtitle: 'Plan ahead by scheduling tasks for the future',
            emptyIcon: Icons.event_available_rounded,
          ),
          _TaskListTab(
            tasksAsync: overdueTasksAsync,
            emptyTitle: 'No overdue tasks!',
            emptySubtitle: 'Great job staying on top of your schedule 🎉',
            emptyIcon: Icons.task_alt_rounded,
          ),
          _TaskListTab(
            tasksAsync: completedTasksAsync,
            emptyTitle: 'No completed tasks yet',
            emptySubtitle: 'Complete tasks to build up your productivity record',
            emptyIcon: Icons.check_circle_outline_rounded,
          ),
          _TaskListTab(
            tasksAsync: allTasksAsync,
            emptyTitle: 'No tasks found',
            emptySubtitle: 'Tap + to create your first task',
            emptyIcon: Icons.inbox_rounded,
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TaskListTab extends StatelessWidget {
  final AsyncValue<List<TaskModel>> tasksAsync;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _TaskListTab({
    required this.tasksAsync,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  emptyIcon,
                  size: 64,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
