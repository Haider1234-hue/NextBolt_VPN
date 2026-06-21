import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const Color bgDark       = Color(0xFF080B1A);
  static const Color bgCard       = Color(0xFF111530);
  static const Color bgCardLight  = Color(0xFF1A2040);

  // ── Brand / Accent ────────────────────────────────────────
  static const Color cyan         = Color(0xFF00E5FF);
  static const Color cyanDark     = Color(0xFF0097A7);
  static const Color purple       = Color(0xFF7C4DFF);
  static const Color purpleDark   = Color(0xFF512DA8);

  // ── Status Colors ─────────────────────────────────────────
  static const Color connected    = Color(0xFF00E676);
  static const Color connecting   = Color(0xFFFFD740);
  static const Color disconnected = Color(0xFFFF1744);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A93B2);
  static const Color textHint      = Color(0xFF4A5280);

  // ── Misc ──────────────────────────────────────────────────
  static const Color divider      = Color(0xFF1E2548);
  static const Color shimmer      = Color(0xFF1E2A50);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF080B1A), Color(0xFF0D1230)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient connectedGlow = RadialGradient(
    colors: [Color(0x4400E676), Colors.transparent],
    radius: 0.8,
  );

  static const RadialGradient disconnectedGlow = RadialGradient(
    colors: [Color(0x44FF1744), Colors.transparent],
    radius: 0.8,
  );

  static const RadialGradient connectingGlow = RadialGradient(
    colors: [Color(0x44FFD740), Colors.transparent],
    radius: 0.8,
  );
}