enum RecurrenceType {
  none,
  daily,
  weekdays, // Monday to Friday
  weekly,
  monthly,
  custom;

  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekdays:
        return 'Every weekday (Mon-Fri)';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  static RecurrenceType fromString(String? value) {
    if (value == null) return RecurrenceType.none;
    return RecurrenceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => RecurrenceType.none,
    );
  }
}

class RecurrenceRule {
  final RecurrenceType type;
  final int interval; // every N days/weeks/months
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final DateTime? endDate;

  const RecurrenceRule({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.endDate,
  });

  bool get isRecurring => type != RecurrenceType.none;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: RecurrenceType.fromString(json['type'] as String?),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
    );
  }

  RecurrenceRule copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    DateTime? endDate,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      endDate: endDate ?? this.endDate,
    );
  }
}
