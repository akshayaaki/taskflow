import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  static const List<IconData> availableIcons = [
    Icons.inbox_rounded,
    Icons.work_rounded,
    Icons.person_rounded,
    Icons.shopping_cart_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.flight_takeoff_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
    Icons.code_rounded,
    Icons.book_rounded,
  ];

  static IconData fromCodePoint(int codePoint) {
    for (final icon in availableIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.folder_rounded;
  }
}
