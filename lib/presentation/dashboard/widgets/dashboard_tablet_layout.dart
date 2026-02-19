import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../data/models/responses/dashboard_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'revenue_chart.dart';

class DashboardTabletLayout extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardTabletLayout({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state.isLoading && state.data == null) {
          return const LoadingIndicator(message: 'Memuat dashboard...');
        }

        if (state.error != null && state.data == null) {
          return ErrorState(
            message: state.error!,
            onRetry: () {
              context.read<DashboardBloc>().add(FetchDashboard());
            },
          );
        }

        if (state.data != null) {
          return _buildContent(context, state.data!, onNavigate);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardModel data, Function(int)? onNavigate) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Quick Actions (prominent) + Stats Summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions - Large & Prominent
                Expanded(
                  flex: 45,
                  child: _buildQuickActionsCard(onNavigate),
                ),
                const SpaceWidth.w20(),
                // Stats Summary
                Expanded(
                  flex: 55,
                  child: _buildStatsSummary(data),
                ),
              ],
            ),
            const SpaceHeight.h20(),

            // Row 2: Revenue Chart + Today's Appointments
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Chart
                Expanded(
                  flex: 55,
                  child: RevenueChartCard(
                    data: data.revenueChart,
                    chartHeight: 260,
                  ),
                ),
                const SpaceWidth.w20(),
                // Today's Appointments
                Expanded(
                  flex: 45,
                  child: _buildAppointmentsCard(data.todayAppointmentsList, onNavigate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(Function(int)? onNavigate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SpaceWidth.w12(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Akses fitur utama dengan cepat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SpaceHeight.h20(),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.add_circle,
                  label: 'Booking Baru',
                  subtitle: 'Buat jadwal',
                  onTap: () => onNavigate?.call(1), // Jadwal
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.person_add,
                  label: 'Pelanggan',
                  subtitle: 'Tambah baru',
                  onTap: () => onNavigate?.call(2), // Pelanggan
                ),
              ),
            ],
          ),
          const SpaceHeight.h12(),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.point_of_sale,
                  label: 'Checkout',
                  subtitle: 'Proses bayar',
                  onTap: () => onNavigate?.call(5), // Checkout
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.analytics,
                  label: 'Laporan',
                  subtitle: 'Lihat data',
                  onTap: () => onNavigate?.call(7), // Laporan
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(DashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h20(),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.payments,
                  iconColor: AppColors.success,
                  iconBg: AppColors.successLight,
                  value: data.todayRevenue.compactCurrency,
                  label: 'Pendapatan',
                ),
              ),
              const SpaceWidth.w16(),
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_today,
                  iconColor: AppColors.info,
                  iconBg: AppColors.infoLight,
                  value: '${data.todayAppointments}',
                  label: 'Appointment',
                ),
              ),
            ],
          ),
          const SpaceHeight.h16(),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.group_add,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primary.withValues(alpha: 0.1),
                  value: '${data.newCustomers}',
                  label: 'Pelanggan Baru',
                ),
              ),
              const SpaceWidth.w16(),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle,
                  iconColor: AppColors.statusCompleted,
                  iconBg: AppColors.statusCompletedBg,
                  value: '${data.completedTreatments}',
                  label: 'Treatment Selesai',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard(List<TodayAppointment> appointments, Function(int)? onNavigate) {
    final displayItems = appointments.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.schedule, color: AppColors.info, size: 20),
              ),
              const SpaceWidth.w12(),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Appointment yang akan datang',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => onNavigate?.call(1),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: const Text('Semua', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SpaceHeight.h16(),
          if (displayItems.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 40, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SpaceHeight.h8(),
                    const Text(
                      'Tidak ada jadwal',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _AppointmentTile(
                    appointment: item,
                    onTap: () => onNavigate?.call(1),
                  ),
                  if (index < displayItems.length - 1)
                    const Divider(height: 16),
                ],
              );
            }),
          if (appointments.length > 5) ...[
            const SpaceHeight.h12(),
            Center(
              child: Text(
                '+${appointments.length - 5} jadwal lainnya',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SpaceWidth.w12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final TodayAppointment appointment;
  final VoidCallback? onTap;

  const _AppointmentTile({required this.appointment, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Time badge
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  appointment.formattedStartTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SpaceWidth.w12(),
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
                  const SizedBox(height: 2),
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
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
