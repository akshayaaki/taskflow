import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/remote/firestore_sync_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../lists/presentation/create_edit_list_dialog.dart';
import '../../lists/providers/lists_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/tasks_provider.dart';
import 'task_edit_sheet.dart';
import 'widgets/swipeable_task_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final syncStatus = ref.watch(syncStateProvider);

    final todayTasks = ref.watch(todayTasksStreamProvider).value ?? [];
    final overdueTasks = ref.watch(overdueTasksStreamProvider).value ?? [];
    final upcomingTasks = ref.watch(upcomingTasksStreamProvider).value ?? [];
    final completedTasks = ref.watch(completedTasksStreamProvider).value ?? [];
    final lists = ref.watch(listsStreamProvider).value ?? [];

    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    final userName = authState.user?.displayName ??
        (authState.user?.email != null
            ? authState.user!.email!.split('@').first
            : 'Productive Friend');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormatter.formatFullDate(now),
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          // Sync status button
          IconButton(
            icon: _buildSyncIcon(syncStatus),
            tooltip: _getSyncTooltip(syncStatus),
            onPressed: () {
              ref.read(syncStateProvider.notifier).syncNow();
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => TaskEditSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncStateProvider.notifier).syncNow();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Smart Views Summary Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _SmartSummaryCard(
                  title: 'Today',
                  count: todayTasks.length,
                  icon: Icons.today_rounded,
                  color: AppColors.primary,
                  onTap: () => context.push('/smart-views?tab=0'),
                ),
                _SmartSummaryCard(
                  title: 'Upcoming',
                  count: upcomingTasks.length,
                  icon: Icons.upcoming_rounded,
                  color: AppColors.info,
                  onTap: () => context.push('/smart-views?tab=1'),
                ),
                _SmartSummaryCard(
                  title: 'Overdue',
                  count: overdueTasks.length,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                  onTap: () => context.push('/smart-views?tab=2'),
                ),
                _SmartSummaryCard(
                  title: 'Completed',
                  count: completedTasks.length,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  onTap: () => context.push('/smart-views?tab=3'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Projects / Lists Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Lists',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add List'),
                  onPressed: () => CreateEditListDialog.show(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lists.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final color = Color(list.colorValue);
                  return GestureDetector(
                    onTap: () => context.push('/lists/${list.id}'),
                    child: Container(
                      width: 135,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              AppIcons.fromCodePoint(list.iconCodePoint),
                              color: color,
                              size: 18,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${list.activeTaskCount} tasks',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Today's Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (todayTasks.isNotEmpty)
                  Text(
                    '${todayTasks.length} pending',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (todayTasks.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.done_all_rounded,
                      size: 48,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All caught up for today!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to create a new task',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todayTasks.map(
                (task) => SwipeableTaskTile(
                  task: task,
                  onTap: () => context.push('/tasks/${task.id}'),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return const Icon(
          Icons.cloud_done_rounded,
          color: AppColors.success,
          size: 22,
        );
      case SyncStatus.error:
        return const Icon(
          Icons.sync_problem_rounded,
          color: AppColors.error,
          size: 22,
        );
      case SyncStatus.unauthenticated:
      case SyncStatus.idle:
        return const Icon(Icons.cloud_outlined, size: 22);
    }
  }

  String _getSyncTooltip(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing with Firestore...';
      case SyncStatus.synced:
        return 'Cloud synced';
      case SyncStatus.error:
        return 'Sync error - tap to retry';
      case SyncStatus.unauthenticated:
        return 'Guest mode (Local only) - Sign in to sync';
      case SyncStatus.idle:
        return 'Tap to sync';
    }
  }
}

class _SmartSummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmartSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: count > 0
                        ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
