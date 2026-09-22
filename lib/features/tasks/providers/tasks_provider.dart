import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../domain/models/task_model.dart';
import '../../lists/providers/lists_provider.dart';
import '../../notifications/providers/notification_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TaskRepositoryImpl(isarService);
});

final allTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAllTasks();
});

final todayTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTodayTasks();
});

final upcomingTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchUpcomingTasks();
});

final overdueTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchOverdueTasks();
});

final completedTasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchCompletedTasks();
});

final tasksByListStreamProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, listId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasksByList(listId);
});

final taskActionsProvider = Provider<TaskActions>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TaskActions(repo, notifications);
});

class TaskActions {
  final TaskRepository _repository;
  final NotificationService _notificationService;

  TaskActions(this._repository, this._notificationService);

  Future<void> saveTask(TaskModel task) async {
    await _repository.saveTask(task);

    // Update notifications
    final reminder = task.reminderDateTime ?? task.dueDate;
    if (reminder != null && !task.isCompleted) {
      await _notificationService.scheduleTaskReminder(
        taskId: task.id,
        title: task.title,
        body: task.notes.isNotEmpty ? task.notes : 'Your task is due!',
        scheduledDate: reminder,
      );
    } else {
      await _notificationService.cancelTaskReminder(task.id);
    }
  }

  Future<TaskModel?> toggleTaskCompletion(String taskId) async {
    final updatedTask = await _repository.toggleTaskCompletion(taskId);
    if (updatedTask != null) {
      if (updatedTask.isCompleted) {
        await _notificationService.cancelTaskReminder(taskId);
      } else if (updatedTask.reminderDateTime != null ||
          updatedTask.dueDate != null) {
        final reminder =
            updatedTask.reminderDateTime ?? updatedTask.dueDate!;
        await _notificationService.scheduleTaskReminder(
          taskId: updatedTask.id,
          title: updatedTask.title,
          body: updatedTask.notes.isNotEmpty
              ? updatedTask.notes
              : 'Your task is due!',
          scheduledDate: reminder,
        );
      }
    }
    return updatedTask;
  }

  Future<void> deleteTask(TaskModel task) async {
    await _repository.deleteTask(task.id);
    await _notificationService.cancelTaskReminder(task.id);
  }

  Future<void> snoozeTask(TaskModel task, Duration duration) async {
    await _repository.snoozeTask(task.id, duration);
    final reminder =
        (task.reminderDateTime ?? task.dueDate ?? DateTime.now()).add(duration);
    await _notificationService.scheduleTaskReminder(
      taskId: task.id,
      title: task.title,
      body: task.notes.isNotEmpty ? task.notes : 'Snoozed task reminder',
      scheduledDate: reminder,
    );
  }

  Future<void> restoreTask(TaskModel task) async {
    await _repository.restoreTask(task);
    final reminder = task.reminderDateTime ?? task.dueDate;
    if (reminder != null && !task.isCompleted) {
      await _notificationService.scheduleTaskReminder(
        taskId: task.id,
        title: task.title,
        body: task.notes.isNotEmpty ? task.notes : 'Your task is due!',
        scheduledDate: reminder,
      );
    }
  }
}
