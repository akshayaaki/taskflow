import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/subtask_model.dart';

class SubtaskListWidget extends StatefulWidget {
  final List<SubtaskModel> subtasks;
  final ValueChanged<List<SubtaskModel>> onChanged;
  final bool isEditable;

  const SubtaskListWidget({
    super.key,
    required this.subtasks,
    required this.onChanged,
    this.isEditable = true,
  });

  @override
  State<SubtaskListWidget> createState() => _SubtaskListWidgetState();
}

class _SubtaskListWidgetState extends State<SubtaskListWidget> {
  final TextEditingController _subtaskInputController = TextEditingController();

  @override
  void dispose() {
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isEmpty) return;

    final updated = List<SubtaskModel>.from(widget.subtasks)
      ..add(
        SubtaskModel.create(
          title: text,
          orderIndex: widget.subtasks.length,
        ),
      );

    _subtaskInputController.clear();
    widget.onChanged(updated);
  }

  void _toggleSubtask(int index) {
    final updated = List<SubtaskModel>.from(widget.subtasks);
    final current = updated[index];
    updated[index] = current.copyWith(isCompleted: !current.isCompleted);
    widget.onChanged(updated);
  }

  void _deleteSubtask(int index) {
    final updated = List<SubtaskModel>.from(widget.subtasks)..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.subtasks.isNotEmpty) ...[
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.subtasks.isEmpty
                  ? 0
                  : widget.subtasks.where((s) => s.isCompleted).length /
                      widget.subtasks.length,
              minHeight: 6,
              backgroundColor: isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.subtasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final subtask = widget.subtasks[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleSubtask(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: subtask.isCompleted
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: subtask.isCompleted
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                            width: 2,
                          ),
                        ),
                        child: subtask.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: subtask.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: subtask.isCompleted
                              ? (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                    if (widget.isEditable)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => _deleteSubtask(index),
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        if (widget.isEditable)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskInputController,
                  decoration: InputDecoration(
                    hintText: 'Add a subtask...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    prefixIcon: const Icon(Icons.add_task_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _addSubtask,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
