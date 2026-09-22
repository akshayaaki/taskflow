import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/task_model.dart';
import '../../../lists/providers/lists_provider.dart';
import '../../providers/tasks_provider.dart';
import 'task_item_card.dart';

class SwipeableTaskTile extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const SwipeableTaskTile({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsStreamProvider).value ?? [];
    final projectList = task.listId != null
        ? lists.where((l) => l.id == task.listId).firstOrNull
        : null;

    final actions = ref.read(taskActionsProvider);

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppColors.warning : AppColors.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(
              task.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Mark Incomplete' : 'Complete',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle Complete
          await actions.toggleTaskCompletion(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  task.isCompleted
                      ? 'Task marked active'
                      : 'Task completed! 🎉',
                ),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: AppColors.primaryLight,
                  onPressed: () {
                    actions.toggleTaskCompletion(task.id);
                  },
                ),
              ),
            );
          }
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          actions.deleteTask(task);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" deleted'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'UNDO',
                textColor: AppColors.primaryLight,
                onPressed: () {
                  actions.restoreTask(task);
                },
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: TaskItemCard(
          task: task,
          listName: projectList?.name,
          listColor:
              projectList != null ? Color(projectList.colorValue) : null,
          onTap: onTap,
          onToggleComplete: () async {
            await actions.toggleTaskCompletion(task.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    task.isCompleted
                        ? 'Task marked active'
                        : 'Task completed! 🎉',
                  ),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: AppColors.primaryLight,
                    onPressed: () {
                      actions.toggleTaskCompletion(task.id);
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
