import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/models/responses/user_model.dart';
import '../bloc/staff_bloc.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _StaffPhoneLayout(),
      tablet: _StaffTabletLayout(),
    );
  }
}

// ==================== PHONE LAYOUT ====================

class _StaffPhoneLayout extends StatefulWidget {
  const _StaffPhoneLayout();

  @override
  State<_StaffPhoneLayout> createState() => _StaffPhoneLayoutState();
}

class _StaffPhoneLayoutState extends State<_StaffPhoneLayout> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const FetchStaff());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari staff...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Staff List
        Expanded(
          child: BlocBuilder<StaffBloc, StaffState>(
            builder: (context, state) {
              if (state.isLoading && state.staff.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null && state.staff.isEmpty) {
                return _StaffErrorWidget(
                  message: state.error!,
                  onRetry: () =>
                      context.read<StaffBloc>().add(const FetchStaff()),
                );
              }

              final filtered = _filterStaff(state.staff);

              if (filtered.isEmpty) {
                return _StaffEmptyWidget(
                  hasSearch: _searchQuery.isNotEmpty,
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StaffBloc>().add(const FetchStaff());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SpaceHeight.h8(),
                  itemBuilder: (context, index) {
                    return _StaffCard(
                      staff: filtered[index],
                      onTap: () =>
                          _showStaffDetail(context, filtered[index]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
      ),
    );
  }

  List<UserModel> _filterStaff(List<UserModel> staff) {
    if (_searchQuery.isEmpty) return staff;
    final query = _searchQuery.toLowerCase();
    return staff.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query) ||
          s.role.toLowerCase().contains(query);
    }).toList();
  }

  void _showStaffDetail(BuildContext context, UserModel staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SpaceHeight.h16(),
              const Text(
                'Detail Staff',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SpaceHeight.h16(),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: _StaffDetailBody(staff: staff),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TABLET LAYOUT ====================

class _StaffTabletLayout extends StatefulWidget {
  const _StaffTabletLayout();

  @override
  State<_StaffTabletLayout> createState() => _StaffTabletLayoutState();
}

class _StaffTabletLayoutState extends State<_StaffTabletLayout> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserModel? _selectedStaff;

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(const FetchStaff());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - List (40%)
          Expanded(
            flex: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.people,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SpaceWidth.w12(),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar Staff',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Kelola staff klinik',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SpaceHeight.h16(),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Cari staff...',
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textMuted, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // List
                  Expanded(
                    child: BlocBuilder<StaffBloc, StaffState>(
                      builder: (context, state) {
                        if (state.isLoading && state.staff.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.error != null && state.staff.isEmpty) {
                          return _StaffErrorWidget(
                            message: state.error!,
                            onRetry: () => context
                                .read<StaffBloc>()
                                .add(const FetchStaff()),
                          );
                        }

                        final filtered = _filterStaff(state.staff);

                        if (filtered.isEmpty) {
                          return _StaffEmptyWidget(
                            hasSearch: _searchQuery.isNotEmpty,
                            onClear: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final staff = filtered[index];
                            final isSelected =
                                _selectedStaff?.id == staff.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _StaffCard(
                                staff: staff,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(
                                      () => _selectedStaff = staff);
                                },
                              ),
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
              child: _selectedStaff != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child:
                          _StaffDetailBody(staff: _selectedStaff!),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey),
                          SpaceHeight.h16(),
                          Text(
                            'Pilih staff untuk melihat detail',
                            style: TextStyle(color: Colors.grey),
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

  List<UserModel> _filterStaff(List<UserModel> staff) {
    if (_searchQuery.isEmpty) return staff;
    final query = _searchQuery.toLowerCase();
    return staff.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query) ||
          s.role.toLowerCase().contains(query);
    }).toList();
  }
}

// ==================== SHARED WIDGETS ====================

class _StaffCard extends StatelessWidget {
  final UserModel staff;
  final VoidCallback? onTap;
  final bool isSelected;

  const _StaffCard({
    required this.staff,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                staff.initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            const SpaceWidth.w12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SpaceHeight.h4(),
                  Text(
                    staff.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SpaceWidth.w8(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RoleBadge(role: staff.role),
                const SpaceHeight.h4(),
                _StatusBadge(isActive: staff.isActive),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffDetailBody extends StatelessWidget {
  final UserModel staff;

  const _StaffDetailBody({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  staff.initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SpaceHeight.h12(),
              Text(
                staff.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SpaceHeight.h4(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoleBadge(role: staff.role),
                  const SpaceWidth.w8(),
                  _StatusBadge(isActive: staff.isActive),
                ],
              ),
            ],
          ),
        ),
        const SpaceHeight.h24(),

        // Info
        _StaffInfoSection(
          title: 'Informasi Kontak',
          children: [
            _StaffInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: staff.email,
            ),
            if (staff.phone != null)
              _StaffInfoRow(
                icon: Icons.phone_outlined,
                label: 'Telepon',
                value: staff.phone!,
              ),
          ],
        ),
        const SpaceHeight.h16(),

        _StaffInfoSection(
          title: 'Informasi Akun',
          children: [
            _StaffInfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: staff.roleDisplayName,
            ),
            _StaffInfoRow(
              icon: Icons.circle,
              label: 'Status',
              value: staff.isActive ? 'Aktif' : 'Nonaktif',
              valueColor: staff.isActive ? AppColors.success : AppColors.error,
            ),
            if (staff.createdAt != null)
              _StaffInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Bergabung',
                value: staff.createdAt!.toFormattedDate,
              ),
          ],
        ),
      ],
    );
  }
}

class _StaffInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StaffInfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h12(),
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: child,
              )),
        ],
      ),
    );
  }
}

class _StaffInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StaffInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SpaceWidth.w12(),
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
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  Color get _color {
    switch (role) {
      case 'owner':
        return AppColors.warning;
      case 'admin':
        return AppColors.info;
      case 'beautician':
        return AppColors.statusInProgress;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (role) {
      case 'owner':
        return 'Pemilik';
      case 'admin':
        return 'Admin';
      case 'beautician':
        return 'Beautician';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

class _StaffErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StaffErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SpaceHeight.h12(),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SpaceHeight.h16(),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffEmptyWidget extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onClear;

  const _StaffEmptyWidget({required this.hasSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 48, color: AppColors.textMuted),
            const SpaceHeight.h12(),
            Text(
              hasSearch
                  ? 'Tidak ditemukan staff yang cocok'
                  : 'Belum ada data staff',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (hasSearch) ...[
              const SpaceHeight.h12(),
              TextButton(
                onPressed: onClear,
                child: const Text('Hapus Pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
