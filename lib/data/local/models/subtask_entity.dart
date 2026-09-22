import 'package:isar/isar.dart';
import '../../../domain/models/subtask_model.dart';

part 'subtask_entity.g.dart';

@embedded
class SubtaskEntity {
  String? id;
  String? title;
  bool isCompleted = false;
  int orderIndex = 0;

  SubtaskModel toDomain() {
    return SubtaskModel(
      id: id ?? '',
      title: title ?? '',
      isCompleted: isCompleted,
      orderIndex: orderIndex,
    );
  }

  static SubtaskEntity fromDomain(SubtaskModel model) {
    return SubtaskEntity()
      ..id = model.id
      ..title = model.title
      ..isCompleted = model.isCompleted
      ..orderIndex = model.orderIndex;
  }
}
