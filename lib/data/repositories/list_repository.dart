import 'package:isar/isar.dart';
import '../local/isar_service.dart';
import '../local/models/list_entity.dart';
import '../local/models/task_entity.dart';
import '../../domain/models/project_list_model.dart';

abstract class ListRepository {
  Stream<List<ProjectListModel>> watchLists();
  Future<List<ProjectListModel>> getAllLists();
  Future<ProjectListModel?> getListById(String id);
  Future<void> saveList(ProjectListModel list);
  Future<void> deleteList(String id, {bool deleteTasks = false});
  Future<void> reorderLists(List<String> listIds);
}

class ListRepositoryImpl implements ListRepository {
  final IsarService _isarService;

  ListRepositoryImpl(this._isarService);

  Isar get _isar => _isarService.isar;

  @override
  Stream<List<ProjectListModel>> watchLists() async* {
    yield* _isar.listEntitys
        .where()
        .sortByOrderIndex()
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final List<ProjectListModel> result = [];
      for (final entity in entities) {
        final activeCount = await _isar.taskEntitys
            .filter()
            .listIdEqualTo(entity.id)
            .and()
            .isCompletedEqualTo(false)
            .count();
        result.add(entity.toDomain(activeCount: activeCount));
      }
      return result;
    });
  }

  @override
  Future<List<ProjectListModel>> getAllLists() async {
    final entities =
        await _isar.listEntitys.where().sortByOrderIndex().findAll();
    final List<ProjectListModel> result = [];
    for (final entity in entities) {
      final activeCount = await _isar.taskEntitys
          .filter()
          .listIdEqualTo(entity.id)
          .and()
          .isCompletedEqualTo(false)
          .count();
      result.add(entity.toDomain(activeCount: activeCount));
    }
    return result;
  }

  @override
  Future<ProjectListModel?> getListById(String id) async {
    final entity =
        await _isar.listEntitys.filter().idEqualTo(id).findFirst();
    if (entity == null) return null;
    final activeCount = await _isar.taskEntitys
        .filter()
        .listIdEqualTo(entity.id)
        .and()
        .isCompletedEqualTo(false)
        .count();
    return entity.toDomain(activeCount: activeCount);
  }

  @override
  Future<void> saveList(ProjectListModel list) async {
    final existing =
        await _isar.listEntitys.filter().idEqualTo(list.id).findFirst();
    final entity = ListEntity.fromDomain(list);
    if (existing != null) {
      entity.isarId = existing.isarId;
    }
    await _isar.writeTxn(() async {
      await _isar.listEntitys.put(entity);
    });
  }

  @override
  Future<void> deleteList(String id, {bool deleteTasks = false}) async {
    await _isar.writeTxn(() async {
      await _isar.listEntitys.filter().idEqualTo(id).deleteAll();
      if (deleteTasks) {
        await _isar.taskEntitys.filter().listIdEqualTo(id).deleteAll();
      } else {
        // Unassign listId from tasks
        final tasks =
            await _isar.taskEntitys.filter().listIdEqualTo(id).findAll();
        for (final task in tasks) {
          task.listId = null;
          task.updatedAt = DateTime.now();
        }
        await _isar.taskEntitys.putAll(tasks);
      }
    });
  }

  @override
  Future<void> reorderLists(List<String> listIds) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < listIds.length; i++) {
        final entity =
            await _isar.listEntitys.filter().idEqualTo(listIds[i]).findFirst();
        if (entity != null) {
          entity.orderIndex = i;
          await _isar.listEntitys.put(entity);
        }
      }
    });
  }
}
