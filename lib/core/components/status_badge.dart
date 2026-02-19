import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Menunggu';
      case AppointmentStatus.confirmed:
        return 'Dikonfirmasi';
      case AppointmentStatus.inProgress:
        return 'Berlangsung';
      case AppointmentStatus.completed:
        return 'Selesai';
      case AppointmentStatus.cancelled:
        return 'Dibatalkan';
      case AppointmentStatus.noShow:
        return 'Tidak Hadir';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return AppColors.statusPending;
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmed;
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgress;
      case AppointmentStatus.completed:
        return AppColors.statusCompleted;
      case AppointmentStatus.cancelled:
        return AppColors.statusCancelled;
      case AppointmentStatus.noShow:
        return AppColors.statusNoShow;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AppointmentStatus.pending:
        return AppColors.statusPendingBg;
      case AppointmentStatus.confirmed:
        return AppColors.statusConfirmedBg;
      case AppointmentStatus.inProgress:
        return AppColors.statusInProgressBg;
      case AppointmentStatus.completed:
        return AppColors.statusCompletedBg;
      case AppointmentStatus.cancelled:
        return AppColors.statusCancelledBg;
      case AppointmentStatus.noShow:
        return AppColors.statusNoShowBg;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.play_circle_outline;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.noShow:
        return Icons.person_off_outlined;
    }
  }

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.pending;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final bool showIcon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.fontSize,
  });

  /// Create from string status
  factory StatusBadge.fromString(String statusString, {bool showIcon = false}) {
    return StatusBadge(
      status: AppointmentStatusExtension.fromString(statusString),
      showIcon: showIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: 14,
              color: status.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic badge untuk status lainnya
class GenericBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  const GenericBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
