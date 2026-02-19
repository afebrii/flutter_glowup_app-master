import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/service_card.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(FetchServices());
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _ServicePhoneLayout(),
      tablet: _ServiceTabletLayout(),
    );
  }
}

class _ServicePhoneLayout extends StatelessWidget {
  const _ServicePhoneLayout();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const LoadingIndicator(message: 'Memuat layanan...');
        }

        if (state is ServiceError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<ServiceBloc>().add(FetchServices()),
          );
        }

        if (state is ServiceLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, ServiceLoaded state) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchInput(
            hint: 'Cari layanan...',
            onChanged: (value) {
              context.read<ServiceBloc>().add(SearchServices(value));
            },
          ),
        ),

        // Category Chips
        CategoryChipList(
          categories: state.categories,
          selectedCategoryId: state.selectedCategoryId,
          onCategorySelected: (categoryId) {
            if (categoryId == null) {
              context.read<ServiceBloc>().add(ClearSearch());
            } else {
              context.read<ServiceBloc>().add(FetchServicesByCategory(categoryId));
            }
          },
        ),
        const SpaceHeight.h16(),

        // Services Grid
        Expanded(
          child: state.filteredServices.isEmpty
              ? const EmptyState(
                  icon: Icons.spa_outlined,
                  message: 'Tidak ada layanan',
                  subtitle: 'Coba ubah filter atau kata kunci pencarian',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<ServiceBloc>().add(RefreshServices());
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: state.filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = state.filteredServices[index];
                      return ServiceCard(
                        service: service,
                        onTap: () {
                          _showServiceDetail(context, service);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showServiceDetail(BuildContext context, service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceDetailSheet(service: service),
    );
  }
}

class _ServiceTabletLayout extends StatefulWidget {
  const _ServiceTabletLayout();

  @override
  State<_ServiceTabletLayout> createState() => _ServiceTabletLayoutState();
}

class _ServiceTabletLayoutState extends State<_ServiceTabletLayout> {
  int? _selectedServiceId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const LoadingIndicator(message: 'Memuat layanan...');
        }

        if (state is ServiceError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<ServiceBloc>().add(FetchServices()),
          );
        }

        if (state is ServiceLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, ServiceLoaded state) {
    final selectedService = _selectedServiceId != null
        ? state.filteredServices.where((s) => s.id == _selectedServiceId).firstOrNull
        : null;

    return Row(
      children: [
        // Left Panel - List (40%)
        Expanded(
          flex: 40,
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchInput(
                  hint: 'Cari layanan...',
                  onChanged: (value) {
                    context.read<ServiceBloc>().add(SearchServices(value));
                  },
                ),
              ),

              // Category Tab Bar
              CategoryTabBar(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onCategorySelected: (categoryId) {
                  if (categoryId == null) {
                    context.read<ServiceBloc>().add(ClearSearch());
                  } else {
                    context.read<ServiceBloc>().add(FetchServicesByCategory(categoryId));
                  }
                },
              ),

              // Services List
              Expanded(
                child: state.filteredServices.isEmpty
                    ? const EmptyState(
                        icon: Icons.spa_outlined,
                        message: 'Tidak ada layanan',
                        subtitle: 'Coba ubah filter pencarian',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = state.filteredServices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ServiceListTile(
                              service: service,
                              isSelected: _selectedServiceId == service.id,
                              onTap: () {
                                setState(() {
                                  _selectedServiceId = service.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: AppColors.border,
        ),

        // Right Panel - Detail (60%)
        Expanded(
          flex: 60,
          child: selectedService != null
              ? _ServiceDetailPanel(service: selectedService)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      SpaceHeight.h16(),
                      Text(
                        'Pilih layanan untuk melihat detail',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ServiceDetailPanel extends StatelessWidget {
  final dynamic service;

  const _ServiceDetailPanel({required this.service});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: service.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
          ),
          const SpaceHeight.h24(),

          // Name
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),

          // Category Badge
          if (service.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                service.category!.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SpaceHeight.h16(),

          // Info Cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.schedule,
                  label: 'Durasi',
                  value: service.durationFormatted,
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: _InfoCard(
                  icon: Icons.payments_outlined,
                  label: 'Harga',
                  value: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(service.price),
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SpaceHeight.h24(),

          // Description
          if (service.description != null) ...[
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SpaceHeight.h8(),
            Text(
              service.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.spa,
        size: 64,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailSheet extends StatelessWidget {
  final dynamic service;

  const _ServiceDetailSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SpaceHeight.h20(),

                // Image
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa,
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SpaceHeight.h16(),

                // Name
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SpaceHeight.h8(),

                // Duration & Price
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      service.durationFormatted,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(service.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SpaceHeight.h16(),

                // Description
                if (service.description != null) ...[
                  const Divider(),
                  const SpaceHeight.h12(),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SpaceHeight.h8(),
                  Text(
                    service.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
