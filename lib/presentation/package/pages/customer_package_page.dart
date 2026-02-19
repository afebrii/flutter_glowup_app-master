import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/package_remote_datasource.dart';
import '../../../data/models/responses/package_model.dart';
import '../../../injection.dart';
import '../bloc/package_bloc.dart';
import '../bloc/package_event.dart';
import '../bloc/package_state.dart';

class CustomerPackagePage extends StatelessWidget {
  const CustomerPackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackageBloc(
        datasource: getIt<PackageRemoteDatasource>(),
      )..add(const FetchCustomerPackages()),
      child: const ResponsiveWidget(
        phone: _CustomerPackagePhoneLayout(),
        tablet: _CustomerPackageTabletLayout(),
      ),
    );
  }
}

// ==================== TABLET LAYOUT ====================

class _CustomerPackageTabletLayout extends StatefulWidget {
  const _CustomerPackageTabletLayout();

  @override
  State<_CustomerPackageTabletLayout> createState() =>
      _CustomerPackageTabletLayoutState();
}

class _CustomerPackageTabletLayoutState
    extends State<_CustomerPackageTabletLayout> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  CustomerPackageModel? _selectedPackage;

  void _fetchFiltered() {
    context.read<PackageBloc>().add(FetchCustomerPackages(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
        ));
  }

  List<CustomerPackageModel> _applyLocalSearch(
      List<CustomerPackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;
    final query = _searchQuery.toLowerCase();
    return packages
        .where((p) =>
            (p.customer?.name ?? '').toLowerCase().contains(query) ||
            (p.package?.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PackageBloc, PackageState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error),
          );
          context.read<PackageBloc>().add(const ClearPackageError());
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success),
          );
          context.read<PackageBloc>().add(const ClearPackageSuccess());
          // Refresh list after session use
          _fetchFiltered();
        }
        // Update selected package if it was updated in state
        if (_selectedPackage != null && state.selectedCustomerPackage != null) {
          if (_selectedPackage!.id == state.selectedCustomerPackage!.id) {
            setState(() => _selectedPackage = state.selectedCustomerPackage);
          }
        }
      },
      builder: (context, state) {
        final filteredPackages =
            _applyLocalSearch(state.customerPackages);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel - Customer Package List (40%)
              Expanded(
                flex: 40,
                child: Column(
                  children: [
                    // Search
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: AppColors.textMuted, size: 20),
                          const SpaceWidth.w8(),
                          Expanded(
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              decoration: const InputDecoration(
                                hintText: 'Cari pelanggan atau paket...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight.h12(),

                    // Status Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Semua',
                            isSelected: _selectedFilter == 'all',
                            onTap: () {
                              setState(() => _selectedFilter = 'all');
                              _fetchFiltered();
                            },
                          ),
                          const SpaceWidth.w8(),
                          _FilterChip(
                            label: 'Aktif',
                            isSelected: _selectedFilter == 'active',
                            color: AppColors.success,
                            onTap: () {
                              setState(() => _selectedFilter = 'active');
                              _fetchFiltered();
                            },
                          ),
                          const SpaceWidth.w8(),
                          _FilterChip(
                            label: 'Selesai',
                            isSelected: _selectedFilter == 'completed',
                            color: AppColors.textMuted,
                            onTap: () {
                              setState(() => _selectedFilter = 'completed');
                              _fetchFiltered();
                            },
                          ),
                          const SpaceWidth.w8(),
                          _FilterChip(
                            label: 'Kadaluarsa',
                            isSelected: _selectedFilter == 'expired',
                            color: AppColors.error,
                            onTap: () {
                              setState(() => _selectedFilter = 'expired');
                              _fetchFiltered();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight.h16(),

                    // List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: state.isLoadingCustomerPackages
                            ? const Center(child: CircularProgressIndicator())
                            : filteredPackages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.card_membership,
                                            size: 48,
                                            color: AppColors.textMuted
                                                .withValues(alpha: 0.5)),
                                        const SpaceHeight.h12(),
                                        const Text('Tidak ada paket pelanggan',
                                            style: TextStyle(
                                                color: AppColors.textMuted)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: filteredPackages.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final cp = filteredPackages[index];
                                      return _CustomerPackageListItem(
                                        customerPackage: cp,
                                        isSelected:
                                            _selectedPackage?.id == cp.id,
                                        onTap: () =>
                                            setState(() =>
                                                _selectedPackage = cp),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel - Detail (60%)
              Expanded(
                flex: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: _selectedPackage != null
                      ? _CustomerPackageDetailPanel(
                          customerPackage: _selectedPackage!,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.card_membership,
                                    size: 48, color: AppColors.textMuted),
                              ),
                              const SpaceHeight.h20(),
                              const Text('Pilih Paket Pelanggan',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SpaceHeight.h8(),
                              const Text(
                                  'Klik paket dari daftar untuk melihat detail',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== PHONE LAYOUT ====================

class _CustomerPackagePhoneLayout extends StatefulWidget {
  const _CustomerPackagePhoneLayout();

  @override
  State<_CustomerPackagePhoneLayout> createState() =>
      _CustomerPackagePhoneLayoutState();
}

class _CustomerPackagePhoneLayoutState
    extends State<_CustomerPackagePhoneLayout> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  void _fetchFiltered() {
    context.read<PackageBloc>().add(FetchCustomerPackages(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
        ));
  }

  List<CustomerPackageModel> _applyLocalSearch(
      List<CustomerPackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;
    final query = _searchQuery.toLowerCase();
    return packages
        .where((p) =>
            (p.customer?.name ?? '').toLowerCase().contains(query) ||
            (p.package?.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paket Pelanggan'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<PackageBloc, PackageState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error),
            );
            context.read<PackageBloc>().add(const ClearPackageError());
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: AppColors.success),
            );
            context.read<PackageBloc>().add(const ClearPackageSuccess());
            _fetchFiltered();
          }
        },
        builder: (context, state) {
          final filteredPackages =
              _applyLocalSearch(state.customerPackages);

          return Column(
            children: [
              // Search & Filter
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Cari pelanggan atau paket...',
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textMuted, size: 20),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Semua',
                            isSelected: _selectedFilter == 'all',
                            onTap: () {
                              setState(() => _selectedFilter = 'all');
                              _fetchFiltered();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Aktif',
                            isSelected: _selectedFilter == 'active',
                            color: AppColors.success,
                            onTap: () {
                              setState(() => _selectedFilter = 'active');
                              _fetchFiltered();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Selesai',
                            isSelected: _selectedFilter == 'completed',
                            color: AppColors.textMuted,
                            onTap: () {
                              setState(() => _selectedFilter = 'completed');
                              _fetchFiltered();
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Kadaluarsa',
                            isSelected: _selectedFilter == 'expired',
                            color: AppColors.error,
                            onTap: () {
                              setState(() => _selectedFilter = 'expired');
                              _fetchFiltered();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: state.isLoadingCustomerPackages
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPackages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_membership,
                                    size: 64,
                                    color: AppColors.textMuted
                                        .withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                const Text('Tidak ada paket pelanggan',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 8),
                                const Text('Coba ubah filter pencarian',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPackages.length,
                            itemBuilder: (context, index) {
                              final cp = filteredPackages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PhoneCustomerPackageCard(
                                  customerPackage: cp,
                                  onTap: () =>
                                      _showCustomerPackageDetail(context, cp),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomerPackageDetail(
      BuildContext context, CustomerPackageModel cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PackageBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: _CustomerPackageDetailContent(customerPackage: cp),
                  ),
                ),
                // Bottom action
                if (cp.isUsable)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -4))
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<PackageBloc, PackageState>(
                        builder: (btnContext, btnState) {
                          return ElevatedButton.icon(
                            onPressed: btnState.isUsingSession
                                ? null
                                : () => _confirmUseSession(
                                    btnContext, cp),
                            icon: btnState.isUsingSession
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.play_circle_outline,
                                    size: 20),
                            label: Text(btnState.isUsingSession
                                ? 'Memproses...'
                                : 'Gunakan Sesi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmUseSession(BuildContext context, CustomerPackageModel cp) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gunakan Sesi'),
        content: Text(
          'Gunakan 1 sesi dari paket "${cp.package?.name ?? 'Paket'}"?\n\n'
          'Sesi terpakai: ${cp.sessionsUsed} / ${cp.sessionsTotal}\n'
          'Sesi tersisa setelah ini: ${cp.sessionsRemaining - 1}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<PackageBloc>()
                  .add(UsePackageSession(cp.id));
              Navigator.pop(context); // close bottom sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Gunakan'),
          ),
        ],
      ),
    );
  }
}

// ==================== SHARED WIDGETS ====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isSelected ? chipColor : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? chipColor : AppColors.textSecondary)),
      ),
    );
  }
}

Color _getStatusColor(CustomerPackageModel cp) {
  switch (cp.statusColorName) {
    case 'green':
      return AppColors.success;
    case 'red':
      return AppColors.error;
    case 'cancelled':
      return const Color(0xFFDC2626);
    case 'orange':
      return AppColors.warning;
    default:
      return AppColors.textMuted;
  }
}

String _getStatusLabel(CustomerPackageModel cp) {
  return cp.statusLabel ?? cp.status;
}

class _CustomerPackageListItem extends StatelessWidget {
  final CustomerPackageModel customerPackage;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomerPackageListItem(
      {required this.customerPackage,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(customerPackage);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 1.5 : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                        customerPackage.package?.name ?? 'Paket #${customerPackage.packageId}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.textPrimary)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(_getStatusLabel(customerPackage),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(customerPackage.customer?.name ?? '-',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: customerPackage.sessionsTotal > 0
                            ? customerPackage.sessionsUsed /
                                customerPackage.sessionsTotal
                            : 0,
                        backgroundColor:
                            AppColors.border.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(customerPackage.usageDisplay,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(customerPackage.expiryStatus,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneCustomerPackageCard extends StatelessWidget {
  final CustomerPackageModel customerPackage;
  final VoidCallback onTap;

  const _PhoneCustomerPackageCard(
      {required this.customerPackage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(customerPackage);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.card_membership,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            customerPackage.package?.name ??
                                'Paket #${customerPackage.packageId}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(customerPackage.customer?.name ?? '-',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_getStatusLabel(customerPackage),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: customerPackage.sessionsTotal > 0
                      ? customerPackage.sessionsUsed /
                          customerPackage.sessionsTotal
                      : 0,
                  backgroundColor: AppColors.border.withValues(alpha: 0.5),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(customerPackage.usageDisplay,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(customerPackage.expiryStatus,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerPackageDetailPanel extends StatelessWidget {
  final CustomerPackageModel customerPackage;

  const _CustomerPackageDetailPanel({required this.customerPackage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                _CustomerPackageDetailContent(customerPackage: customerPackage),
          ),
        ),
        // Action button
        if (customerPackage.isUsable)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: BlocBuilder<PackageBloc, PackageState>(
                builder: (context, state) {
                  return ElevatedButton.icon(
                    onPressed: state.isUsingSession
                        ? null
                        : () => _confirmUseSession(context, customerPackage),
                    icon: state.isUsingSession
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_circle_outline, size: 20),
                    label: Text(state.isUsingSession
                        ? 'Memproses...'
                        : 'Gunakan Sesi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _confirmUseSession(BuildContext context, CustomerPackageModel cp) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Gunakan Sesi'),
        content: Text(
          'Gunakan 1 sesi dari paket "${cp.package?.name ?? 'Paket'}"?\n\n'
          'Sesi terpakai: ${cp.sessionsUsed} / ${cp.sessionsTotal}\n'
          'Sesi tersisa setelah ini: ${cp.sessionsRemaining - 1}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PackageBloc>().add(UsePackageSession(cp.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Gunakan'),
          ),
        ],
      ),
    );
  }
}

class _CustomerPackageDetailContent extends StatelessWidget {
  final CustomerPackageModel customerPackage;

  const _CustomerPackageDetailContent({required this.customerPackage});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(customerPackage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                  customerPackage.package?.name ??
                      'Paket #${customerPackage.packageId}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(_getStatusLabel(customerPackage),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Customer Info
        _DetailSection(
          title: 'Pelanggan',
          icon: Icons.person_outline,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (customerPackage.customer?.name ?? '?')[0],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerPackage.customer?.name ?? '-',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    if (customerPackage.customer != null)
                      Text(customerPackage.customer!.phone,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Session Progress
        _DetailSection(
          title: 'Progres Sesi',
          icon: Icons.donut_large_outlined,
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: customerPackage.sessionsTotal > 0
                      ? customerPackage.sessionsUsed /
                          customerPackage.sessionsTotal
                      : 0,
                  backgroundColor: AppColors.border.withValues(alpha: 0.5),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${customerPackage.sessionsUsed} dari ${customerPackage.sessionsTotal} sesi terpakai',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                  ),
                  if (customerPackage.usagePercentage != null)
                    Text(
                      '${customerPackage.usagePercentage!.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    customerPackage.sessionsRemaining > 0
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 14,
                    color: customerPackage.sessionsRemaining > 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${customerPackage.sessionsRemaining} sesi tersisa',
                    style: TextStyle(
                        fontSize: 13,
                        color: customerPackage.sessionsRemaining > 0
                            ? AppColors.success
                            : AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Grid
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.calendar_today,
                label: 'Tanggal Beli',
                value: customerPackage.purchasedAt.toFormattedDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.event,
                label: 'Berlaku Sampai',
                value: customerPackage.expiresAt?.toFormattedDate ?? '-',
                badge: customerPackage.daysRemaining != null &&
                        !customerPackage.isExpired
                    ? '${customerPackage.daysRemaining} hari'
                    : null,
                badgeColor: customerPackage.isExpired
                    ? AppColors.error
                    : (customerPackage.daysRemaining != null &&
                            customerPackage.daysRemaining! <= 7)
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.payments,
                label: 'Harga Dibayar',
                value: customerPackage.formattedPricePaid ??
                    'Rp ${customerPackage.pricePaid.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.person_pin,
                label: 'Dijual Oleh',
                value: customerPackage.seller?.name ?? '-',
              ),
            ),
          ],
        ),

        // Notes
        if (customerPackage.notes != null &&
            customerPackage.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DetailSection(
            title: 'Catatan',
            icon: Icons.notes,
            child: Text(customerPackage.notes!,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ),
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSection(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;

  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      this.badge,
      this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          if (badge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.success)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(badge!,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeColor ?? AppColors.success)),
            ),
          ],
        ],
      ),
    );
  }
}
