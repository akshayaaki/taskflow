import 'package:isar/isar.dart';
import '../../../domain/models/priority_enum.dart';
import '../../../domain/models/task_model.dart';
import 'recurrence_entity.dart';
import 'subtask_entity.dart';

part 'task_entity.g.dart';

@collection
class TaskEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String title;
  late String notes;

  @Index()
  DateTime? dueDate;

  DateTime? reminderDateTime;

  late String priority;

  @Index()
  String? listId;

  int? colorTag;

  @Index()
  bool isCompleted = false;

  DateTime? completedAt;

  List<SubtaskEntity> subtasks = [];

  RecurrenceEntity recurrence = RecurrenceEntity();

  List<String> tags = [];

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  TaskModel toDomain() {
    return TaskModel(
      id: id,
      title: title,
      notes: notes,
      dueDate: dueDate,
      reminderDateTime: reminderDateTime,
      priority: TaskPriority.fromString(priority),
      listId: listId,
      colorTag: colorTag,
      isCompleted: isCompleted,
      completedAt: completedAt,
      subtasks: subtasks.map((s) => s.toDomain()).toList(),
      recurrence: recurrence.toDomain(),
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskEntity fromDomain(TaskModel model) {
    return TaskEntity()
      ..id = model.id
      ..title = model.title
      ..notes = model.notes
      ..dueDate = model.dueDate
      ..reminderDateTime = model.reminderDateTime
      ..priority = model.priority.name
      ..listId = model.listId
      ..colorTag = model.colorTag
      ..isCompleted = model.isCompleted
      ..completedAt = model.completedAt
      ..subtasks = model.subtasks.map(SubtaskEntity.fromDomain).toList()
      ..recurrence = RecurrenceEntity.fromDomain(model.recurrence)
      ..tags = List<String>.from(model.tags)
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }
}
