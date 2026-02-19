import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/package_remote_datasource.dart';
import '../../../data/models/responses/package_model.dart';
import '../../../injection.dart';
import '../bloc/package_bloc.dart';
import '../bloc/package_event.dart';
import '../bloc/package_state.dart';

class PackagePage extends StatelessWidget {
  final Function(int)? onNavigate;

  const PackagePage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PackageBloc(
        datasource: getIt<PackageRemoteDatasource>(),
      )..add(const FetchPackages()),
      child: ResponsiveWidget(
        phone: _PackagePhoneLayout(onNavigate: onNavigate),
        tablet: _PackageTabletLayout(onNavigate: onNavigate),
      ),
    );
  }
}

// Tablet Layout
class _PackageTabletLayout extends StatefulWidget {
  final Function(int)? onNavigate;

  const _PackageTabletLayout({this.onNavigate});

  @override
  State<_PackageTabletLayout> createState() => _PackageTabletLayoutState();
}

class _PackageTabletLayoutState extends State<_PackageTabletLayout> {
  String _searchQuery = '';
  PackageModel? _selectedPackage;

  List<PackageModel> _applyLocalSearch(List<PackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;
    return packages.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (p.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PackageBloc, PackageState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
          context.read<PackageBloc>().add(const ClearPackageError());
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
          );
          context.read<PackageBloc>().add(const ClearPackageSuccess());
        }
      },
      builder: (context, state) {
        final filteredPackages = _applyLocalSearch(state.packages);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel - Package List (40%)
              Expanded(
                flex: 40,
                child: Column(
                  children: [
                    // Header with Search
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                                const SpaceWidth.w8(),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) => setState(() => _searchQuery = value),
                                    decoration: const InputDecoration(
                                      hintText: 'Cari paket...',
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
                        ),
                      ],
                    ),
                    const SpaceHeight.h16(),

                    // Package List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredPackages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.card_giftcard, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                        const SpaceHeight.h12(),
                                        const Text('Tidak ada paket', style: TextStyle(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: filteredPackages.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final package = filteredPackages[index];
                                      return _PackageListItem(
                                        package: package,
                                        isSelected: _selectedPackage?.id == package.id,
                                        onTap: () => setState(() => _selectedPackage = package),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel - Package Detail (60%)
              Expanded(
                flex: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: _selectedPackage != null
                      ? _PackageDetailPanel(
                          package: _selectedPackage!,
                          onBuyNow: widget.onNavigate != null ? () => widget.onNavigate!(5) : null,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                                child: const Icon(Icons.card_giftcard, size: 48, color: AppColors.textMuted),
                              ),
                              const SpaceHeight.h20(),
                              const Text('Pilih Paket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SpaceHeight.h8(),
                              const Text('Klik paket dari daftar untuk melihat detail', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
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

// Phone Layout
class _PackagePhoneLayout extends StatefulWidget {
  final Function(int)? onNavigate;

  const _PackagePhoneLayout({this.onNavigate});

  @override
  State<_PackagePhoneLayout> createState() => _PackagePhoneLayoutState();
}

class _PackagePhoneLayoutState extends State<_PackagePhoneLayout> {
  String _searchQuery = '';

  List<PackageModel> _applyLocalSearch(List<PackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;
    return packages.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (p.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paket'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<PackageBloc, PackageState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
            );
            context.read<PackageBloc>().add(const ClearPackageError());
          }
        },
        builder: (context, state) {
          final filteredPackages = _applyLocalSearch(state.packages);

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari paket...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              // Package List
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPackages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_giftcard, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                const Text('Tidak ada paket', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredPackages.length,
                            itemBuilder: (context, index) {
                              final package = filteredPackages[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PhonePackageCard(
                                  package: package,
                                  onTap: () => _showPackageDetail(package),
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

  void _showPackageDetail(PackageModel package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _PackageDetailContent(package: package),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _PackageListItem extends StatelessWidget {
  final PackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageListItem({required this.package, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: isSelected ? 1.5 : 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(package.name, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: AppColors.textPrimary)),
                  ),
                  if (package.discountPercentage != null && package.discountPercentage! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('-${package.discountPercentage!.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(package.displayPrice, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(width: 8),
                  if (package.originalPrice > package.packagePrice)
                    Text(
                      'Rp ${package.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.event_repeat, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${package.totalSessions} sesi', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(package.validityDisplay, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhonePackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onTap;

  const _PhonePackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.card_giftcard, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(package.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        if (package.description != null)
                          Text(package.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (package.discountPercentage != null && package.discountPercentage! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('-${package.discountPercentage!.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_repeat, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${package.totalSessions} sesi', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(package.validityDisplay, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(package.displayPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageDetailPanel extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onBuyNow;

  const _PackageDetailPanel({required this.package, this.onBuyNow});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PackageDetailContent(package: package),
          const SpaceHeight.h24(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBuyNow,
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('Beli Paket Ini'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageDetailContent extends StatelessWidget {
  final PackageModel package;

  const _PackageDetailContent({required this.package});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(package.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        if (package.description != null) ...[
          const SizedBox(height: 8),
          Text(package.description!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 16),

        // Price Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga Paket', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text(package.displayPrice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              if (package.originalPrice > package.packagePrice) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Harga Normal', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      'Rp ${package.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
              ],
              if (package.formattedSavings != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('Hemat ${package.formattedSavings}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Cards
        Row(
          children: [
            Expanded(
              child: _InfoCard(icon: Icons.event_repeat, label: 'Total Sesi', value: '${package.totalSessions} sesi'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(icon: Icons.access_time, label: 'Berlaku', value: package.validityDisplay),
            ),
          ],
        ),
        if (package.formattedPricePerSession != null) ...[
          const SizedBox(height: 12),
          _InfoCard(icon: Icons.price_check, label: 'Harga per Sesi', value: package.formattedPricePerSession!),
        ],

        // Service info
        if (package.service != null) ...[
          const SizedBox(height: 16),
          const Text('Layanan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.spa, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(package.service!.name, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
