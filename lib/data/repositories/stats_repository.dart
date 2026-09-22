import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../domain/models/priority_enum.dart';
import '../local/isar_service.dart';
import '../local/models/task_entity.dart';
import '../local/models/list_entity.dart';

class StatsData {
  final int totalTasks;
  final int completedTasks;
  final int activeTasks;
  final double completionRate;
  final int streakDays;
  final List<DailyStat> weeklyCompletion;
  final Map<TaskPriority, int> priorityCounts;
  final Map<String, int> listCounts;

  const StatsData({
    required this.totalTasks,
    required this.completedTasks,
    required this.activeTasks,
    required this.completionRate,
    required this.streakDays,
    required this.weeklyCompletion,
    required this.priorityCounts,
    required this.listCounts,
  });
}

class DailyStat {
  final String dayName;
  final int count;
  final DateTime date;

  const DailyStat({
    required this.dayName,
    required this.count,
    required this.date,
  });
}

abstract class StatsRepository {
  Future<StatsData> getProductivityStats();
}

class StatsRepositoryImpl implements StatsRepository {
  final IsarService _isarService;

  StatsRepositoryImpl(this._isarService);

  Isar get _isar => _isarService.isar;

  @override
  Future<StatsData> getProductivityStats() async {
    final allTasks = await _isar.taskEntitys.where().findAll();
    final allLists = await _isar.listEntitys.where().findAll();

    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((t) => t.isCompleted).length;
    final activeTasks = totalTasks - completedTasks;
    final completionRate =
        totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

    // 1. Weekly completion stats (past 7 days)
    final now = DateTime.now();
    final List<DailyStat> weekly = [];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: i),
      );
      final nextDay = day.add(const Duration(days: 1));

      final countForDay = allTasks.where((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return t.completedAt!.isAfter(day) &&
            t.completedAt!.isBefore(nextDay);
      }).length;

      weekly.add(
        DailyStat(
          dayName: DateFormat('E').format(day),
          count: countForDay,
          date: day,
        ),
      );
    }

    // 2. Streak calculation
    int streak = 0;
    DateTime checkDay = DateTime(now.year, now.month, now.day);
    while (true) {
      final nextDay = checkDay.add(const Duration(days: 1));
      final hasCompleted = allTasks.any((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return t.completedAt!.isAfter(checkDay) &&
            t.completedAt!.isBefore(nextDay);
      });

      if (hasCompleted) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        // If today has 0, check if yesterday had completed tasks before breaking streak
        if (checkDay == DateTime(now.year, now.month, now.day)) {
          checkDay = checkDay.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    // 3. Priority breakdown
    final Map<TaskPriority, int> priorityCounts = {
      TaskPriority.low: 0,
      TaskPriority.medium: 0,
      TaskPriority.high: 0,
      TaskPriority.urgent: 0,
    };
    for (final task in allTasks) {
      final p = TaskPriority.fromString(task.priority);
      priorityCounts[p] = (priorityCounts[p] ?? 0) + 1;
    }

    // 4. List breakdown
    final Map<String, int> listCounts = {};
    for (final list in allLists) {
      final count = allTasks.where((t) => t.listId == list.id).length;
      listCounts[list.name] = count;
    }

    return StatsData(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      activeTasks: activeTasks,
      completionRate: completionRate,
      streakDays: streak,
      weeklyCompletion: weekly,
      priorityCounts: priorityCounts,
      listCounts: listCounts,
    );
  }
}
