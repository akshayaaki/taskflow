import 'package:uuid/uuid.dart';

class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final int orderIndex;

  const SubtaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.orderIndex = 0,
  });

  factory SubtaskModel.create({
    required String title,
    int orderIndex = 0,
  }) {
    return SubtaskModel(
      id: const Uuid().v4(),
      title: title,
      isCompleted: false,
      orderIndex: orderIndex,
    );
  }

  SubtaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? orderIndex,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'orderIndex': orderIndex,
    };
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
