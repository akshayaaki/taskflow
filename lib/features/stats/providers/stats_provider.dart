import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/stats_repository.dart';
import '../../lists/providers/lists_provider.dart';
import '../../tasks/providers/tasks_provider.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return StatsRepositoryImpl(isarService);
});

final productivityStatsProvider = FutureProvider<StatsData>((ref) async {
  final repo = ref.watch(statsRepositoryProvider);
  ref.watch(allTasksStreamProvider); // Recompute when tasks change
  return repo.getProductivityStats();
});
