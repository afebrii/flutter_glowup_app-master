import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../data/models/responses/dashboard_model.dart';
import '../../appointment/pages/add_appointment_page.dart';
import '../../checkout/pages/checkout_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'stats_card.dart';
import 'revenue_chart.dart';
import 'today_appointments_list.dart';

class DashboardPhoneLayout extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardPhoneLayout({super.key, this.onNavigate});

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
          return _buildContent(context, state.data!);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardModel data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Stats Row
            StatsRow(
              stats: [
                StatsItemData(
                  value: data.todayRevenue.compactCurrency,
                  label: 'Pendapatan',
                  color: AppColors.success,
                ),
                StatsItemData(
                  value: '${data.todayAppointments}',
                  label: 'Appointment',
                  color: AppColors.info,
                ),
                StatsItemData(
                  value: '${data.completedTreatments}',
                  label: 'Selesai',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SpaceHeight.h16(),

            // Quick Actions
            _buildQuickActions(context),
            const SpaceHeight.h16(),

            // Revenue Chart
            RevenueChartCard(
              data: data.revenueChart,
              chartHeight: 160,
            ),
            const SpaceHeight.h16(),

            // Today's Appointments
            TodayAppointmentsList(
              appointments: data.todayAppointmentsList,
              onViewAll: () {
                onNavigate?.call(1); // Navigate to Jadwal tab
              },
              onAppointmentTap: (appointment) {
                onNavigate?.call(1); // Navigate to Jadwal tab
              },
            ),
            const SpaceHeight.h16(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add,
            label: 'Booking',
            color: AppColors.primary,
            onTap: () {
              // Navigate to Add Appointment page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
              );
            },
          ),
        ),
        const SpaceWidth.w8(),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.point_of_sale,
            label: 'Checkout',
            color: AppColors.success,
            onTap: () {
              // Navigate to Checkout page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutPage()),
              );
            },
          ),
        ),
        const SpaceWidth.w8(),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add,
            label: 'Pelanggan',
            color: AppColors.info,
            onTap: () {
              // Navigate to Customer page (index 2)
              onNavigate?.call(2);
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
