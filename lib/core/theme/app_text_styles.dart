import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised text style definitions using Nunito via google_fonts.
abstract final class AppTextStyles {
  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.onBackground,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.onBackground,
        height: 1.25,
      );

  // ── Headline ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.35,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.grey800,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.grey800,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.grey600,
        height: 1.5,
      );

  // ── Label ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.grey600,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.grey600,
        letterSpacing: 0.4,
      );

  // ── Special ───────────────────────────────────────────────────────────────
  static TextStyle get xpCounter => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.xpGold,
        height: 1,
      );

  static TextStyle get streakCounter => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.streakOrange,
        height: 1,
      );
}
