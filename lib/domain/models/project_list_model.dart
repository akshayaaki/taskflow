import 'package:uuid/uuid.dart';

class ProjectListModel {
  final String id;
  final String name;
  final int colorValue; // ARGB int
  final int iconCodePoint; // IconData codepoint
  final int orderIndex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int activeTaskCount;

  const ProjectListModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.orderIndex = 0,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.activeTaskCount = 0,
  });

  factory ProjectListModel.create({
    required String name,
    required int colorValue,
    required int iconCodePoint,
    int orderIndex = 0,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return ProjectListModel(
      id: const Uuid().v4(),
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      orderIndex: orderIndex,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
      activeTaskCount: 0,
    );
  }

  ProjectListModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
    int? orderIndex,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? activeTaskCount,
  }) {
    return ProjectListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      orderIndex: orderIndex ?? this.orderIndex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeTaskCount: activeTaskCount ?? this.activeTaskCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'orderIndex': orderIndex,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProjectListModel.fromJson(Map<String, dynamic> json) {
    return ProjectListModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? 'Untitled List',
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF6366F1,
      iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0xe3af,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      activeTaskCount: (json['activeTaskCount'] as num?)?.toInt() ?? 0,
    );
  }
}
