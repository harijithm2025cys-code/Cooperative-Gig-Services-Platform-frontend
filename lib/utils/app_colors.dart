import 'package:flutter/material.dart';

class AppColors {
  // Unified Royal Violet & Electric Purple Design System
  static const Color primary = Color(0xFF5B21B6); // Royal Violet
  static const Color primaryDark = Color(0xFF4C1D95);
  static const Color primaryLight = Color(0xFF7C3AED); // Electric Purple
  static const Color primaryAccent = Color(0xFF8B5CF6);
  static const Color primaryContainer = Color(0xFFF3E8FF); // Soft Lavender
  static const Color onPrimaryContainer = Color(0xFF581C87);

  // Status Colors unified with design system
  static const Color statusRequested = Color(0xFFF59E0B);
  static const Color statusRequestedBg = Color(0xFFFEF3C7);

  static const Color statusAccepted = Color(0xFF7C3AED);
  static const Color statusAcceptedBg = Color(0xFFF3E8FF);

  static const Color statusInProgress = Color(0xFF6366F1);
  static const Color statusInProgressBg = Color(0xFFEEF2FF);

  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCompletedBg = Color(0xFFD1FAE5);

  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCancelledBg = Color(0xFFFEE2E2);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Rating
  static const Color rating = Color(0xFFFBBF24);

  // Helper methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase().replaceAll(' ', '_')) {
      case 'requested':
      case 'pending':
        return statusRequested;
      case 'accepted':
      case 'confirmed':
        return statusAccepted;
      case 'in_progress':
      case 'on_the_way':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
      case 'declined':
        return statusCancelled;
      default:
        return primary;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase().replaceAll(' ', '_')) {
      case 'requested':
      case 'pending':
        return statusRequestedBg;
      case 'accepted':
      case 'confirmed':
        return statusAcceptedBg;
      case 'in_progress':
      case 'on_the_way':
        return statusInProgressBg;
      case 'completed':
      case 'completed_remotely':
        return statusCompletedBg;
      case 'cancelled':
      case 'declined':
        return statusCancelledBg;
      default:
        return primaryContainer;
    }
  }
}

/// 3D UI & Neumorphic Design System Helpers
class App3D {
  /// 3D Card Decoration with multi-layered depth shadow & top highlight
  static BoxDecoration card3D({
    Color backgroundColor = Colors.white,
    double borderRadius = 18,
    Border? border,
    bool isElevated = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      boxShadow: isElevated
          ? [
              const BoxShadow(
                color: Color(0x0F1E1B4B),
                blurRadius: 16,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
              const BoxShadow(
                color: Color(0x085B21B6),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }

  /// 3D Glowing Card Decoration (for active hero sections)
  static BoxDecoration glowCard3D({
    List<Color>? gradientColors,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors ?? const [Color(0xFF5B21B6), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x405B21B6),
          blurRadius: 20,
          offset: Offset(0, 10),
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// 3D Floating Action Button Decoration
  static ButtonStyle button3D({
    Color backgroundColor = const Color(0xFF5B21B6),
    Color foregroundColor = Colors.white,
    double borderRadius = 14,
    double height = 52,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 6,
      shadowColor: backgroundColor.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }
}
