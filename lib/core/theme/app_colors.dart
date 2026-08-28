import 'package:flutter/material.dart';

/// EduQuest brand color palette.
/// Warm, high-contrast colors optimised for low-quality outdoor screens.
abstract final class AppColors {
  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo-400
  static const Color primaryDark = Color(0xFF3730A3);   // Indigo-800

  // ── Secondary / Accent ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFFF59E0B);     // Amber-500
  static const Color secondaryLight = Color(0xFFFCD34D);
  static const Color secondaryDark = Color(0xFFB45309);

  // ── Success / XP / Correct ───────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);       // Emerald-500
  static const Color successLight = Color(0xFF6EE7B7);

  // ── Error / Wrong ────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);         // Red-500
  static const Color errorLight = Color(0xFFFCA5A5);

  // ── Warning ───────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFF97316);       // Orange-500

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF8F7FF);
  static const Color surfaceVariant = Color(0xFFEDE9FE);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1E1B4B);

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);

  // ── Gamification ─────────────────────────────────────────────────────────
  static const Color xpGold = Color(0xFFFFD700);
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color badgePurple = Color(0xFF7C3AED);
}
