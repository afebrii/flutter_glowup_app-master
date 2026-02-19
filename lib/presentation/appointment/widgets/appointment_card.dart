import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../data/models/responses/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showDate;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.isSelected = false,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Time Column
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    appointment.formattedStartTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.formattedEndTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor().withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.customer?.name ?? 'Pelanggan #${appointment.customerId}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppointmentStatusBadge(status: appointment.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.service?.name ?? 'Service #${appointment.serviceId}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getSourceIcon(),
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment.source.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (appointment.service?.price != null) ...[
                        const Spacer(),
                        Text(
                          appointment.service!.price.currencyFormat,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.info;
      case AppointmentStatus.inProgress:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.error;
    }
  }

  IconData _getSourceIcon() {
    switch (appointment.source) {
      case AppointmentSource.walkIn:
        return Icons.directions_walk;
      case AppointmentSource.phone:
        return Icons.phone;
      case AppointmentSource.whatsapp:
        return Icons.chat;
      case AppointmentSource.online:
        return Icons.language;
    }
  }
}

class AppointmentStatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final bool showIcon;

  const AppointmentStatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), size: 12, color: _getColor()),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _getColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.info;
      case AppointmentStatus.inProgress:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.error;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.inProgress:
        return Icons.play_circle_outline;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.person_off;
    }
  }
}

class AppointmentListTile extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppointmentListTile({
    super.key,
    required this.appointment,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appointment.formattedStartTime,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        appointment.customer?.name ?? 'Pelanggan',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        appointment.service?.name ?? 'Service',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: AppointmentStatusBadge(status: appointment.status),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.info;
      case AppointmentStatus.inProgress:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return AppColors.error;
    }
  }
}
