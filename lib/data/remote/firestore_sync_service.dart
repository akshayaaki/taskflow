import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/firebase_config.dart';
import '../../domain/models/project_list_model.dart';
import '../../domain/models/task_model.dart';
import '../local/isar_service.dart';
import '../local/models/list_entity.dart';
import '../local/models/task_entity.dart';

enum SyncStatus { idle, syncing, synced, error, unauthenticated }

class FirestoreSyncService {
  final IsarService _isarService;
  FirebaseFirestore? get _firestore =>
      FirebaseConfig.isInitialized ? FirebaseFirestore.instance : null;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _listsSubscription;

  FirestoreSyncService(this._isarService);

  Isar get _isar => _isarService.isar;

  CollectionReference<Map<String, dynamic>>? _tasksRef(String userId) {
    if (_firestore == null) return null;
    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.tasksCollection);
  }

  CollectionReference<Map<String, dynamic>>? _listsRef(String userId) {
    if (_firestore == null) return null;
    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.listsCollection);
  }

  Future<void> syncAll(String userId) async {
    if (_firestore == null) {
      debugPrint('FirestoreSyncService: Firestore not initialized');
      return;
    }

    try {
      final tasksCol = _tasksRef(userId);
      final listsCol = _listsRef(userId);
      if (tasksCol == null || listsCol == null) return;

      // 1. Pull Remote Lists and merge
      final remoteListsSnapshot = await listsCol.get();
      for (final doc in remoteListsSnapshot.docs) {
        final remoteData = doc.data();
        final remoteModel = ProjectListModel.fromJson(remoteData);
        final localEntity = await _isar.listEntitys
            .filter()
            .idEqualTo(remoteModel.id)
            .findFirst();

        if (localEntity == null ||
            remoteModel.updatedAt.isAfter(localEntity.updatedAt)) {
          final entity = ListEntity.fromDomain(remoteModel);
          if (localEntity != null) entity.isarId = localEntity.isarId;
          await _isar.writeTxn(() async {
            await _isar.listEntitys.put(entity);
          });
        }
      }

      // 2. Push Local Lists to Remote
      final localLists = await _isar.listEntitys.where().findAll();
      for (final list in localLists) {
        await listsCol.doc(list.id).set(
              list.toDomain().toJson(),
              SetOptions(merge: true),
            );
      }

      // 3. Pull Remote Tasks and merge
      final remoteTasksSnapshot = await tasksCol.get();
      for (final doc in remoteTasksSnapshot.docs) {
        final remoteData = doc.data();
        final remoteModel = TaskModel.fromJson(remoteData);
        final localEntity = await _isar.taskEntitys
            .filter()
            .idEqualTo(remoteModel.id)
            .findFirst();

        if (localEntity == null ||
            remoteModel.updatedAt.isAfter(localEntity.updatedAt)) {
          final entity = TaskEntity.fromDomain(remoteModel);
          if (localEntity != null) entity.isarId = localEntity.isarId;
          await _isar.writeTxn(() async {
            await _isar.taskEntitys.put(entity);
          });
        }
      }

      // 4. Push Local Tasks to Remote
      final localTasks = await _isar.taskEntitys.where().findAll();
      for (final task in localTasks) {
        await tasksCol.doc(task.id).set(
              task.toDomain().toJson(),
              SetOptions(merge: true),
            );
      }
    } catch (e) {
      debugPrint('FirestoreSyncService error: $e');
      rethrow;
    }
  }

  void startRealtimeSync(String userId) {
    if (_firestore == null) return;
    stopRealtimeSync();

    final tasksCol = _tasksRef(userId);
    final listsCol = _listsRef(userId);
    if (tasksCol == null || listsCol == null) return;

    // Listen to remote task updates
    _tasksSubscription = tasksCol.snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;
          final remoteModel = TaskModel.fromJson(data);
          final localEntity = await _isar.taskEntitys
              .filter()
              .idEqualTo(remoteModel.id)
              .findFirst();

          if (localEntity == null ||
              remoteModel.updatedAt.isAfter(localEntity.updatedAt)) {
            final entity = TaskEntity.fromDomain(remoteModel);
            if (localEntity != null) entity.isarId = localEntity.isarId;
            await _isar.writeTxn(() async {
              await _isar.taskEntitys.put(entity);
            });
          }
        } else if (change.type == DocumentChangeType.removed) {
          final taskId = change.doc.id;
          await _isar.writeTxn(() async {
            await _isar.taskEntitys.filter().idEqualTo(taskId).deleteAll();
          });
        }
      }
    });

    // Listen to remote list updates
    _listsSubscription = listsCol.snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;
          final remoteModel = ProjectListModel.fromJson(data);
          final localEntity = await _isar.listEntitys
              .filter()
              .idEqualTo(remoteModel.id)
              .findFirst();

          if (localEntity == null ||
              remoteModel.updatedAt.isAfter(localEntity.updatedAt)) {
            final entity = ListEntity.fromDomain(remoteModel);
            if (localEntity != null) entity.isarId = localEntity.isarId;
            await _isar.writeTxn(() async {
              await _isar.listEntitys.put(entity);
            });
          }
        } else if (change.type == DocumentChangeType.removed) {
          final listId = change.doc.id;
          await _isar.writeTxn(() async {
            await _isar.listEntitys.filter().idEqualTo(listId).deleteAll();
          });
        }
      }
    });
  }

  void stopRealtimeSync() {
    _tasksSubscription?.cancel();
    _listsSubscription?.cancel();
  }
}
