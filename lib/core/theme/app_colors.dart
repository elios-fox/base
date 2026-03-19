import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand palette ──────────────────────────────────────────────────
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF81C784);
  static const primaryDark = Color(0xFF1B5E20);

  static const secondary = Color(0xFFF57C00);
  static const secondaryLight = Color(0xFFFFB74D);
  static const secondaryDark = Color(0xFFE65100);

  static const tertiary = Color(0xFF1565C0);
  static const tertiaryLight = Color(0xFF64B5F6);
  static const tertiaryDark = Color(0xFF0D47A1);

  /// Kept for backward compat; prefer [primary].
  static const seed = primary;

  // ── Semantic: attendance ───────────────────────────────────────────
  static const aanwezig = Color(0xFF4CAF50);
  static const aanwezigBg = Color(0xFFE8F5E9);
  static const afwezig = Color(0xFFF44336);
  static const afwezigBg = Color(0xFFFFEBEE);
  static const onzeker = Color(0xFFFF9800);
  static const onzekerBg = Color(0xFFFFF3E0);

  // ── Semantic: event types ──────────────────────────────────────────
  static const training = Color(0xFF1565C0);
  static const trainingBg = Color(0xFFBBDEFB);
  static const trainingBgLight = Color(0xFFE3F2FD);
  static const wedstrijd = Color(0xFFF57C00);
  static const wedstrijdBg = Color(0xFFFFE0B2);
  static const wedstrijdBgLight = Color(0xFFFFF3E0);

  // ── Surface colors ─────────────────────────────────────────────────
  static const surfaceLight = Color(0xFFFAFAFA);
  static const surfaceDark = Color(0xFF121212);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E1E1E);

  // ── Neutral ────────────────────────────────────────────────────────
  static const grey = Color(0xFF9E9E9E);
  static const greyLight = Color(0xFFBDBDBD);
  static const greyDark = Color(0xFF616161);
  static const divider = Color(0xFFE0E0E0);

  // ── Danger ─────────────────────────────────────────────────────────
  static const error = Color(0xFFD32F2F);
  static const errorBg = Color(0xFFFFEBEE);
}
