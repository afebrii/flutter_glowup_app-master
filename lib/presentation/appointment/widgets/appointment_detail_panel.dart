import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../data/models/responses/appointment_model.dart';
import 'appointment_card.dart';

class AppointmentDetailPanel extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onConfirm;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onRecordTreatment;
  final VoidCallback? onContinuePayment;
  final bool isUpdating;
  /// True if there's a pending transaction for this appointment
  final bool hasPendingTransaction;
  /// Amount of pending transaction
  final int? pendingTransactionAmount;
  /// True if payment has been completed (transaction is paid)
  final bool isPaid;

  const AppointmentDetailPanel({
    super.key,
    required this.appointment,
    this.onConfirm,
    this.onStart,
    this.onComplete,
    this.onCancel,
    this.onRecordTreatment,
    this.onContinuePayment,
    this.isUpdating = false,
    this.hasPendingTransaction = false,
    this.pendingTransactionAmount,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.appointmentDate.toFormattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SpaceHeight.h4(),
                    Text(
                      appointment.timeRange,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              AppointmentStatusBadge(status: appointment.status, showIcon: true),
            ],
          ),
          const SpaceHeight.h24(),

          // Customer Info Card
          _buildInfoCard(
            title: 'Pelanggan',
            icon: Icons.person_outline,
            children: [
              _InfoRow(
                label: 'Nama',
                value: appointment.customer?.name ?? '-',
              ),
              _InfoRow(
                label: 'Telepon',
                value: appointment.customer?.phone ?? '-',
                isPhone: true,
              ),
            ],
          ),
          const SpaceHeight.h16(),

          // Service Info Card
          _buildInfoCard(
            title: 'Layanan',
            icon: Icons.spa_outlined,
            children: [
              _InfoRow(
                label: 'Nama',
                value: appointment.service?.name ?? '-',
              ),
              _InfoRow(
                label: 'Durasi',
                value: appointment.service?.durationFormatted ?? '-',
              ),
              _InfoRow(
                label: 'Harga',
                value: appointment.service?.price.currencyFormat ?? '-',
                valueColor: AppColors.primary,
              ),
            ],
          ),
          const SpaceHeight.h16(),

          // Booking Info Card
          _buildInfoCard(
            title: 'Info Booking',
            icon: Icons.info_outline,
            children: [
              _InfoRow(
                label: 'Sumber',
                value: appointment.source.label,
              ),
              _InfoRow(
                label: 'Dibuat',
                value: appointment.createdAt.toFormattedDateTime,
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                _InfoRow(
                  label: 'Catatan',
                  value: appointment.notes!,
                ),
            ],
          ),

          if (appointment.status == AppointmentStatus.cancelled) ...[
            const SpaceHeight.h16(),
            _buildInfoCard(
              title: 'Info Pembatalan',
              icon: Icons.cancel_outlined,
              iconColor: AppColors.error,
              children: [
                if (appointment.cancelledAt != null)
                  _InfoRow(
                    label: 'Dibatalkan',
                    value: appointment.cancelledAt!.toFormattedDateTime,
                  ),
                if (appointment.cancelledReason != null)
                  _InfoRow(
                    label: 'Alasan',
                    value: appointment.cancelledReason!,
                  ),
              ],
            ),
          ],

          const SpaceHeight.h24(),

          // Action Buttons based on status
          if (isUpdating)
            const Center(child: CircularProgressIndicator())
          else
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
              const SpaceWidth.w8(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SpaceHeight.h12(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Column(
          children: [
            Button.filled(
              onPressed: onConfirm ?? () {},
              label: 'Konfirmasi',
              icon: Icons.check,
            ),
            const SpaceHeight.h8(),
            Button.outlined(
              onPressed: onCancel,
              label: 'Batalkan',
              icon: Icons.close,
              color: AppColors.error,
            ),
          ],
        );
      case AppointmentStatus.confirmed:
        return Column(
          children: [
            if (appointment.isToday)
              Button.filled(
                onPressed: onStart ?? () {},
                label: 'Mulai Treatment',
                icon: Icons.play_arrow,
              ),
            const SpaceHeight.h8(),
            Button.outlined(
              onPressed: onCancel,
              label: 'Batalkan',
              icon: Icons.close,
              color: AppColors.error,
            ),
          ],
        );
      case AppointmentStatus.inProgress:
        return Column(
          children: [
            Button.filled(
              onPressed: onComplete ?? () {},
              label: 'Selesaikan',
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            const SpaceHeight.h8(),
            Button.outlined(
              onPressed: onRecordTreatment,
              label: 'Catat Treatment',
              icon: Icons.assignment,
            ),
          ],
        );
      case AppointmentStatus.completed:
        // Case 1: Has pending transaction - show "Lanjut Bayar"
        if (hasPendingTransaction) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
                        const SpaceWidth.w8(),
                        const Flexible(
                          child: Text(
                            'Menunggu Pembayaran',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (pendingTransactionAmount != null) ...[
                      const SpaceHeight.h8(),
                      Text(
                        pendingTransactionAmount!.currencyFormat,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SpaceHeight.h12(),
              Button.filled(
                onPressed: onContinuePayment,
                label: 'Lanjut Bayar',
                icon: Icons.payment,
                color: AppColors.primary,
              ),
              const SpaceHeight.h8(),
              Button.outlined(
                onPressed: onRecordTreatment,
                label: 'Catat Treatment',
                icon: Icons.assignment,
              ),
            ],
          );
        }

        // Case 2: No transaction yet (not paid) - show "Proses Pembayaran"
        if (!isPaid) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, color: AppColors.warning, size: 20),
                        const SpaceWidth.w8(),
                        const Flexible(
                          child: Text(
                            'Belum Dibayar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight.h8(),
                    Text(
                      appointment.service?.price.currencyFormat ?? 'Rp 0',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight.h12(),
              Button.filled(
                onPressed: onContinuePayment,
                label: 'Proses Pembayaran',
                icon: Icons.payment,
                color: AppColors.primary,
              ),
              const SpaceHeight.h8(),
              Button.outlined(
                onPressed: onRecordTreatment,
                label: 'Catat Treatment',
                icon: Icons.assignment,
              ),
            ],
          );
        }

        // Case 3: Already paid - show completed status
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SpaceWidth.w8(),
                  const Flexible(
                    child: Text(
                      'Appointment selesai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SpaceHeight.h8(),
            Button.filled(
              onPressed: onRecordTreatment,
              label: 'Catat Treatment',
              icon: Icons.assignment,
            ),
          ],
        );
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: AppColors.error, size: 20),
              const SpaceWidth.w8(),
              Flexible(
                child: Text(
                  appointment.status == AppointmentStatus.cancelled
                      ? 'Appointment dibatalkan'
                      : 'Pelanggan tidak hadir',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isPhone;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
          if (isPhone)
            IconButton(
              onPressed: () {
                final cleanPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
                final waUrl = Uri.parse('https://wa.me/$cleanPhone');
                launchUrl(waUrl, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.phone, size: 18),
              color: AppColors.primary,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
