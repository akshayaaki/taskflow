import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/priority_enum.dart';
import '../../../domain/models/recurrence_model.dart';
import '../../../domain/models/subtask_model.dart';
import '../../../domain/models/task_model.dart';
import '../../lists/providers/lists_provider.dart';
import '../providers/tasks_provider.dart';
import 'widgets/recurrence_picker.dart';
import 'widgets/subtask_list_widget.dart';

class TaskEditSheet extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;
  final String? initialListId;

  const TaskEditSheet({
    super.key,
    this.taskToEdit,
    this.initialListId,
  });

  static Future<void> show(
    BuildContext context, {
    TaskModel? taskToEdit,
    String? initialListId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditSheet(
        taskToEdit: taskToEdit,
        initialListId: initialListId,
      ),
    );
  }

  @override
  ConsumerState<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends ConsumerState<TaskEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _reminderDateTime;
  late TaskPriority _priority;
  String? _selectedListId;
  int? _selectedColorTag;
  late List<SubtaskModel> _subtasks;
  late RecurrenceRule _recurrenceRule;

  bool _showRecurrenceSection = false;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _priority = task?.priority ?? TaskPriority.medium;
    _selectedListId = task?.listId ?? widget.initialListId;
    _selectedColorTag = task?.colorTag;
    _subtasks = task?.subtasks != null
        ? List<SubtaskModel>.from(task!.subtasks)
        : [];
    _recurrenceRule = task?.recurrence ?? const RecurrenceRule();
    _showRecurrenceSection = _recurrenceRule.isRecurring;

    if (task?.dueDate != null) {
      _dueDate = task!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
    }
    _reminderDateTime = task?.reminderDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? const TimeOfDay(hour: 12, minute: 0),
      );

      setState(() {
        _dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? 23,
          pickedTime?.minute ?? 59,
        );
        _dueTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();

    if (widget.taskToEdit != null) {
      final updatedTask = widget.taskToEdit!.copyWith(
        title: title,
        notes: notes,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
        reminderDateTime: _reminderDateTime,
        clearReminder: _reminderDateTime == null,
        priority: _priority,
        listId: _selectedListId,
        clearListId: _selectedListId == null,
        colorTag: _selectedColorTag,
        clearColorTag: _selectedColorTag == null,
        subtasks: _subtasks,
        recurrence: _recurrenceRule,
        updatedAt: DateTime.now(),
      );
      ref.read(taskActionsProvider).saveTask(updatedTask);
    } else {
      final newTask = TaskModel.create(
        title: title,
        notes: notes,
        dueDate: _dueDate,
        reminderDateTime: _reminderDateTime,
        priority: _priority,
        listId: _selectedListId,
        colorTag: _selectedColorTag,
        subtasks: _subtasks,
        recurrence: _recurrenceRule,
      );
      ref.read(taskActionsProvider).saveTask(newTask);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lists = ref.watch(listsStreamProvider).value ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Sheet Handle & Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                        Text(
                          widget.taskToEdit != null ? 'Edit Task' : 'New Task',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Title Field
                          TextFormField(
                            controller: _titleController,
                            autofocus: widget.taskToEdit == null,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'What needs to be done?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Task title cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Task Notes Field
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add description or notes...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Due Date & Time Picker Tile
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: const Text('Due Date & Time'),
                            subtitle: Text(
                              _dueDate == null
                                  ? 'No due date set'
                                  : DateFormatter.formatDateTime(_dueDate!),
                              style: TextStyle(
                                color: _dueDate != null
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                fontWeight: _dueDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: _dueDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      setState(() {
                                        _dueDate = null;
                                        _dueTime = null;
                                      });
                                    },
                                  )
                                : const Icon(Icons.chevron_right_rounded),
                            onTap: _pickDueDate,
                          ),
                          const Divider(),

                          // Priority Selector
                          const SizedBox(height: 10),
                          const Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: TaskPriority.values.map((p) {
                              final isSelected = _priority == p;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3.0,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(p.label),
                                    selected: isSelected,
                                    selectedColor:
                                        p.color.withValues(alpha: 0.2),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? p.color
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    avatar: Icon(
                                      p.icon,
                                      size: 14,
                                      color: isSelected
                                          ? p.color
                                          : (isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _priority = p;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),

                          // Project / List Selector
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String?>(
                            initialValue: _selectedListId,
                            decoration: InputDecoration(
                              labelText: 'List / Project',
                              prefixIcon: const Icon(Icons.folder_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No List'),
                              ),
                              ...lists.map((l) {
                                return DropdownMenuItem<String?>(
                                  value: l.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(l.colorValue),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(l.name),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedListId = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Color Tag Picker
                          const Text(
                            'Color Tag',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: AppColors.presetColors.length + 1,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // None option
                                  final isSelected = _selectedColorTag == null;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColorTag = null;
                                      });
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : (isDark
                                                  ? AppColors.darkBorder
                                                  : AppColors.lightBorder),
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.block_rounded,
                                        size: 16,
                                      ),
                                    ),
                                  );
                                }
                                final color =
                                    AppColors.presetColors[index - 1];
                                final colorVal = color.toARGB32();
                                final isSelected =
                                    _selectedColorTag == colorVal;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorTag = colorVal;
                                    });
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            )
                                          : null,
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color:
                                                color.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(),

                          // Subtasks / Checklist
                          const SizedBox(height: 10),
                          const Text(
                            'Subtasks & Checklist',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SubtaskListWidget(
                            subtasks: _subtasks,
                            onChanged: (updated) {
                              setState(() {
                                _subtasks = updated;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          const Divider(),

                          // Recurrence Section
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Recurring Task',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text('Repeat automatically'),
                            value: _showRecurrenceSection,
                            onChanged: (val) {
                              setState(() {
                                _showRecurrenceSection = val;
                                if (!val) {
                                  _recurrenceRule = const RecurrenceRule();
                                } else if (_recurrenceRule.type ==
                                    RecurrenceType.none) {
                                  _recurrenceRule = const RecurrenceRule(
                                    type: RecurrenceType.daily,
                                  );
                                }
                              });
                            },
                          ),
                          if (_showRecurrenceSection) ...[
                            const SizedBox(height: 10),
                            RecurrencePicker(
                              initialRule: _recurrenceRule,
                              onRuleChanged: (rule) {
                                setState(() {
                                  _recurrenceRule = rule;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
