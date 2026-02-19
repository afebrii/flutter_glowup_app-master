import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/models/responses/treatment_record_model.dart';
import '../bloc/treatment_bloc.dart';
import '../bloc/treatment_event.dart';
import '../bloc/treatment_state.dart';
import 'add_treatment_page.dart';

class TreatmentPage extends StatelessWidget {
  const TreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _TreatmentPhoneLayout(),
      tablet: _TreatmentTabletLayout(),
    );
  }
}

// ==================== PHONE LAYOUT ====================

class _TreatmentPhoneLayout extends StatefulWidget {
  const _TreatmentPhoneLayout();

  @override
  State<_TreatmentPhoneLayout> createState() => _TreatmentPhoneLayoutState();
}

class _TreatmentPhoneLayoutState extends State<_TreatmentPhoneLayout> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TreatmentBloc>().add(const FetchTreatments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddTreatment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTreatmentPage()),
    ).then((result) {
      if (result == true) {
        context.read<TreatmentBloc>().add(const FetchTreatments());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Treatment'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Stack(
      children: [
        Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari treatment...',
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

            // Treatment List
            Expanded(
              child: BlocBuilder<TreatmentBloc, TreatmentState>(
                builder: (context, state) {
                  if (state.isLoading && state.treatments.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null && state.treatments.isEmpty) {
                    return _ErrorWidget(
                      message: state.error!,
                      onRetry: () => context
                          .read<TreatmentBloc>()
                          .add(const FetchTreatments()),
                    );
                  }

                  final filtered = _filterTreatments(state.treatments);

                  if (filtered.isEmpty) {
                    return _EmptyWidget(
                      hasSearch: _searchQuery.isNotEmpty,
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<TreatmentBloc>()
                          .add(const FetchTreatments());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filtered.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SpaceHeight.h8(),
                      itemBuilder: (context, index) {
                        if (index >= filtered.length) {
                          // Load more
                          if (!state.isLoading) {
                            context.read<TreatmentBloc>().add(FetchTreatments(
                                  page: (state.meta?.currentPage ?? 1) + 1,
                                ));
                          }
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return _TreatmentCard(
                          treatment: filtered[index],
                          onTap: () => _showTreatmentDetail(
                              context, filtered[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _navigateToAddTreatment,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
      ),
    );
  }

  List<TreatmentRecordModel> _filterTreatments(
      List<TreatmentRecordModel> treatments) {
    if (_searchQuery.isEmpty) return treatments;
    final query = _searchQuery.toLowerCase();
    return treatments.where((t) {
      final customerName = t.customer?.name.toLowerCase() ?? '';
      final staffName = t.staff?.name.toLowerCase() ?? '';
      final notes = t.notes?.toLowerCase() ?? '';
      return customerName.contains(query) ||
          staffName.contains(query) ||
          notes.contains(query);
    }).toList();
  }

  void _showTreatmentDetail(
      BuildContext context, TreatmentRecordModel treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _TreatmentDetailContent(
            treatment: treatment,
            scrollController: controller,
          ),
        ),
      ),
    );
  }
}

// ==================== TABLET LAYOUT ====================

class _TreatmentTabletLayout extends StatefulWidget {
  const _TreatmentTabletLayout();

  @override
  State<_TreatmentTabletLayout> createState() =>
      _TreatmentTabletLayoutState();
}

class _TreatmentTabletLayoutState extends State<_TreatmentTabletLayout> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TreatmentRecordModel? _selectedTreatment;

  @override
  void initState() {
    super.initState();
    context.read<TreatmentBloc>().add(const FetchTreatments());
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
                              child: const Icon(Icons.medical_services,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SpaceWidth.w12(),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Treatment Records',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Riwayat treatment pelanggan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddTreatmentPage(),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    context
                                        .read<TreatmentBloc>()
                                        .add(const FetchTreatments());
                                  }
                                });
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SpaceHeight.h16(),
                        // Search
                        TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Cari treatment...',
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
                    child: BlocBuilder<TreatmentBloc, TreatmentState>(
                      builder: (context, state) {
                        if (state.isLoading && state.treatments.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.error != null &&
                            state.treatments.isEmpty) {
                          return _ErrorWidget(
                            message: state.error!,
                            onRetry: () => context
                                .read<TreatmentBloc>()
                                .add(const FetchTreatments()),
                          );
                        }

                        final filtered =
                            _filterTreatments(state.treatments);

                        if (filtered.isEmpty) {
                          return _EmptyWidget(
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
                            final treatment = filtered[index];
                            final isSelected =
                                _selectedTreatment?.id == treatment.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _TreatmentCard(
                                treatment: treatment,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() =>
                                      _selectedTreatment = treatment);
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
              child: _selectedTreatment != null
                  ? _TreatmentDetailPanel(
                      treatment: _selectedTreatment!)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services_outlined,
                              size: 64, color: Colors.grey),
                          SpaceHeight.h16(),
                          Text(
                            'Pilih treatment untuk melihat detail',
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

  List<TreatmentRecordModel> _filterTreatments(
      List<TreatmentRecordModel> treatments) {
    if (_searchQuery.isEmpty) return treatments;
    final query = _searchQuery.toLowerCase();
    return treatments.where((t) {
      final customerName = t.customer?.name.toLowerCase() ?? '';
      final staffName = t.staff?.name.toLowerCase() ?? '';
      final notes = t.notes?.toLowerCase() ?? '';
      return customerName.contains(query) ||
          staffName.contains(query) ||
          notes.contains(query);
    }).toList();
  }
}

// ==================== SHARED WIDGETS ====================

class _TreatmentCard extends StatelessWidget {
  final TreatmentRecordModel treatment;
  final VoidCallback? onTap;
  final bool isSelected;

  const _TreatmentCard({
    required this.treatment,
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
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.medical_services,
                size: 18,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SpaceWidth.w12(),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.customer?.name ?? 'Pelanggan #${treatment.customerId}',
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
                    treatment.staff?.name ?? 'Staff #${treatment.staffId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (treatment.notes != null &&
                      treatment.notes!.isNotEmpty) ...[
                    const SpaceHeight.h4(),
                    Text(
                      treatment.notes!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SpaceWidth.w8(),
            // Meta
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  treatment.createdAt?.toFormattedDate ?? '-',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SpaceHeight.h4(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (treatment.hasPhotos)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera,
                                size: 10, color: AppColors.info),
                            const SizedBox(width: 2),
                            Text(
                              '${treatment.totalPhotosCount}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (treatment.hasFollowUp) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (treatment.isFollowUpDue
                                  ? AppColors.warning
                                  : AppColors.success)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.event,
                          size: 10,
                          color: treatment.isFollowUpDue
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentDetailPanel extends StatelessWidget {
  final TreatmentRecordModel treatment;

  const _TreatmentDetailPanel({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _TreatmentDetailBody(treatment: treatment),
    );
  }
}

class _TreatmentDetailContent extends StatelessWidget {
  final TreatmentRecordModel treatment;
  final ScrollController scrollController;

  const _TreatmentDetailContent({
    required this.treatment,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
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
          'Detail Treatment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SpaceHeight.h16(),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: _TreatmentDetailBody(treatment: treatment),
          ),
        ),
      ],
    );
  }
}

class _TreatmentDetailBody extends StatelessWidget {
  final TreatmentRecordModel treatment;

  const _TreatmentDetailBody({required this.treatment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer & Staff Info
        _DetailSection(
          title: 'Informasi',
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Pelanggan',
                value: treatment.customer?.name ??
                    'Pelanggan #${treatment.customerId}',
              ),
              const SpaceHeight.h12(),
              _DetailRow(
                icon: Icons.medical_services_outlined,
                label: 'Staff',
                value:
                    treatment.staff?.name ?? 'Staff #${treatment.staffId}',
              ),
              const SpaceHeight.h12(),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal',
                value: treatment.createdAt?.toFormattedDateTime ?? '-',
              ),
            ],
          ),
        ),
        const SpaceHeight.h20(),

        // Notes
        if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
          _DetailSection(
            title: 'Catatan Treatment',
            child: Text(
              treatment.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SpaceHeight.h20(),
        ],

        // Recommendations
        if (treatment.recommendations != null &&
            treatment.recommendations!.isNotEmpty) ...[
          _DetailSection(
            title: 'Rekomendasi',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: AppColors.info),
                  const SpaceWidth.w8(),
                  Expanded(
                    child: Text(
                      treatment.recommendations!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SpaceHeight.h20(),
        ],

        // Follow Up
        if (treatment.hasFollowUp) ...[
          _DetailSection(
            title: 'Follow Up',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (treatment.isFollowUpDue
                        ? AppColors.warning
                        : AppColors.success)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (treatment.isFollowUpDue
                          ? AppColors.warning
                          : AppColors.success)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 18,
                    color: treatment.isFollowUpDue
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  const SpaceWidth.w8(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatment.followUpDate!.toFormattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          treatment.isFollowUpDue
                              ? 'Sudah jatuh tempo'
                              : '${treatment.daysUntilFollowUp} hari lagi',
                          style: TextStyle(
                            fontSize: 12,
                            color: treatment.isFollowUpDue
                                ? AppColors.warning
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SpaceHeight.h20(),
        ],

        // Photos
        if (treatment.hasPhotos) ...[
          if (treatment.hasBeforePhotos) ...[
            _DetailSection(
              title: 'Foto Sebelum (${treatment.beforePhotoUrls!.length})',
              child: _PhotoGrid(urls: treatment.beforePhotoUrls!),
            ),
            const SpaceHeight.h20(),
          ],
          if (treatment.hasAfterPhotos) ...[
            _DetailSection(
              title: 'Foto Sesudah (${treatment.afterPhotoUrls!.length})',
              child: _PhotoGrid(urls: treatment.afterPhotoUrls!),
            ),
          ],
        ],
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<String> urls;

  const _PhotoGrid({required this.urls});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls
          .map((url) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.broken_image,
                        color: AppColors.textMuted),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

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

class _EmptyWidget extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onClear;

  const _EmptyWidget({required this.hasSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined,
                size: 48, color: AppColors.textMuted),
            const SpaceHeight.h12(),
            Text(
              hasSearch
                  ? 'Tidak ditemukan treatment yang cocok'
                  : 'Belum ada treatment record',
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
