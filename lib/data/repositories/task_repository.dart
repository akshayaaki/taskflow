import 'package:isar/isar.dart';
import '../../core/utils/recurrence_helper.dart';
import '../../domain/models/priority_enum.dart';
import '../../domain/models/task_model.dart';
import '../local/isar_service.dart';
import '../local/models/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> watchAllTasks();
  Stream<List<TaskModel>> watchTasksByList(String listId);
  Stream<List<TaskModel>> watchTodayTasks();
  Stream<List<TaskModel>> watchUpcomingTasks();
  Stream<List<TaskModel>> watchOverdueTasks();
  Stream<List<TaskModel>> watchCompletedTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> saveTask(TaskModel task);
  Future<TaskModel?> toggleTaskCompletion(String id);
  Future<void> deleteTask(String id);
  Future<void> snoozeTask(String id, Duration duration);
  Future<void> restoreTask(TaskModel task);
  Future<List<TaskModel>> searchTasks(String query);
  Future<List<TaskModel>> filterAndSortTasks({
    String? query,
    String? listId,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'dueDate',
    bool ascending = true,
  });
}

class TaskRepositoryImpl implements TaskRepository {
  final IsarService _isarService;

  TaskRepositoryImpl(this._isarService);

  Isar get _isar => _isarService.isar;

