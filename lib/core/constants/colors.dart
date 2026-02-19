import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Rose (dari Design System GlowUp)
  static const Color primary = Color(0xFFf43f5e); // rose-500
  static const Color primaryLight = Color(0xFFfb7185); // rose-400
  static const Color primaryDark = Color(0xFFe11d48); // rose-600
  static const Color primaryDarker = Color(0xFFbe123c); // rose-700

  // Secondary - Coral
  static const Color secondary = Color(0xFFcc4637);

  // Neutral - Cream & Peach
  static const Color background = Color(0xFFFFF9F5);
  static const Color surface = Color(0xFFFFEEE8);
  static const Color card = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF22c55e);
  static const Color successLight = Color(0xFFdcfce7);
  static const Color warning = Color(0xFFf59e0b);
  static const Color warningLight = Color(0xFFfef3c7);
  static const Color error = Color(0xFFef4444);
  static const Color errorLight = Color(0xFFfee2e2);
  static const Color info = Color(0xFF3b82f6);
  static const Color infoLight = Color(0xFFdbeafe);

  // Text Colors
  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textMuted = Color(0xFF9ca3af);
  static const Color textLight = Color(0xFFd1d5db);

  // Border Colors
  static const Color border = Color(0xFFe5e7eb);
  static const Color borderLight = Color(0xFFf3f4f6);

  // Status Colors - Appointment
  static const Color statusPending = Color(0xFFf59e0b); // Amber
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusConfirmed = Color(0xFF3b82f6); // Blue
  static const Color statusConfirmedBg = Color(0xFFDBEAFE);
  static const Color statusInProgress = Color(0xFF8b5cf6); // Purple
  static const Color statusInProgressBg = Color(0xFFEDE9FE);
  static const Color statusCompleted = Color(0xFF22c55e); // Green
  static const Color statusCompletedBg = Color(0xFFDCFCE7);
  static const Color statusCancelled = Color(0xFFef4444); // Red
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusNoShow = Color(0xFF6b7280); // Gray
  static const Color statusNoShowBg = Color(0xFFF3F4F6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
