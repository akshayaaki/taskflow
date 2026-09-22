import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/priority_enum.dart';
import '../../../domain/models/task_model.dart';
import '../../tasks/providers/tasks_provider.dart';

class FilterSortState {
  final String query;
  final String? listId;
  final TaskPriority? priority;
  final bool? isCompleted;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final bool ascending;

  const FilterSortState({
    this.query = '',
    this.listId,
    this.priority,
    this.isCompleted,
    this.startDate,
    this.endDate,
    this.sortBy = 'dueDate',
    this.ascending = true,
  });

  bool get hasActiveFilters =>
      listId != null ||
      priority != null ||
      isCompleted != null ||
      startDate != null ||
      endDate != null;

  FilterSortState copyWith({
    String? query,
    String? listId,
    bool clearListId = false,
    TaskPriority? priority,
    bool clearPriority = false,
    bool? isCompleted,
    bool clearIsCompleted = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? sortBy,
    bool? ascending,
  }) {
    return FilterSortState(
      query: query ?? this.query,
      listId: clearListId ? null : (listId ?? this.listId),
      priority: clearPriority ? null : (priority ?? this.priority),
      isCompleted:
          clearIsCompleted ? null : (isCompleted ?? this.isCompleted),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

final filterSortProvider =
    StateNotifierProvider<FilterSortNotifier, FilterSortState>((ref) {
  return FilterSortNotifier();
});

class FilterSortNotifier extends StateNotifier<FilterSortState> {
  FilterSortNotifier() : super(const FilterSortState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setListId(String? listId) {
    state = state.copyWith(listId: listId, clearListId: listId == null);
  }

  void setPriority(TaskPriority? priority) {
    state =
        state.copyWith(priority: priority, clearPriority: priority == null);
  }

  void setIsCompleted(bool? isCompleted) {
    state = state.copyWith(
      isCompleted: isCompleted,
      clearIsCompleted: isCompleted == null,
    );
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      clearStartDate: start == null,
      endDate: end,
      clearEndDate: end == null,
    );
  }

  void setSort(String sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, ascending: ascending);
  }

  void resetFilters() {
    state = const FilterSortState();
  }
}

final filteredTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(filterSortProvider);
  ref.watch(allTasksStreamProvider); // Re-run whenever tasks update

  return repo.filterAndSortTasks(
    query: filter.query,
    listId: filter.listId,
    priority: filter.priority,
    isCompleted: filter.isCompleted,
    startDate: filter.startDate,
    endDate: filter.endDate,
    sortBy: filter.sortBy,
    ascending: filter.ascending,
  );
});