  @override
  Stream<List<TaskModel>> watchAllTasks() {
    return _isar.taskEntitys
        .where()
        .sortByIsCompleted()
        .thenByDueDate()
        .thenByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Stream<List<TaskModel>> watchTasksByList(String listId) {
    return _isar.taskEntitys
        .filter()
        .listIdEqualTo(listId)
        .sortByIsCompleted()
        .thenByDueDate()
        .thenByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Stream<List<TaskModel>> watchTodayTasks() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _isar.taskEntitys
        .filter()
        .dueDateBetween(startOfDay, endOfDay)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .thenByPriority()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Stream<List<TaskModel>> watchUpcomingTasks() {
    final now = DateTime.now();
    final tomorrowStart =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    return _isar.taskEntitys
        .filter()
        .dueDateGreaterThan(tomorrowStart, include: true)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .thenByPriority()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Stream<List<TaskModel>> watchOverdueTasks() {
    final now = DateTime.now();

    return _isar.taskEntitys
        .filter()
        .dueDateLessThan(now)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Stream<List<TaskModel>> watchCompletedTasks() {
    return _isar.taskEntitys
        .filter()
        .isCompletedEqualTo(true)
        .sortByCompletedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    final entity =
        await _isar.taskEntitys.filter().idEqualTo(id).findFirst();
    return entity?.toDomain();
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final existing =
        await _isar.taskEntitys.filter().idEqualTo(task.id).findFirst();
    final entity = TaskEntity.fromDomain(task);
    if (existing != null) {
      entity.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.taskEntitys.put(entity);
    });
  }

  @override
  Future<TaskModel?> toggleTaskCompletion(String id) async {
    final existing =
        await _isar.taskEntitys.filter().idEqualTo(id).findFirst();
    if (existing == null) return null;

    final now = DateTime.now();
    final willComplete = !existing.isCompleted;

    existing.isCompleted = willComplete;
    existing.completedAt = willComplete ? now : null;
    existing.updatedAt = now;

    TaskEntity? nextRecurringEntity;

    // Handle Recurring Task Logic on completion
    if (willComplete) {
      final domain = existing.toDomain();
      if (domain.recurrence.isRecurring && domain.dueDate != null) {
        final nextDueDate = RecurrenceHelper.calculateNextDueDate(
          domain.dueDate!,
          domain.recurrence,
        );

        if (nextDueDate != null) {
          DateTime? nextReminder;
          if (domain.reminderDateTime != null) {
            final diff = domain.dueDate!.difference(domain.reminderDateTime!);
            nextReminder = nextDueDate.subtract(diff);
          }

          // Create next recurring instance
          final nextTask = domain.copyWith(
            id: null,
            isCompleted: false,
            clearCompletedAt: true,
            dueDate: nextDueDate,
            reminderDateTime: nextReminder,
            createdAt: now,
            updatedAt: now,
            subtasks: domain.subtasks
                .map((s) => s.copyWith(isCompleted: false))
                .toList(),
          );
          nextRecurringEntity = TaskEntity.fromDomain(
            TaskModel.create(
              title: nextTask.title,
              notes: nextTask.notes,
              dueDate: nextTask.dueDate,
              reminderDateTime: nextTask.reminderDateTime,
              priority: nextTask.priority,
              listId: nextTask.listId,
              colorTag: nextTask.colorTag,
              subtasks: nextTask.subtasks,
              recurrence: nextTask.recurrence,
              tags: nextTask.tags,
            ),
          );
        }
      }
    }

    await _isar.writeTxn(() async {
      await _isar.taskEntitys.put(existing);
      if (nextRecurringEntity != null) {
        await _isar.taskEntitys.put(nextRecurringEntity);
      }
    });

    return existing.toDomain();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _isar.writeTxn(() async {
      await _isar.taskEntitys.filter().idEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> snoozeTask(String id, Duration duration) async {
    final existing =
        await _isar.taskEntitys.filter().idEqualTo(id).findFirst();
    if (existing == null) return;

    final currentDue = existing.dueDate ?? DateTime.now();
    final newDue = currentDue.add(duration);
    existing.dueDate = newDue;
    if (existing.reminderDateTime != null) {
      existing.reminderDateTime = existing.reminderDateTime!.add(duration);
    }
    existing.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.taskEntitys.put(existing);
    });
  }

  @override
  Future<void> restoreTask(TaskModel task) async {
    await saveTask(task);
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    if (query.trim().isEmpty) return [];

    final cleanQuery = query.trim().toLowerCase();
    final entities = await _isar.taskEntitys
        .filter()
        .titleContains(cleanQuery, caseSensitive: false)
        .or()
        .notesContains(cleanQuery, caseSensitive: false)
        .findAll();

    return entities.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<TaskModel>> filterAndSortTasks({
    String? query,
    String? listId,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'dueDate',
    bool ascending = true,
  }) async {
    final entities = await _isar.taskEntitys.where().findAll();
    var models = entities.map((e) => e.toDomain()).toList();

    // Query filter
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      models = models
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.notes.toLowerCase().contains(q),
          )
          .toList();
    }

    // List filter
    if (listId != null) {
      models = models.where((t) => t.listId == listId).toList();
    }

    // Priority filter
    if (priority != null) {
      models = models.where((t) => t.priority == priority).toList();
    }

    // Completed status filter
    if (isCompleted != null) {
      models = models.where((t) => t.isCompleted == isCompleted).toList();
    }

    // Date range filter
    if (startDate != null && endDate != null) {
      models = models.where((t) {
        if (t.dueDate == null) return false;
        return (t.dueDate!.isAfter(startDate) ||
                t.dueDate!.isAtSameMomentAs(startDate)) &&
            (t.dueDate!.isBefore(endDate) ||
                t.dueDate!.isAtSameMomentAs(endDate));
      }).toList();
    } else if (startDate != null) {
      models = models.where((t) {
        if (t.dueDate == null) return false;
        return t.dueDate!.isAfter(startDate) ||
            t.dueDate!.isAtSameMomentAs(startDate);
      }).toList();
    } else if (endDate != null) {
      models = models.where((t) {
        if (t.dueDate == null) return false;
        return t.dueDate!.isBefore(endDate) ||
            t.dueDate!.isAtSameMomentAs(endDate);
      }).toList();
    }

    // Sort models
    models.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'priority':
          comparison = b.priority.weight.compareTo(a.priority.weight);
          break;
        case 'title':
          comparison =
              a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }
      return ascending ? comparison : -comparison;
    });

    return models;
  }
}
