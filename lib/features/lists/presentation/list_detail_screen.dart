import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../tasks/presentation/task_edit_sheet.dart';
import '../../tasks/presentation/widgets/swipeable_task_tile.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../providers/lists_provider.dart';
import 'create_edit_list_dialog.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lists = ref.watch(listsStreamProvider).value ?? [];
    final projectList = lists.where((l) => l.id == listId).firstOrNull;
    final tasksAsync = ref.watch(tasksByListStreamProvider(listId));

    if (projectList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('List')),
        body: const Center(child: Text('List not found')),
      );
    }

    final listColor = Color(projectList.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: listColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.fromCodePoint(projectList.iconCodePoint),
                color: listColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(projectList.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              CreateEditListDialog.show(context, listToEdit: projectList);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: listColor,
        foregroundColor: Colors.white,
        onPressed: () {
          TaskEditSheet.show(context, initialListId: listId);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 64,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks in "${projectList.name}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to create a task for this list'),
                ],
              ),
            );
          }

          final activeTasks = tasks.where((t) => !t.isCompleted).toList();
          final completedTasks = tasks.where((t) => t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              if (activeTasks.isNotEmpty) ...[
                ...activeTasks.map(
                  (task) => SwipeableTaskTile(
                    task: task,
                    onTap: () => context.push('/tasks/${task.id}'),
                  ),
                ),
              ],
              if (completedTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Completed (${completedTasks.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                ...completedTasks.map(
                  (task) => SwipeableTaskTile(
                    task: task,
                    onTap: () => context.push('/tasks/${task.id}'),
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
