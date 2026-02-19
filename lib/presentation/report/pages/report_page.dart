import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/models/responses/report_model.dart';
import '../../../injection.dart';
import '../../../data/datasources/report_remote_datasource.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportBloc(
        datasource: getIt<ReportRemoteDatasource>(),
      )..add(const LoadReportData(period: 'bulan_ini')),
      child: const ResponsiveWidget(
        phone: _ReportPhoneLayout(),
        tablet: _ReportTabletLayout(),
      ),
    );
  }
}

// Tablet Layout
class _ReportTabletLayout extends StatefulWidget {
  const _ReportTabletLayout();

  @override
  State<_ReportTabletLayout> createState() => _ReportTabletLayoutState();
}

class _ReportTabletLayoutState extends State<_ReportTabletLayout> {
  String _selectedReport = 'penjualan';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Period Selector
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _PeriodChip(
                            label: 'Hari Ini',
                            isSelected: state.period == 'hari_ini',
                            onTap: () => context.read<ReportBloc>().add(const ChangePeriod('hari_ini')),
                          ),
                          const SpaceWidth.w8(),
                          _PeriodChip(
                            label: 'Minggu Ini',
                            isSelected: state.period == 'minggu_ini',
                            onTap: () => context.read<ReportBloc>().add(const ChangePeriod('minggu_ini')),
                          ),
                          const SpaceWidth.w8(),
                          _PeriodChip(
                            label: 'Bulan Ini',
                            isSelected: state.period == 'bulan_ini',
                            onTap: () => context.read<ReportBloc>().add(const ChangePeriod('bulan_ini')),
                          ),
                          const SpaceWidth.w8(),
                          _PeriodChip(
                            label: 'Tahun Ini',
                            isSelected: state.period == 'tahun_ini',
                            onTap: () => context.read<ReportBloc>().add(const ChangePeriod('tahun_ini')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SpaceWidth.w16(),
                  OutlinedButton.icon(
                    onPressed: () => _selectCustomRange(context, state),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(state.startDate != null && state.endDate != null
                        ? '${state.startDate!.day}/${state.startDate!.month} - ${state.endDate!.day}/${state.endDate!.month}'
                        : 'Pilih Tanggal'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SpaceWidth.w12(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SpaceHeight.h20(),

              // Summary Cards
              _buildSummaryCards(state),
              const SpaceHeight.h20(),

              // Main Content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel - Report Types (35%)
                    Expanded(
                      flex: 35,
                      child: Container(
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
                              'Jenis Laporan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SpaceHeight.h16(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _ReportTypeItem(
                                      icon: Icons.bar_chart,
                                      label: 'Laporan Penjualan',
                                      description: 'Ringkasan penjualan dan pendapatan',
                                      isSelected: _selectedReport == 'penjualan',
                                      onTap: () => setState(() => _selectedReport = 'penjualan'),
                                    ),
                                    const SizedBox(height: 10),
                                    _ReportTypeItem(
                                      icon: Icons.spa,
                                      label: 'Laporan Layanan',
                                      description: 'Layanan paling populer',
                                      isSelected: _selectedReport == 'layanan',
                                      onTap: () => setState(() => _selectedReport = 'layanan'),
                                    ),
                                    const SizedBox(height: 10),
                                    _ReportTypeItem(
                                      icon: Icons.people,
                                      label: 'Laporan Pelanggan',
                                      description: 'Analisis pelanggan',
                                      isSelected: _selectedReport == 'pelanggan',
                                      onTap: () => setState(() => _selectedReport = 'pelanggan'),
                                    ),
                                    const SizedBox(height: 10),
                                    _ReportTypeItem(
                                      icon: Icons.person,
                                      label: 'Laporan Staff',
                                      description: 'Performa therapist',
                                      isSelected: _selectedReport == 'staff',
                                      onTap: () => setState(() => _selectedReport = 'staff'),
                                    ),
                                    const SizedBox(height: 10),
                                    _ReportTypeItem(
                                      icon: Icons.card_giftcard,
                                      label: 'Laporan Paket',
                                      description: 'Penjualan paket',
                                      isSelected: _selectedReport == 'paket',
                                      onTap: () => setState(() => _selectedReport = 'paket'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SpaceWidth.w20(),

                    // Right Panel - Report Content (65%)
                    Expanded(
                      flex: 65,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: _buildReportContent(state),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(ReportState state) {
    if (state.isLoading) {
      return const Row(
        children: [
          Expanded(child: _SummaryCardSkeleton()),
          SpaceWidth.w16(),
          Expanded(child: _SummaryCardSkeleton()),
          SpaceWidth.w16(),
          Expanded(child: _SummaryCardSkeleton()),
          SpaceWidth.w16(),
          Expanded(child: _SummaryCardSkeleton()),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Pendapatan',
            value: state.summary.totalRevenue.currencyFormat,
            change: '${state.summary.revenueChange >= 0 ? '+' : ''}${state.summary.revenueChange.toStringAsFixed(1)}%',
            isPositive: state.summary.revenueChange >= 0,
            icon: Icons.payments,
            iconColor: AppColors.success,
          ),
        ),
        const SpaceWidth.w16(),
        Expanded(
          child: _SummaryCard(
            title: 'Total Transaksi',
            value: '${state.summary.totalTransactions}',
            change: '${state.summary.transactionChange >= 0 ? '+' : ''}${state.summary.transactionChange.toStringAsFixed(1)}%',
            isPositive: state.summary.transactionChange >= 0,
            icon: Icons.receipt_long,
            iconColor: AppColors.info,
          ),
        ),
        const SpaceWidth.w16(),
        Expanded(
          child: _SummaryCard(
            title: 'Pelanggan Baru',
            value: '${state.summary.newCustomers}',
            change: '${state.summary.customerChange >= 0 ? '+' : ''}${state.summary.customerChange.toStringAsFixed(1)}%',
            isPositive: state.summary.customerChange >= 0,
            icon: Icons.group_add,
            iconColor: AppColors.primary,
          ),
        ),
        const SpaceWidth.w16(),
        Expanded(
          child: _SummaryCard(
            title: 'Rata-rata Transaksi',
            value: state.summary.averageTransaction.currencyFormat,
            change: '${state.summary.averageChange >= 0 ? '+' : ''}${state.summary.averageChange.toStringAsFixed(1)}%',
            isPositive: state.summary.averageChange >= 0,
            icon: Icons.trending_up,
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildReportContent(ReportState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Terjadi kesalahan'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ReportBloc>().add(const RefreshReport()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    switch (_selectedReport) {
      case 'penjualan':
        return _SalesReport(items: state.salesReport);
      case 'layanan':
        return _ServiceReport(services: state.serviceReport);
      case 'pelanggan':
        return _CustomerReport(stats: state.customerStats, customers: state.topCustomers);
      case 'staff':
        return _StaffReport(staff: state.staffReport);
      case 'paket':
        return _PackageReport(stats: state.packageStats, packages: state.packageReport);
      default:
        return _SalesReport(items: state.salesReport);
    }
  }

  Future<void> _selectCustomRange(BuildContext context, ReportState state) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
    );
    if (picked != null && context.mounted) {
      context.read<ReportBloc>().add(SetCustomDateRange(
        startDate: picked.start,
        endDate: picked.end,
      ));
    }
  }
}

// Phone Layout
class _ReportPhoneLayout extends StatefulWidget {
  const _ReportPhoneLayout();

  @override
  State<_ReportPhoneLayout> createState() => _ReportPhoneLayoutState();
}

class _ReportPhoneLayoutState extends State<_ReportPhoneLayout> {
  String _selectedReport = 'penjualan';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Laporan'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ReportBloc>().add(const RefreshReport());
            },
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Period Selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _PhonePeriodChip(
                              label: 'Hari Ini',
                              isSelected: state.period == 'hari_ini',
                              onTap: () => context.read<ReportBloc>().add(const ChangePeriod('hari_ini')),
                            ),
                            const SizedBox(width: 8),
                            _PhonePeriodChip(
                              label: 'Minggu Ini',
                              isSelected: state.period == 'minggu_ini',
                              onTap: () => context.read<ReportBloc>().add(const ChangePeriod('minggu_ini')),
                            ),
                            const SizedBox(width: 8),
                            _PhonePeriodChip(
                              label: 'Bulan Ini',
                              isSelected: state.period == 'bulan_ini',
                              onTap: () => context.read<ReportBloc>().add(const ChangePeriod('bulan_ini')),
                            ),
                            const SizedBox(width: 8),
                            _PhonePeriodChip(
                              label: 'Tahun Ini',
                              isSelected: state.period == 'tahun_ini',
                              onTap: () => context.read<ReportBloc>().add(const ChangePeriod('tahun_ini')),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _selectCustomRange(context, state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: state.period == 'custom' ? AppColors.info.withValues(alpha: 0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: state.period == 'custom' ? AppColors.info : AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: state.period == 'custom' ? AppColors.info : AppColors.textSecondary),
                                    if (state.startDate != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '${state.startDate!.day}/${state.startDate!.month} - ${state.endDate!.day}/${state.endDate!.month}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Summary Cards
                      _buildPhoneSummaryCards(state),
                    ],
                  ),
                ),

                // Report Type Tabs
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _PhoneReportTab(
                          icon: Icons.bar_chart,
                          label: 'Penjualan',
                          isSelected: _selectedReport == 'penjualan',
                          onTap: () => setState(() => _selectedReport = 'penjualan'),
                        ),
                        const SizedBox(width: 10),
                        _PhoneReportTab(
                          icon: Icons.spa,
                          label: 'Layanan',
                          isSelected: _selectedReport == 'layanan',
                          onTap: () => setState(() => _selectedReport = 'layanan'),
                        ),
                        const SizedBox(width: 10),
                        _PhoneReportTab(
                          icon: Icons.people,
                          label: 'Pelanggan',
                          isSelected: _selectedReport == 'pelanggan',
                          onTap: () => setState(() => _selectedReport = 'pelanggan'),
                        ),
                        const SizedBox(width: 10),
                        _PhoneReportTab(
                          icon: Icons.person,
                          label: 'Staff',
                          isSelected: _selectedReport == 'staff',
                          onTap: () => setState(() => _selectedReport = 'staff'),
                        ),
                        const SizedBox(width: 10),
                        _PhoneReportTab(
                          icon: Icons.card_giftcard,
                          label: 'Paket',
                          isSelected: _selectedReport == 'paket',
                          onTap: () => setState(() => _selectedReport = 'paket'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Report Content
                Expanded(
                  child: _buildPhoneReportContent(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneSummaryCards(ReportState state) {
    if (state.isLoading) {
      return const Row(
        children: [
          Expanded(child: _PhoneSummaryCardSkeleton()),
          SizedBox(width: 12),
          Expanded(child: _PhoneSummaryCardSkeleton()),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _PhoneSummaryCard(
            title: 'Pendapatan',
            value: state.summary.totalRevenue.compactCurrency,
            change: '${state.summary.revenueChange >= 0 ? '+' : ''}${state.summary.revenueChange.toStringAsFixed(1)}%',
            isPositive: state.summary.revenueChange >= 0,
            icon: Icons.payments,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PhoneSummaryCard(
            title: 'Transaksi',
            value: '${state.summary.totalTransactions}',
            change: '${state.summary.transactionChange >= 0 ? '+' : ''}${state.summary.transactionChange.toStringAsFixed(1)}%',
            isPositive: state.summary.transactionChange >= 0,
            icon: Icons.receipt_long,
            iconColor: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneReportContent(ReportState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'Terjadi kesalahan'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ReportBloc>().add(const RefreshReport()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    switch (_selectedReport) {
      case 'penjualan':
        return _PhoneSalesReport(items: state.salesReport);
      case 'layanan':
        return _PhoneServiceReport(services: state.serviceReport);
      case 'pelanggan':
        return _PhoneCustomerReport(stats: state.customerStats, customers: state.topCustomers);
      case 'staff':
        return _PhoneStaffReport(staff: state.staffReport);
      case 'paket':
        return _PhonePackageReport(stats: state.packageStats, packages: state.packageReport);
      default:
        return _PhoneSalesReport(items: state.salesReport);
    }
  }

  Future<void> _selectCustomRange(BuildContext context, ReportState state) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<ReportBloc>().add(SetCustomDateRange(
        startDate: picked.start,
        endDate: picked.end,
      ));
    }
  }
}

// Phone-specific Widgets
class _PhonePeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhonePeriodChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PhoneSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;

  const _PhoneSummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 10, color: isPositive ? AppColors.success : AppColors.error),
                    const SizedBox(width: 2),
                    Text(change, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isPositive ? AppColors.success : AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PhoneSummaryCardSkeleton extends StatelessWidget {
  const _PhoneSummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 10),
          Container(width: 80, height: 20, color: AppColors.border),
          const SizedBox(height: 4),
          Container(width: 60, height: 12, color: AppColors.border),
        ],
      ),
    );
  }
}

class _PhoneReportTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhoneReportTab({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneSalesReport extends StatelessWidget {
  final List<SalesReportItem> items;

  const _PhoneSalesReport({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada data penjualan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text('Grafik Penjualan', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Penjualan Harian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${item.transactions} transaksi', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  item.revenue.currencyFormat,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PhoneServiceReport extends StatelessWidget {
  final List<ServiceReportItem> services;

  const _PhoneServiceReport({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('Tidak ada data layanan'));
    }

    final maxCount = services.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Layanan Populer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            final percentage = maxCount > 0 ? service.count / maxCount : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
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
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      Text(service.revenue.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${service.count} transaksi', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PhoneCustomerReport extends StatelessWidget {
  final CustomerReportStats stats;
  final List<CustomerReportItem> customers;

  const _PhoneCustomerReport({required this.stats, required this.customers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _PhoneStatBox(label: 'Total', value: '${stats.totalCustomers}')),
              const SizedBox(width: 10),
              Expanded(child: _PhoneStatBox(label: 'Aktif', value: '${stats.activeCustomers}')),
              const SizedBox(width: 10),
              Expanded(child: _PhoneStatBox(label: 'Baru', value: '${stats.newCustomers}')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Top Pelanggan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (customers.isEmpty)
            const Center(child: Text('Tidak ada data pelanggan'))
          else
            ...customers.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(c.name.isNotEmpty ? c.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${c.visits} kunjungan', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(c.totalSpent.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _PhoneStaffReport extends StatelessWidget {
  final List<StaffReportItem> staff;

  const _PhoneStaffReport({required this.staff});

  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) {
      return const Center(child: Text('Tidak ada data staff'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performa Staff', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...staff.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Text(s.role, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${s.patients} pasien', style: const TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(s.revenue.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PhonePackageReport extends StatelessWidget {
  final PackageReportStats stats;
  final List<PackageReportItem> packages;

  const _PhonePackageReport({required this.stats, required this.packages});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _PhoneStatBox(label: 'Terjual', value: '${stats.totalSold}')),
              const SizedBox(width: 12),
              Expanded(child: _PhoneStatBox(label: 'Pendapatan', value: stats.totalRevenue.compactCurrency)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Penjualan Paket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (packages.isEmpty)
            const Center(child: Text('Tidak ada data paket'))
          else
            ...packages.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.card_giftcard, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${p.sold} paket terjual', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(p.revenue.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _PhoneStatBox extends StatelessWidget {
  final String label;
  final String value;

  const _PhoneStatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// Helper Widgets
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? AppColors.success : AppColors.error),
                    const SizedBox(width: 2),
                    Text(change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isPositive ? AppColors.success : AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SpaceHeight.h12(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8))),
          const SpaceHeight.h12(),
          Container(width: 100, height: 24, color: AppColors.border),
          const SizedBox(height: 4),
          Container(width: 80, height: 14, color: AppColors.border),
        ],
      ),
    );
  }
}

class _ReportTypeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: isSelected ? 1.5 : 0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            ),
            const SpaceWidth.w12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: AppColors.textPrimary)),
                  Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// Tablet Report Content Widgets
class _SalesReport extends StatelessWidget {
  final List<SalesReportItem> items;

  const _SalesReport({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SpaceHeight.h20(),
          Container(
            height: 200,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: AppColors.textMuted),
                  SpaceHeight.h8(),
                  Text('Grafik Penjualan', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SpaceHeight.h20(),
          const Text('Penjualan Tertinggi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SpaceHeight.h12(),
          _buildSalesTable(),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada data penjualan'));
    }

    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Tanggal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('Transaksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text('Pendapatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ...items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(item.date, style: const TextStyle(fontSize: 13))),
                Expanded(flex: 2, child: Text('${item.transactions}', style: const TextStyle(fontSize: 13), textAlign: TextAlign.center)),
                Expanded(flex: 3, child: Text(item.revenue.currencyFormat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ServiceReport extends StatelessWidget {
  final List<ServiceReportItem> services;

  const _ServiceReport({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('Tidak ada data layanan'));
    }

    final maxCount = services.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SpaceHeight.h20(),
          ...services.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            final percentage = maxCount > 0 ? service.count / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
                      ),
                      const SpaceWidth.w12(),
                      Expanded(child: Text(service.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                      Text('${service.count} transaksi', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SpaceHeight.h8(),
                  Row(
                    children: [
                      const SizedBox(width: 36),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SpaceWidth.w12(),
                      Text(service.revenue.compactCurrency, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CustomerReport extends StatelessWidget {
  final CustomerReportStats stats;
  final List<CustomerReportItem> customers;

  const _CustomerReport({required this.stats, required this.customers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SpaceHeight.h20(),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Total Pelanggan', value: '${stats.totalCustomers}')),
              const SpaceWidth.w12(),
              Expanded(child: _StatBox(label: 'Pelanggan Aktif', value: '${stats.activeCustomers}')),
              const SpaceWidth.w12(),
              Expanded(child: _StatBox(label: 'Pelanggan Baru', value: '${stats.newCustomers}')),
            ],
          ),
          const SpaceHeight.h20(),
          const Text('Top Pelanggan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SpaceHeight.h12(),
          if (customers.isEmpty)
            const Center(child: Text('Tidak ada data pelanggan'))
          else
            ...customers.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(c.name.isNotEmpty ? c.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SpaceWidth.w12(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('${c.visits} kunjungan', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(c.totalSpent.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _StaffReport extends StatelessWidget {
  final List<StaffReportItem> staff;

  const _StaffReport({required this.staff});

  @override
  Widget build(BuildContext context) {
    if (staff.isEmpty) {
      return const Center(child: Text('Tidak ada data staff'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Staff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SpaceHeight.h20(),
          ...staff.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(s.role, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(s.revenue.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('${s.patients} pasien', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PackageReport extends StatelessWidget {
  final PackageReportStats stats;
  final List<PackageReportItem> packages;

  const _PackageReport({required this.stats, required this.packages});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Laporan Paket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SpaceHeight.h20(),
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Paket Terjual', value: '${stats.totalSold}')),
              const SpaceWidth.w12(),
              Expanded(child: _StatBox(label: 'Total Pendapatan', value: stats.totalRevenue.compactCurrency)),
            ],
          ),
          const SpaceHeight.h20(),
          const Text('Penjualan per Paket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SpaceHeight.h12(),
          if (packages.isEmpty)
            const Center(child: Text('Tidak ada data paket'))
          else
            ...packages.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.card_giftcard, color: AppColors.primary, size: 20),
                  ),
                  const SpaceWidth.w12(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('${p.sold} paket terjual', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(p.revenue.compactCurrency, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
