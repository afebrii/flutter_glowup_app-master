import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/status_badge.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../data/models/responses/dashboard_model.dart';

class TodayAppointmentsList extends StatelessWidget {
  final List<TodayAppointment> appointments;
  final VoidCallback? onViewAll;
  final Function(TodayAppointment)? onAppointmentTap;

  const TodayAppointmentsList({
    super.key,
    required this.appointments,
    this.onViewAll,
    this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.event_available,
                size: 32,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada appointment',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jadwal hari ini masih kosong',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Appointment Hari Ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${appointments.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentListItem(
                appointment: appointment,
                onTap: onAppointmentTap != null
                    ? () => onAppointmentTap!(appointment)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class AppointmentListItem extends StatelessWidget {
  final TodayAppointment appointment;
  final VoidCallback? onTap;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = AppointmentStatusExtension.fromString(appointment.status);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Time Column with accent bar
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: status.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: status.color,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    appointment.formattedStartTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: status.color,
                    ),
                  ),
                  Text(
                    appointment.formattedEndTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: status.color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (appointment.staffName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: AppColors.textMuted.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.staffName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Status Badge
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

/// Compact version untuk sidebar tablet
class TodayAppointmentsCompact extends StatelessWidget {
  final List<TodayAppointment> appointments;
  final VoidCallback? onViewAll;
  final Function(TodayAppointment)? onAppointmentTap;
  final int maxItems;

  const TodayAppointmentsCompact({
    super.key,
    required this.appointments,
    this.onViewAll,
    this.onAppointmentTap,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayedAppointments = appointments.take(maxItems).toList();
    final hasMore = appointments.length > maxItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Appointment Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Semua'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // List
        if (displayedAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Tidak ada appointment',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...displayedAppointments.map((appointment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CompactAppointmentItem(
                appointment: appointment,
                onTap: onAppointmentTap != null
                    ? () => onAppointmentTap!(appointment)
                    : null,
              ),
            );
          }),
        if (hasMore) ...[
          const SizedBox(height: 4),
          Center(
            child: Text(
              '+${appointments.length - maxItems} lainnya',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactAppointmentItem extends StatelessWidget {
  final TodayAppointment appointment;
  final VoidCallback? onTap;

  const _CompactAppointmentItem({
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = AppointmentStatusExtension.fromString(appointment.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status.backgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                appointment.formattedStartTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: status.color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    appointment.serviceName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                appointment.customerName.initials,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
