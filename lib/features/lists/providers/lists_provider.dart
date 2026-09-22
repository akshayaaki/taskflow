import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/isar_service.dart';
import '../../../data/repositories/list_repository.dart';
import '../../../domain/models/project_list_model.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService must be initialized in main()');
});

final listRepositoryProvider = Provider<ListRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return ListRepositoryImpl(isarService);
});

final listsStreamProvider = StreamProvider<List<ProjectListModel>>((ref) {
  final repo = ref.watch(listRepositoryProvider);
  return repo.watchLists();
});

final selectedListIdProvider = StateProvider<String?>((ref) => null);

final selectedListProvider = Provider<ProjectListModel?>((ref) {
  final lists = ref.watch(listsStreamProvider).value ?? [];
  final selectedId = ref.watch(selectedListIdProvider);
  if (selectedId == null) return null;
  return lists.firstWhere(
    (l) => l.id == selectedId,
    orElse: () => lists.first,
  );
});
