import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/domain/models/priority_enum.dart';
import 'package:my_todo_app/domain/models/project_list_model.dart';
import 'package:my_todo_app/domain/models/recurrence_model.dart';
import 'package:my_todo_app/domain/models/subtask_model.dart';
import 'package:my_todo_app/domain/models/task_model.dart';
import 'package:my_todo_app/core/utils/date_formatter.dart';
import 'package:my_todo_app/core/utils/recurrence_helper.dart';

void main() {
  group('TaskModel Domain Tests', () {
    test('Task creation and properties', () {
      final task = TaskModel.create(
        title: 'Complete project proposal',
        notes: 'Include budget breakdown',
        priority: TaskPriority.urgent,
        listId: 'work-list',
        subtasks: [
          SubtaskModel.create(title: 'Draft proposal'),
          SubtaskModel.create(title: 'Review numbers'),
        ],
      );

      expect(task.title, 'Complete project proposal');
      expect(task.priority, TaskPriority.urgent);
      expect(task.isCompleted, false);
      expect(task.subtasks.length, 2);
      expect(task.completedSubtasksCount, 0);
      expect(task.subtasksProgress, 0.0);
    });

    test('Task subtask progress calculation', () {
      final subtask1 = SubtaskModel.create(title: 'Step 1').copyWith(isCompleted: true);
      final subtask2 = SubtaskModel.create(title: 'Step 2');
      final task = TaskModel.create(
        title: 'Multi-step task',
        subtasks: [subtask1, subtask2],
      );

      expect(task.completedSubtasksCount, 1);
      expect(task.subtasksProgress, 0.5);
    });

    test('Task JSON serialization and deserialization roundtrip', () {
      final task = TaskModel.create(
        title: 'Sync test task',
        notes: 'Testing json',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 5, 20, 14, 30),
      );

      final json = task.toJson();
      final restored = TaskModel.fromJson(json);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.priority, task.priority);
      expect(restored.dueDate, task.dueDate);
    });
  });

  group('ProjectListModel Domain Tests', () {
    test('Project list creation and json mapping', () {
      final list = ProjectListModel.create(
        name: 'Design System',
        colorValue: 0xFF6366F1,
        iconCodePoint: 0xe3af,
      );

      expect(list.name, 'Design System');
      expect(list.isDefault, false);

      final json = list.toJson();
      final restored = ProjectListModel.fromJson(json);
      expect(restored.name, list.name);
      expect(restored.colorValue, list.colorValue);
    });
  });

  group('Recurrence Engine Tests', () {
    test('Daily recurrence calculation', () {
      final baseDate = DateTime(2026, 3, 10, 9, 0);
      const rule = RecurrenceRule(type: RecurrenceType.daily, interval: 3);
      final next = RecurrenceHelper.calculateNextDueDate(baseDate, rule);
      expect(next, DateTime(2026, 3, 13, 9, 0));
    });

    test('Weekday recurrence skips weekends', () {
      // Friday
      final friday = DateTime(2026, 3, 13, 9, 0);
      const rule = RecurrenceRule(type: RecurrenceType.weekdays);
      final next = RecurrenceHelper.calculateNextDueDate(friday, rule);
      // Next day must be Monday
      expect(next?.weekday, DateTime.monday);
    });

    test('Monthly recurrence calculation', () {
      final jan15 = DateTime(2026, 1, 15, 10, 0);
      const rule = RecurrenceRule(type: RecurrenceType.monthly, interval: 1);
      final next = RecurrenceHelper.calculateNextDueDate(jan15, rule);
      expect(next, DateTime(2026, 2, 15, 10, 0));
    });

    test('Recurrence respects end date', () {
      final baseDate = DateTime(2026, 1, 10, 9, 0);
      final endDate = DateTime(2026, 1, 15, 9, 0);
      final rule = RecurrenceRule(
        type: RecurrenceType.daily,
        interval: 10,
        endDate: endDate,
      );
      final next = RecurrenceHelper.calculateNextDueDate(baseDate, rule);
      expect(next, isNull);
    });
  });

  group('Date Utility Tests', () {
    test('Same day comparisons', () {
      final d1 = DateTime(2026, 4, 1, 10, 30);
      final d2 = DateTime(2026, 4, 1, 22, 15);
      expect(DateFormatter.isSameDay(d1, d2), isTrue);
    });
  });
}
