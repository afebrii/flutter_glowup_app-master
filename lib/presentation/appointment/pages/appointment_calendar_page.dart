import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import '../widgets/appointment_detail_panel.dart';
import '../../../data/models/responses/appointment_model.dart';
import '../../../data/models/responses/transaction_model.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../checkout/pages/checkout_page.dart';
import '../../treatment/pages/add_treatment_page.dart';
import 'add_appointment_page.dart';

class AppointmentCalendarPage extends StatefulWidget {
  const AppointmentCalendarPage({super.key});

  @override
  State<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends State<AppointmentCalendarPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(FetchAppointments());
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _AppointmentPhoneLayout(),
      tablet: _AppointmentTabletLayout(),
    );
  }
}

// Phone Layout
class _AppointmentPhoneLayout extends StatefulWidget {
  const _AppointmentPhoneLayout();

  @override
  State<_AppointmentPhoneLayout> createState() => _AppointmentPhoneLayoutState();
}

class _AppointmentPhoneLayoutState extends State<_AppointmentPhoneLayout> {
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status diubah menjadi ${state.appointment.status.label}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const LoadingIndicator(message: 'Memuat appointment...');
        }

        if (state is AppointmentError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<AppointmentBloc>().add(FetchAppointments()),
          );
        }

        if (state is AppointmentLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, AppointmentLoaded state) {
    return Column(
      children: [
        // Calendar Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Calendar Header with toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Kalender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Toggle week/month
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _CalendarToggleButton(
                            label: 'Minggu',
                            isSelected: _calendarFormat == CalendarFormat.week,
                            onTap: () => setState(() => _calendarFormat = CalendarFormat.week),
                          ),
                          _CalendarToggleButton(
                            label: 'Bulan',
                            isSelected: _calendarFormat == CalendarFormat.month,
                            onTap: () => setState(() => _calendarFormat = CalendarFormat.month),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: state.selectedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  context.read<AppointmentBloc>().add(FetchAppointmentsByDate(selectedDay));
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendTextStyle: const TextStyle(color: AppColors.error),
                  outsideDaysVisible: false,
                  cellMargin: const EdgeInsets.all(4),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  leftChevronPadding: EdgeInsets.zero,
                  rightChevronPadding: EdgeInsets.zero,
                  leftChevronIcon: const Icon(Icons.chevron_left, size: 24, color: AppColors.textSecondary),
                  rightChevronIcon: const Icon(Icons.chevron_right, size: 24, color: AppColors.textSecondary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                rowHeight: 42,
                daysOfWeekHeight: 32,
              ),
            ],
          ),
        ),

        // Date Header & Status Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDateLabel(state.selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFullDate(state.selectedDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status chips
              _buildStatusChips(state.appointments),
            ],
          ),
        ),

        // Appointments List
        Expanded(
          child: state.appointments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<AppointmentBloc>().add(RefreshAppointments());
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = state.appointments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PhoneAppointmentCard(
                          appointment: appointment,
                          onTap: () => _showAppointmentDetail(context, appointment),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusChips(List<AppointmentModel> appointments) {
    final pending = appointments.where((a) => a.status == AppointmentStatus.pending).length;
    final confirmed = appointments.where((a) => a.status == AppointmentStatus.confirmed).length;
    final total = appointments.length;

    return Row(
      children: [
        if (pending > 0)
          _MiniChip(count: pending, color: AppColors.warning, label: 'pending'),
        if (pending > 0 && confirmed > 0) const SizedBox(width: 6),
        if (confirmed > 0)
          _MiniChip(count: confirmed, color: AppColors.info, label: 'confirmed'),
        if (total > 0 && (pending > 0 || confirmed > 0)) const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$total total',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available, size: 48, color: AppColors.textMuted),
          ),
          const SpaceHeight.h20(),
          const Text(
            'Tidak Ada Jadwal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),
          const Text(
            'Belum ada appointment untuk tanggal ini',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SpaceHeight.h24(),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
              ).then((result) {
                if (result == true) {
                  context.read<AppointmentBloc>().add(RefreshAppointments());
                }
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Appointment'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAtSameMomentAs(today)) {
      return 'Hari Ini';
    } else if (selectedDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Besok';
    } else if (selectedDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Kemarin';
    }

    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[date.weekday - 1];
  }

  String _getFullDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAppointmentDetail(BuildContext context, AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<AppointmentBloc>(),
        child: _AppointmentDetailSheet(appointment: appointment),
      ),
    );
  }
}

class _CalendarToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final int count;
  final Color color;
  final String label;

  const _MiniChip({
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const _PhoneAppointmentCard({
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time block with status color
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [statusColor, statusColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    appointment.formattedStartTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 16,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.formattedEndTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appointment.customer?.name ?? 'Pelanggan',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          appointment.status.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.spa, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appointment.service?.name ?? 'Service',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(_getSourceIcon(), size: 12, color: AppColors.textMuted),
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
            const SizedBox(width: 8),
            // Arrow
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
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

class _AppointmentDetailSheet extends StatefulWidget {
  final AppointmentModel appointment;

  const _AppointmentDetailSheet({required this.appointment});

  @override
  State<_AppointmentDetailSheet> createState() => _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<_AppointmentDetailSheet> {
  TransactionModel? _appointmentTransaction;
  bool _isCheckingTransaction = false;

  bool get _hasPendingTransaction =>
      _appointmentTransaction != null &&
      (_appointmentTransaction!.status == 'pending' ||
          _appointmentTransaction!.status == 'partial');

  bool get _isPaid =>
      _appointmentTransaction != null &&
      _appointmentTransaction!.status == 'paid';

  @override
  void initState() {
    super.initState();
    // Check transaction for completed appointments
    if (widget.appointment.status == AppointmentStatus.completed) {
      _checkAppointmentTransaction(widget.appointment.id);
    }
  }

  Future<void> _checkAppointmentTransaction(int appointmentId) async {
    setState(() {
      _isCheckingTransaction = true;
      _appointmentTransaction = null;
    });

    final authLocal = AuthLocalDatasource();
    final datasource = TransactionRemoteDatasource(api: ApiService(authLocal: authLocal));
    final result = await datasource.getTransactionByAppointment(appointmentId);

    if (mounted) {
      setState(() {
        _isCheckingTransaction = false;
        result.fold(
          (error) => _appointmentTransaction = null,
          (transaction) => _appointmentTransaction = transaction,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final isUpdating = state is AppointmentLoaded && state.isUpdating;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    AppointmentDetailPanel(
                      appointment: widget.appointment,
                      isUpdating: isUpdating || _isCheckingTransaction,
                      hasPendingTransaction: _hasPendingTransaction,
                      pendingTransactionAmount: _hasPendingTransaction
                          ? _appointmentTransaction?.totalAmount.toInt()
                          : null,
                      isPaid: _isPaid,
                      onConfirm: () {
                        context.read<AppointmentBloc>().add(
                          UpdateAppointmentStatus(
                            widget.appointment.id,
                            AppointmentStatus.confirmed,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      onStart: () {
                        context.read<AppointmentBloc>().add(
                          UpdateAppointmentStatus(
                            widget.appointment.id,
                            AppointmentStatus.inProgress,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      onComplete: () {
                        _showCompleteAndPayDialog(context, widget.appointment);
                      },
                      onCancel: () => _showCancelDialog(context, widget.appointment),
                      onRecordTreatment: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTreatmentPage(
                              appointmentId: widget.appointment.id,
                              customerId: widget.appointment.customerId,
                              customerName: widget.appointment.customer?.name ?? 'Pelanggan',
                              serviceName: widget.appointment.service?.name ?? 'Service',
                            ),
                          ),
                        );
                      },
                      onContinuePayment: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              preselectedAppointment: widget.appointment,
                              existingTransaction: _hasPendingTransaction
                                  ? _appointmentTransaction
                                  : null,
                            ),
                          ),
                        );
                        // Refresh appointments after checkout
                        if (context.mounted) {
                          context.read<AppointmentBloc>().add(RefreshAppointments());
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCompleteAndPayDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            const SpaceWidth.w12(),
            const Text('Treatment Selesai'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Treatment telah selesai. Lanjutkan ke pembayaran?'),
            const SpaceHeight.h16(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.service?.name ?? 'Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SpaceHeight.h4(),
                  Text(
                    appointment.customer?.name ?? 'Customer',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SpaceHeight.h8(),
                  Text(
                    appointment.service?.price.currencyFormat ?? 'Rp 0',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              // Just mark as completed without payment
              context.read<AppointmentBloc>().add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.completed,
                ),
              );
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              // Mark as completed
              context.read<AppointmentBloc>().add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.completed,
                ),
              );
              // Navigate to checkout with appointment data
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    preselectedAppointment: appointment,
                  ),
                ),
              );
              // Refresh appointments after checkout
              if (context.mounted) {
                context.read<AppointmentBloc>().add(RefreshAppointments());
              }
            },
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Proses Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin membatalkan appointment ini?'),
            const SpaceHeight.h16(),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan',
                hintText: 'Masukkan alasan pembatalan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Alasan pembatalan wajib diisi')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              context.read<AppointmentBloc>().add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.cancelled,
                  cancelledReason: reasonController.text.trim(),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }
}

// Tablet Layout
class _AppointmentTabletLayout extends StatefulWidget {
  const _AppointmentTabletLayout();

  @override
  State<_AppointmentTabletLayout> createState() => _AppointmentTabletLayoutState();
}

class _AppointmentTabletLayoutState extends State<_AppointmentTabletLayout> {
  TransactionModel? _appointmentTransaction;
  bool _isCheckingTransaction = false;

  bool get _hasPendingTransaction =>
      _appointmentTransaction != null &&
      (_appointmentTransaction!.status == 'pending' ||
          _appointmentTransaction!.status == 'partial');

  bool get _isPaid =>
      _appointmentTransaction != null &&
      _appointmentTransaction!.status == 'paid';

  Future<void> _checkAppointmentTransaction(int appointmentId) async {
    setState(() {
      _isCheckingTransaction = true;
      _appointmentTransaction = null; // Reset state
    });

    final authLocal = AuthLocalDatasource();
    final datasource = TransactionRemoteDatasource(api: ApiService(authLocal: authLocal));

    // Get any transaction for this appointment (no status filter)
    final result = await datasource.getTransactionByAppointment(appointmentId);

    if (mounted) {
      setState(() {
        _isCheckingTransaction = false;
        result.fold(
          (error) => _appointmentTransaction = null,
          (transaction) => _appointmentTransaction = transaction,
        );
      });
    }
  }

  int? _lastCheckedAppointmentId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status diubah menjadi ${state.appointment.status.label}'),
              backgroundColor: AppColors.success,
            ),
          );
          // Re-check pending transaction after status update
          if (state.appointment.status == AppointmentStatus.completed) {
            // Reset to force re-check
            _lastCheckedAppointmentId = null;
            _appointmentTransaction = null;
            _checkAppointmentTransaction(state.appointment.id);
          }
        }
        // Check pending transaction when appointment is selected
        if (state is AppointmentLoaded && state.selectedAppointment != null) {
          final selectedId = state.selectedAppointment!.id;
          // Always check transaction for completed appointments when selection changes
          if (state.selectedAppointment!.status == AppointmentStatus.completed) {
            // Always re-check when appointment changes OR when transaction is null
            if (_lastCheckedAppointmentId != selectedId || _appointmentTransaction == null) {
              _lastCheckedAppointmentId = selectedId;
              _appointmentTransaction = null;
              _checkAppointmentTransaction(selectedId);
            }
          } else {
            // Reset transaction state for non-completed appointments
            _lastCheckedAppointmentId = selectedId;
            _appointmentTransaction = null;
          }
        }
      },
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const LoadingIndicator(message: 'Memuat appointment...');
        }

        if (state is AppointmentError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<AppointmentBloc>().add(FetchAppointments()),
          );
        }

        if (state is AppointmentLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, AppointmentLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Calendar (35%)
          Expanded(
            flex: 35,
            child: Column(
              children: [
                // Calendar Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: state.selectedDate,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          context.read<AppointmentBloc>().add(FetchAppointmentsByDate(selectedDay));
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: const TextStyle(color: AppColors.error),
                          outsideDaysVisible: false,
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          leftChevronIcon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_left, size: 20),
                          ),
                          rightChevronIcon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.chevron_right, size: 20),
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SpaceHeight.h16(),

                // Quick Stats
                _buildQuickStats(state),
              ],
            ),
          ),
          const SpaceWidth.w20(),

          // Middle Panel - Appointments List (35%)
          Expanded(
            flex: 35,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                        ),
                        const SpaceWidth.w12(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDateLabel(state.selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${state.appointments.length} appointment',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
                            ).then((result) {
                              if (result == true) {
                                context.read<AppointmentBloc>().add(RefreshAppointments());
                              }
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: state.appointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.event_busy, size: 40, color: AppColors.textMuted),
                                ),
                                const SpaceHeight.h16(),
                                const Text(
                                  'Tidak ada appointment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SpaceHeight.h4(),
                                const Text(
                                  'Belum ada jadwal untuk tanggal ini',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.appointments.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final appointment = state.appointments[index];
                              return _AppointmentListItem(
                                appointment: appointment,
                                isSelected: state.selectedAppointment?.id == appointment.id,
                                onTap: () {
                                  context.read<AppointmentBloc>().add(
                                    SelectAppointment(appointment.id),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SpaceWidth.w20(),

          // Right Panel - Detail (30%)
          Expanded(
            flex: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: state.selectedAppointment != null
                  ? Column(
                      children: [
                        // Detail Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                              const SpaceWidth.w8(),
                              const Text(
                                'Detail Appointment',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final selectedId = state.selectedAppointment!.id;
                              final txAppointmentId = _appointmentTransaction?.appointmentId;
                              final isPaidForThis = _isPaid && txAppointmentId == selectedId;
                              final hasPendingForThis = _hasPendingTransaction && txAppointmentId == selectedId;

                              return AppointmentDetailPanel(
                                appointment: state.selectedAppointment!,
                                isUpdating: state.isUpdating || _isCheckingTransaction,
                                hasPendingTransaction: hasPendingForThis,
                                pendingTransactionAmount: hasPendingForThis
                                    ? _appointmentTransaction?.totalAmount.toInt()
                                    : null,
                                isPaid: isPaidForThis,
                                onConfirm: () {
                                  context.read<AppointmentBloc>().add(
                                    UpdateAppointmentStatus(
                                      state.selectedAppointment!.id,
                                      AppointmentStatus.confirmed,
                                    ),
                                  );
                                },
                                onStart: () {
                                  context.read<AppointmentBloc>().add(
                                    UpdateAppointmentStatus(
                                      state.selectedAppointment!.id,
                                      AppointmentStatus.inProgress,
                                    ),
                                  );
                                },
                                onComplete: () {
                                  _showCompleteAndPayDialog(context, state.selectedAppointment!);
                                },
                                onCancel: () => _showCancelDialog(context, state.selectedAppointment!),
                                onRecordTreatment: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTreatmentPage(
                                        appointmentId: state.selectedAppointment!.id,
                                        customerId: state.selectedAppointment!.customerId,
                                        customerName: state.selectedAppointment!.customer?.name ?? 'Pelanggan',
                                        serviceName: state.selectedAppointment!.service?.name ?? 'Service',
                                      ),
                                    ),
                                  );
                                },
                                onContinuePayment: () async {
                                  final appointmentId = state.selectedAppointment!.id;
                                  final existingTx = _hasPendingTransaction ? _appointmentTransaction : null;
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutPage(
                                        preselectedAppointment: state.selectedAppointment,
                                        existingTransaction: existingTx,
                                      ),
                                    ),
                                  );
                                  // Refresh transaction check after returning from checkout
                                  if (mounted) {
                                    // Use post frame callback to ensure UI is stable before refreshing
                                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                                      if (mounted) {
                                        // Reset to force re-check
                                        _lastCheckedAppointmentId = null;
                                        _appointmentTransaction = null;
                                        await _checkAppointmentTransaction(appointmentId);
                                      }
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.touch_app, size: 48, color: AppColors.textMuted),
                          ),
                          const SpaceHeight.h20(),
                          const Text(
                            'Pilih Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SpaceHeight.h8(),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Klik appointment dari daftar untuk melihat detail',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppointmentLoaded state) {
    final pending = state.appointments.where((a) => a.status == AppointmentStatus.pending).length;
    final confirmed = state.appointments.where((a) => a.status == AppointmentStatus.confirmed).length;
    final inProgress = state.appointments.where((a) => a.status == AppointmentStatus.inProgress).length;
    final completed = state.appointments.where((a) => a.status == AppointmentStatus.completed).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Hari Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h12(),
          Row(
            children: [
              Expanded(child: _StatBadge(label: 'Pending', count: pending, color: AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(child: _StatBadge(label: 'Confirmed', count: confirmed, color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatBadge(label: 'Proses', count: inProgress, color: AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _StatBadge(label: 'Selesai', count: completed, color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isAtSameMomentAs(today)) {
      return 'Hari Ini';
    } else if (selectedDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Besok';
    } else if (selectedDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Kemarin';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin membatalkan appointment ini?'),
            const SpaceHeight.h16(),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan',
                hintText: 'Masukkan alasan pembatalan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Alasan pembatalan wajib diisi')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<AppointmentBloc>().add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.cancelled,
                  cancelledReason: reasonController.text.trim(),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showCompleteAndPayDialog(BuildContext context, AppointmentModel appointment) {
    final bloc = context.read<AppointmentBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            const SpaceWidth.w12(),
            const Text('Treatment Selesai'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Treatment telah selesai. Lanjutkan ke pembayaran?'),
            const SpaceHeight.h16(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.service?.name ?? 'Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SpaceHeight.h4(),
                  Text(
                    appointment.customer?.name ?? 'Customer',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SpaceHeight.h8(),
                  Text(
                    appointment.service?.price.currencyFormat ?? 'Rp 0',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Just mark as completed without payment
              bloc.add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.completed,
                ),
              );
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Mark as completed
              bloc.add(
                UpdateAppointmentStatus(
                  appointment.id,
                  AppointmentStatus.completed,
                ),
              );
              // Navigate to checkout with appointment data and wait for result
              _navigateToCheckoutAndRefresh(appointment);
            },
            icon: const Icon(Icons.payment, size: 18),
            label: const Text('Proses Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCheckoutAndRefresh(AppointmentModel appointment) async {
    final appointmentId = appointment.id;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          preselectedAppointment: appointment,
        ),
      ),
    );
    // Refresh transaction check after returning from checkout
    if (mounted) {
      // Use post frame callback to ensure UI is stable before refreshing
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // Reset lastCheckedAppointmentId to force re-check
          _lastCheckedAppointmentId = null;
          _appointmentTransaction = null;
          await _checkAppointmentTransaction(appointmentId);
        }
      });
    }
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentListItem extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AppointmentListItem({
    required this.appointment,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            // Time
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    appointment.formattedStartTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    appointment.formattedEndTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor.withValues(alpha: 0.7),
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
                  Text(
                    appointment.customer?.name ?? 'Pelanggan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.service?.name ?? 'Service',
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
            // Status indicator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
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
}
