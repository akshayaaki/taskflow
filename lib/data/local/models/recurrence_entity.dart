import 'package:isar/isar.dart';
import '../../../domain/models/recurrence_model.dart';

part 'recurrence_entity.g.dart';

@embedded
class RecurrenceEntity {
  String type = 'none';
  int interval = 1;
  List<int> daysOfWeek = [];
  DateTime? endDate;

  RecurrenceRule toDomain() {
    return RecurrenceRule(
      type: RecurrenceType.fromString(type),
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
    );
  }

  static RecurrenceEntity fromDomain(RecurrenceRule rule) {
    return RecurrenceEntity()
      ..type = rule.type.name
      ..interval = rule.interval
      ..daysOfWeek = rule.daysOfWeek
      ..endDate = rule.endDate;
  }
}
