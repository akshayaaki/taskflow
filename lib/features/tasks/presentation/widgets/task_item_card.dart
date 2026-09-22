import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/models/task_model.dart';
import 'priority_badge.dart';

class TaskItemCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final String? listName;
  final Color? listColor;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    this.listName,
    this.listColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.isOverdue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
          boxShadow: [
            if (!task.isCompleted)
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggleComplete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24,
                height: 24,
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
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

                  if (task.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Metadata Badges (Due date, Subtask progress, Priority, List, Recurrence)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Due Date Badge
                      if (task.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? AppColors.error.withValues(alpha: 0.12)
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue
                                    ? Icons.warning_amber_rounded
                                    : Icons.calendar_today_rounded,
                                size: 12,
                                color: isOverdue
                                    ? AppColors.error
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatRelative(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isOverdue
                                      ? AppColors.error
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Priority Badge
                      PriorityBadge(
                        priority: task.priority,
                        isCompact: true,
                      ),

                      // List Tag
                      if (listName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (listColor ?? AppColors.primary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: listColor ?? AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                listName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: listColor ?? AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Subtasks count
                      if (task.subtasks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${task.completedSubtasksCount}/${task.subtasks.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Recurrence Indicator
                      if (task.recurrence.isRecurring)
                        Icon(
                          Icons.repeat_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
