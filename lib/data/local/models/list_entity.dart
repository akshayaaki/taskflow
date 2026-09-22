import 'package:isar/isar.dart';
import '../../../domain/models/project_list_model.dart';

part 'list_entity.g.dart';

@collection
class ListEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String name;
  late int colorValue;
  late int iconCodePoint;
  late int orderIndex;
  late bool isDefault;
  late DateTime createdAt;
  late DateTime updatedAt;

  ProjectListModel toDomain({int activeCount = 0}) {
    return ProjectListModel(
      id: id,
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      orderIndex: orderIndex,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      activeTaskCount: activeCount,
    );
  }

  static ListEntity fromDomain(ProjectListModel model) {
    return ListEntity()
      ..id = model.id
      ..name = model.name
      ..colorValue = model.colorValue
      ..iconCodePoint = model.iconCodePoint
      ..orderIndex = model.orderIndex
      ..isDefault = model.isDefault
      ..createdAt = model.createdAt
      ..updatedAt = model.updatedAt;
  }
}
