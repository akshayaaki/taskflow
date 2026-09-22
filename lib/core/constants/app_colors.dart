import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFEC4899); // Pink

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981); // Emerald Green
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityHigh = Color(0xFFF97316); // Orange
  static const Color priorityUrgent = Color(0xFFEF4444); // Red

  // Dark Theme Backgrounds
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF475569);

  // Light Theme Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Preset Project / Tag Colors
  static const List<Color> presetColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF3B82F6), // Blue
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFF84CC16), // Lime
    Color(0xFFEAB308), // Yellow
    Color(0xFFF97316), // Orange
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF64748B), // Slate
  ];
}
