import 'package:uuid/uuid.dart';
import 'priority_enum.dart';
import 'recurrence_model.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final DateTime? reminderDateTime;
  final TaskPriority priority;
  final String? listId;
  final int? colorTag;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<SubtaskModel> subtasks;
  final RecurrenceRule recurrence;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.notes = '',
    this.dueDate,
    this.reminderDateTime,
    this.priority = TaskPriority.medium,
    this.listId,
    this.colorTag,
    this.isCompleted = false,
    this.completedAt,
    this.subtasks = const [],
    this.recurrence = const RecurrenceRule(),
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.create({
    required String title,
    String notes = '',
    DateTime? dueDate,
    DateTime? reminderDateTime,
    TaskPriority priority = TaskPriority.medium,
    String? listId,
    int? colorTag,
    List<SubtaskModel> subtasks = const [],
    RecurrenceRule recurrence = const RecurrenceRule(),
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      notes: notes,
      dueDate: dueDate,
      reminderDateTime: reminderDateTime,
      priority: priority,
      listId: listId,
      colorTag: colorTag,
      isCompleted: false,
      completedAt: null,
      subtasks: subtasks,
      recurrence: recurrence,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
  }

  int get completedSubtasksCount =>
      subtasks.where((s) => s.isCompleted).length;

  double get subtasksProgress =>
      subtasks.isEmpty ? 0.0 : completedSubtasksCount / subtasks.length;

  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? reminderDateTime,
    bool clearReminder = false,
    TaskPriority? priority,
    String? listId,
    bool clearListId = false,
    int? colorTag,
    bool clearColorTag = false,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<SubtaskModel>? subtasks,
    RecurrenceRule? recurrence,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderDateTime:
          clearReminder ? null : (reminderDateTime ?? this.reminderDateTime),
      priority: priority ?? this.priority,
      listId: clearListId ? null : (listId ?? this.listId),
      colorTag: clearColorTag ? null : (colorTag ?? this.colorTag),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      subtasks: subtasks ?? this.subtasks,
      recurrence: recurrence ?? this.recurrence,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'priority': priority.name,
      'listId': listId,
      'colorTag': colorTag,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'recurrence': recurrence.toJson(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      reminderDateTime: json['reminderDateTime'] != null
          ? DateTime.tryParse(json['reminderDateTime'] as String)
          : null,
      priority: TaskPriority.fromString(json['priority'] as String?),
      listId: json['listId'] as String?,
      colorTag: (json['colorTag'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((s) => SubtaskModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      recurrence: json['recurrence'] != null
          ? RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>)
          : const RecurrenceRule(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
