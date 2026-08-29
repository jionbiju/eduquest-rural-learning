import 'package:flutter/material.dart';

/// EduQuest GAME-THEMED color palette.
/// Epic, vibrant colors for an immersive gaming experience.
abstract final class AppColors {
  // ── Primary (Cosmic Purple/Blue) ─────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);       // Vivid Indigo
  static const Color primaryLight = Color(0xFF818CF8);  // Bright Indigo
  static const Color primaryDark = Color(0xFF4338CA);   // Deep Indigo
  static const Color primaryGlow = Color(0xFFA78BFA);  // Purple Glow

  // ── Secondary / Accent (Electric Gold/Orange) ────────────────────────────
  static const Color secondary = Color(0xFFFBBF24);     // Bright Gold
  static const Color secondaryLight = Color(0xFFFDE047);// Light Yellow
  static const Color secondaryDark = Color(0xFFD97706); // Deep Orange

  // ── Success / XP / Correct (Neon Green) ──────────────────────────────────
  static const Color success = Color(0xFF22C55E);       // Bright Green
  static const Color successLight = Color(0xFF86EFAC); // Light Green
  static const Color successGlow = Color(0xFF4ADE80);  // Neon Green Glow

  // ── Error / Wrong (Vibrant Red) ──────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);         // Bright Red
  static const Color errorLight = Color(0xFFFCA5A5);   // Light Red
  static const Color errorDark = Color(0xFFDC2626);    // Deep Red

  // ── Warning (Cyber Orange) ───────────────────────────────────────────────
  static const Color warning = Color(0xFFFF6B35);       // Neon Orange

  // ── Neutrals (Space Theme) ───────────────────────────────────────────────
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceVariant = Color(0xFFEDE9FE);
  static const Color background = Color(0xFFF1F5F9);    // Subtle blue-grey
  static const Color onBackground = Color(0xFF1E1B4B);

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey800 = Color(0xFF1F2937);

  // ── Epic Gamification Colors ─────────────────────────────────────────────
  static const Color xpGold = Color(0xFFFFD700);        // Shiny Gold
  static const Color xpGoldGlow = Color(0xFFFFA500);   // Gold Glow
  static const Color streakFire = Color(0xFFFF6B35);   // Fire Orange
  static const Color streakOrange = Color(0xFFFF6B35); // Alias for backward compatibility
  static const Color streakFlame = Color(0xFFFF4500);  // Flame Red
  static const Color badgePurple = Color(0xFF8B5CF6);  // Epic Purple
  static const Color badgeGlow = Color(0xFFA78BFA);    // Purple Glow
  
  // ── Space/Nebula Theme ───────────────────────────────────────────────────
  static const Color cosmicBlue = Color(0xFF3B82F6);   // Cosmic Blue
  static const Color cosmicPurple = Color(0xFF9333EA); // Nebula Purple
  static const Color cosmicPink = Color(0xFFEC4899);   // Star Pink
  static const Color cosmicTeal = Color(0xFF14B8A6);   // Galaxy Teal
  
  // ── Game-Themed Gradients ────────────────────────────────────────────────
  static const List<Color> heroGradient = [
    Color(0xFF6366F1),  // Indigo
    Color(0xFF8B5CF6),  // Purple
    Color(0xFFEC4899),  // Pink
  ];
  
  static const List<Color> questGradient = [
    Color(0xFFFBBF24),  // Gold
    Color(0xFFF59E0B),  // Amber
    Color(0xFFEF4444),  // Red
  ];
  
  static const List<Color> victoryGradient = [
    Color(0xFF22C55E),  // Green
    Color(0xFF14B8A6),  // Teal
    Color(0xFF3B82F6),  // Blue
  ];
  
  static const List<Color> nebulaGradient = [
    Color(0xFF4338CA),  // Deep Indigo
    Color(0xFF7C3AED),  // Purple
    Color(0xFFDB2777),  // Pink
  ];
  
  static const List<Color> legendaryGradient = [
    Color(0xFFFFD700),  // Gold
    Color(0xFFFFA500),  // Orange
    Color(0xFFFF6B35),  // Red-Orange
  ];
}
