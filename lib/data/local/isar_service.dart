import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/list_entity.dart';
import 'models/task_entity.dart';

class IsarService {
  static IsarService? _instance;
  late final Isar _isar;

  IsarService._(this._isar);

  static Future<IsarService> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [TaskEntitySchema, ListEntitySchema],
      directory: dir.path,
      name: 'todo_app_db',
    );

    _instance = IsarService._(isar);
    await _instance!._seedDefaultListsIfNeeded();
    return _instance!;
  }

  Isar get isar => _isar;

  Future<void> _seedDefaultListsIfNeeded() async {
    final count = await _isar.listEntitys.count();
    if (count == 0) {
      final now = DateTime.now();
      final defaultLists = [
        ListEntity()
          ..id = 'default_inbox'
          ..name = 'Inbox'
          ..colorValue = 0xFF6366F1
          ..iconCodePoint = Icons.inbox_rounded.codePoint
          ..orderIndex = 0
          ..isDefault = true
          ..createdAt = now
          ..updatedAt = now,
        ListEntity()
          ..id = 'default_work'
          ..name = 'Work'
          ..colorValue = 0xFF3B82F6
          ..iconCodePoint = Icons.work_rounded.codePoint
          ..orderIndex = 1
          ..isDefault = false
          ..createdAt = now
          ..updatedAt = now,
        ListEntity()
          ..id = 'default_personal'
          ..name = 'Personal'
          ..colorValue = 0xFF10B981
          ..iconCodePoint = Icons.person_rounded.codePoint
          ..orderIndex = 2
          ..isDefault = false
          ..createdAt = now
          ..updatedAt = now,
      ];

      await _isar.writeTxn(() async {
        await _isar.listEntitys.putAll(defaultLists);
      });
    }
  }

  Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.taskEntitys.clear();
      await _isar.listEntitys.clear();
    });
    await _seedDefaultListsIfNeeded();
  }
}
