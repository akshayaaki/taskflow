import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/date_formatter.dart';
import '../../lists/providers/lists_provider.dart';
import '../providers/tasks_provider.dart';
import 'task_edit_sheet.dart';
import 'widgets/priority_badge.dart';
import 'widgets/subtask_list_widget.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTasks = ref.watch(allTasksStreamProvider).value ?? [];
    final task = allTasks.where((t) => t.id == taskId).firstOrNull;

    final lists = ref.watch(listsStreamProvider).value ?? [];
    final projectList = (task?.listId != null)
        ? lists.where((l) => l.id == task!.listId).firstOrNull
        : null;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    final actions = ref.read(taskActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              TaskEditSheet.show(context, taskToEdit: task);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: Text(
                    'Are you sure you want to delete "${task.title}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => ctx.pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => ctx.pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await actions.deleteTask(task);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Completion Checkbox & Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => actions.toggleTaskCompletion(task.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primary
                            : task.priority.color,
                        width: 2.5,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Badges Row (Priority, List, Due Date)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                PriorityBadge(priority: task.priority),
                if (projectList != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Color(projectList.colorValue)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(projectList.colorValue)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.fromCodePoint(projectList.iconCodePoint),
                          size: 14,
                          color: Color(projectList.colorValue),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          projectList.name,
                          style: TextStyle(
                            color: Color(projectList.colorValue),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (task.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: task.isOverdue
                          ? AppColors.error.withValues(alpha: 0.15)
                          : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isOverdue
                            ? AppColors.error.withValues(alpha: 0.4)
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: task.isOverdue
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatDateTime(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: task.isOverdue
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            // Notes Section
            if (task.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  task.notes,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
            ],

            // Subtasks Section
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.subtasks.isNotEmpty)
                  Text(
                    '${task.completedSubtasksCount} of ${task.subtasks.length} completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SubtaskListWidget(
              subtasks: task.subtasks,
              isEditable: true,
              onChanged: (updatedSubtasks) {
                final updatedTask = task.copyWith(
                  subtasks: updatedSubtasks,
                  updatedAt: DateTime.now(),
                );
                actions.saveTask(updatedTask);
              },
            ),
            const SizedBox(height: 20),
            const Divider(),

            // Recurrence Details
            if (task.recurrence.isRecurring) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.repeat_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Recurring Schedule'),
                subtitle: Text(
                  task.recurrence.type.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(),
            ],

            // Created / Completed Timestamp Metadata
            const SizedBox(height: 12),
            Text(
              'Created: ${DateFormatter.formatFullDate(task.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (task.completedAt != null)
              Text(
                'Completed: ${DateFormatter.formatDateTime(task.completedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
