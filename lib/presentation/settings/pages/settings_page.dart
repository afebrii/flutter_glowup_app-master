import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/staff_remote_datasource.dart';
import '../../auth/pages/login_page.dart';
import '../../../injection.dart';
import '../../staff/bloc/staff_bloc.dart';
import '../../../data/models/responses/settings_model.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const FetchSettings());
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _SettingsPhoneLayout(),
      tablet: _SettingsTabletLayout(),
    );
  }
}

// Tablet Layout
class _SettingsTabletLayout extends StatefulWidget {
  const _SettingsTabletLayout();

  @override
  State<_SettingsTabletLayout> createState() => _SettingsTabletLayoutState();
}

class _SettingsTabletLayoutState extends State<_SettingsTabletLayout> {
  String _selectedSection = 'profil';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - Settings Menu (35%)
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                        const SpaceWidth.w12(),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengaturan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Kelola aplikasi Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _SettingsMenuItem(
                          icon: Icons.person_outline,
                          label: 'Profil Klinik',
                          description: 'Informasi dan branding',
                          isSelected: _selectedSection == 'profil',
                          onTap: () => setState(() => _selectedSection = 'profil'),
                        ),
                        _SettingsMenuItem(
                          icon: Icons.schedule_outlined,
                          label: 'Jam Operasional',
                          description: 'Jadwal buka klinik',
                          isSelected: _selectedSection == 'jadwal',
                          onTap: () => setState(() => _selectedSection = 'jadwal'),
                        ),
                        _SettingsMenuItem(
                          icon: Icons.people_outline,
                          label: 'Manajemen Staff',
                          description: 'Akun dan hak akses',
                          isSelected: _selectedSection == 'staff',
                          onTap: () => setState(() => _selectedSection = 'staff'),
                        ),
                        _SettingsMenuItem(
                          icon: Icons.payment_outlined,
                          label: 'Metode Pembayaran',
                          description: 'Opsi pembayaran',
                          isSelected: _selectedSection == 'pembayaran',
                          onTap: () => setState(() => _selectedSection = 'pembayaran'),
                        ),
                        _SettingsMenuItem(
                          icon: Icons.print_outlined,
                          label: 'Printer & Struk',
                          description: 'Pengaturan cetak',
                          isSelected: _selectedSection == 'printer',
                          onTap: () => setState(() => _selectedSection = 'printer'),
                        ),
                        const Divider(height: 24),
                        _SettingsMenuItem(
                          icon: Icons.help_outline,
                          label: 'Bantuan',
                          description: 'FAQ dan dukungan',
                          isSelected: _selectedSection == 'bantuan',
                          onTap: () => setState(() => _selectedSection = 'bantuan'),
                        ),
                        _SettingsMenuItem(
                          icon: Icons.info_outline,
                          label: 'Tentang Aplikasi',
                          description: 'Versi dan lisensi',
                          isSelected: _selectedSection == 'tentang',
                          onTap: () => setState(() => _selectedSection = 'tentang'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SpaceWidth.w20(),

          // Right Panel - Settings Content (65%)
          Expanded(
            flex: 65,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: _buildSettingsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    switch (_selectedSection) {
      case 'profil':
        return _ProfileSettings();
      case 'jadwal':
        return _ScheduleSettings();
      case 'staff':
        return _StaffSettings();
      case 'pembayaran':
        return _PaymentSettings();
      case 'printer':
        return _PrinterSettings();
      case 'bantuan':
        return _HelpSettings();
      case 'tentang':
        return _AboutSettings();
      default:
        return _ProfileSettings();
    }
  }
}

// Phone Layout - Full Implementation
class _SettingsPhoneLayout extends StatefulWidget {
  const _SettingsPhoneLayout();

  @override
  State<_SettingsPhoneLayout> createState() => _SettingsPhoneLayoutState();
}

class _SettingsPhoneLayoutState extends State<_SettingsPhoneLayout> {
  String? _connectedPrinterName;

  @override
  void initState() {
    super.initState();
    _loadPrinterStatus();
  }

  Future<void> _loadPrinterStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _connectedPrinterName = prefs.getString('connected_printer_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final clinic = state.settings?.clinic;
        final clinicName = clinic?.name ?? 'Klinik';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Pengaturan'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.spa, size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinicName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.settings?.businessType == 'salon' ? 'Salon' : 'Klinik Kecantikan',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings Groups
                const Text(
                  'Pengaturan Umum',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _PhoneSettingsGroup(
                  items: [
                    _PhoneSettingsItem(
                      icon: Icons.person_outline,
                      label: 'Profil Klinik',
                      subtitle: 'Informasi dan branding',
                      onTap: () => _showSettingsDetail(context, 'Profil Klinik', _ProfileSettings()),
                    ),
                    _PhoneSettingsItem(
                      icon: Icons.schedule_outlined,
                      label: 'Jam Operasional',
                      subtitle: 'Jadwal buka klinik',
                      onTap: () => _showSettingsDetail(context, 'Jam Operasional', _ScheduleSettings()),
                    ),
                    _PhoneSettingsItem(
                      icon: Icons.people_outline,
                      label: 'Manajemen Staff',
                      subtitle: 'Kelola akun staff',
                      onTap: () => _showSettingsDetail(context, 'Manajemen Staff', _StaffSettings()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Pembayaran & Transaksi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _PhoneSettingsGroup(
                  items: [
                    _PhoneSettingsItem(
                      icon: Icons.payment_outlined,
                      label: 'Metode Pembayaran',
                      subtitle: 'Pengaturan pembayaran',
                      onTap: () => _showSettingsDetail(context, 'Metode Pembayaran', _PaymentSettings()),
                    ),
                    _PhoneSettingsItem(
                      icon: Icons.print_outlined,
                      label: 'Printer & Struk',
                      subtitle: _connectedPrinterName ?? 'Belum terhubung',
                      onTap: () => _showSettingsDetail(context, 'Printer & Struk', _PrinterSettings()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Lainnya',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _PhoneSettingsGroup(
                  items: [
                    _PhoneSettingsItem(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      subtitle: 'Versi dan informasi',
                      onTap: () => _showSettingsDetail(context, 'Tentang Aplikasi', _AboutSettings()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                    label: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDetail(BuildContext context, String title, Widget content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: content,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthLocalDatasource().clearAll();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _PhoneSettingsGroup extends StatelessWidget {
  final List<_PhoneSettingsItem> items;

  const _PhoneSettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: index == items.length - 1 ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (item.subtitle != null)
                              Text(
                                item.subtitle!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 60),
            ],
          );
        }),
        ),
      ),
    );
  }
}

class _PhoneSettingsItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _PhoneSettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}

// Helper Widgets
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: isSelected ? 1.5 : 0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Settings Content Widgets
class _ProfileSettings extends StatefulWidget {
  @override
  State<_ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<_ProfileSettings> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _initControllers(ClinicInfo? clinic) {
    if (_initialized || clinic == null) return;
    _initialized = true;
    _nameCtrl.text = clinic.name ?? '';
    _addressCtrl.text = clinic.address ?? '';
    _phoneCtrl.text = clinic.phone ?? '';
    _whatsappCtrl.text = clinic.whatsapp ?? '';
    _emailCtrl.text = clinic.email ?? '';
  }

  void _resetControllers(ClinicInfo? clinic) {
    _nameCtrl.text = clinic?.name ?? '';
    _addressCtrl.text = clinic?.address ?? '';
    _phoneCtrl.text = clinic?.phone ?? '';
    _whatsappCtrl.text = clinic?.whatsapp ?? '';
    _emailCtrl.text = clinic?.email ?? '';
  }

  void _saveClinicInfo() {
    context.read<SettingsBloc>().add(UpdateClinicInfo({
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'whatsapp': _whatsappCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<SettingsBloc>().add(const ClearSettingsError());
        }
        if (state.error != null && state.isSaving == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<SettingsBloc>().add(const ClearSettingsError());
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.settings == null) {
          return const Center(child: CircularProgressIndicator());
        }

        _initControllers(state.settings?.clinic);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil Klinik',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SpaceHeight.h8(),
              const Text(
                'Informasi dasar dan branding klinik Anda',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SpaceHeight.h24(),

              // Logo Section
              _SettingsSection(
                title: 'Logo Klinik',
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.spa, size: 40, color: AppColors.primary),
                    ),
                    const SpaceWidth.w16(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload, size: 16),
                          label: const Text('Upload Logo'),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Format: PNG, JPG (Max 2MB)',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SpaceHeight.h20(),

              // Basic Info
              _SettingsSection(
                title: 'Informasi Dasar',
                child: Column(
                  children: [
                    _SettingsTextField(label: 'Nama Klinik', value: '', controller: _nameCtrl),
                    const SpaceHeight.h12(),
                    _SettingsTextField(label: 'Alamat', value: '', controller: _addressCtrl),
                    const SpaceHeight.h12(),
                    Row(
                      children: [
                        Expanded(child: _SettingsTextField(label: 'Telepon', value: '', controller: _phoneCtrl)),
                        const SpaceWidth.w12(),
                        Expanded(child: _SettingsTextField(label: 'WhatsApp', value: '', controller: _whatsappCtrl)),
                      ],
                    ),
                    const SpaceHeight.h12(),
                    _SettingsTextField(label: 'Email', value: '', controller: _emailCtrl),
                  ],
                ),
              ),
              const SpaceHeight.h20(),

              // Feature flags
              if (state.settings != null) ...[
                _SettingsSection(
                  title: 'Fitur Aktif',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.settings!.features.entries.map((entry) {
                      return Chip(
                        avatar: Icon(
                          entry.value ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: entry.value ? AppColors.success : AppColors.textMuted,
                        ),
                        label: Text(
                          _featureLabel(entry.key),
                          style: TextStyle(
                            fontSize: 12,
                            color: entry.value ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        backgroundColor: entry.value
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.background,
                      );
                    }).toList(),
                  ),
                ),
                const SpaceHeight.h20(),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _resetControllers(state.settings?.clinic),
                    child: const Text('Batal'),
                  ),
                  const SpaceWidth.w12(),
                  ElevatedButton(
                    onPressed: state.isSaving ? null : _saveClinicInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _featureLabel(String key) {
    final labels = {
      'products': 'Produk',
      'treatment_records': 'Treatment Records',
      'packages': 'Paket',
      'customer_packages': 'Paket Pelanggan',
      'loyalty': 'Loyalty',
      'online_booking': 'Booking Online',
      'customer_portal': 'Portal Pelanggan',
      'walk_in_queue': 'Antrian Walk-in',
    };
    return labels[key] ?? key.replaceAll('_', ' ');
  }
}

class _ScheduleSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<SettingsBloc>().add(const ClearSettingsError());
        }
        if (state.error != null && !state.isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<SettingsBloc>().add(const ClearSettingsError());
        }
      },
      builder: (context, state) {
        final hours = state.operatingHours;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jam Operasional',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SpaceHeight.h8(),
              const Text(
                'Atur jadwal buka klinik Anda',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SpaceHeight.h24(),

              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (hours.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 40, color: AppColors.warning),
                      const SpaceHeight.h12(),
                      const Text(
                        'Data jam operasional kosong',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SpaceHeight.h4(),
                      const Text(
                        'API tidak mengembalikan data operating_hours.\nPastikan endpoint GET /settings sudah return data.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SpaceHeight.h12(),
                      OutlinedButton.icon(
                        onPressed: () => context.read<SettingsBloc>().add(const FetchSettings()),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              else
                ...hours.map((hour) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          child: Text(
                            hour.dayNameId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: !hour.isClosed,
                          onChanged: (value) {},
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    hour.isClosed ? '-' : _formatTime(hour.openTime),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: hour.isClosed ? AppColors.textMuted : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('-'),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    hour.isClosed ? '-' : _formatTime(hour.closeTime),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: hour.isClosed ? AppColors.textMuted : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SpaceHeight.h12(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () {
                            final hoursData = hours
                                .map((h) => h.toJson())
                                .toList();
                            context.read<SettingsBloc>().add(
                              UpdateOperatingHours(hoursData),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan Jadwal'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }
}

class _StaffSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffBloc(
        staffDatasource: getIt<StaffRemoteDatasource>(),
      )..add(const FetchStaff(activeOnly: false)),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen Staff',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SpaceHeight.h4(),
                          Text(
                            'Kelola akun dan hak akses staff',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Staff'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SpaceHeight.h24(),

                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state.error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(state.error!, style: const TextStyle(color: AppColors.error)),
                        const SpaceHeight.h12(),
                        ElevatedButton(
                          onPressed: () => context.read<StaffBloc>().add(const FetchStaff(activeOnly: false)),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                else if (state.staff.isEmpty)
                  const Center(child: Text('Belum ada data staff'))
                else
                  ...state.staff.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            s.name.isNotEmpty ? s.name[0] : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.email.isNotEmpty ? s.email : '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      s.role.isNotEmpty ? s.role : 'Staff',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.info,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: s.isActive
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      s.isActive ? 'Aktif' : 'Nonaktif',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: s.isActive ? AppColors.success : AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (value) {
                            // TODO: handle edit/delete
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Text('Hapus', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),
          const Text(
            'Atur opsi pembayaran yang tersedia',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SpaceHeight.h24(),

          _PaymentMethodTile(
            icon: Icons.payments,
            label: 'Cash',
            description: 'Pembayaran tunai',
            isEnabled: true,
          ),
          _PaymentMethodTile(
            icon: Icons.credit_card,
            label: 'Kartu Debit/Kredit',
            description: 'EDC BCA, Mandiri, BNI',
            isEnabled: true,
          ),
          _PaymentMethodTile(
            icon: Icons.qr_code,
            label: 'QRIS',
            description: 'Scan QR untuk bayar',
            isEnabled: true,
          ),
          _PaymentMethodTile(
            icon: Icons.account_balance,
            label: 'Transfer Bank',
            description: 'BCA 1234567890',
            isEnabled: true,
          ),
          _PaymentMethodTile(
            icon: Icons.wallet,
            label: 'E-Wallet',
            description: 'GoPay, OVO, DANA',
            isEnabled: false,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isEnabled;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {},
            activeColor: AppColors.primary,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 18),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _PrinterSettings extends StatefulWidget {
  @override
  State<_PrinterSettings> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<_PrinterSettings> {
  final _printerService = PrinterService();
  List<BluetoothInfo> _devices = [];
  ReceiptSettings? _receiptSettings;
  bool _isScanning = false;
  bool _isPrinting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _printerService.checkConnection();
  }

  Future<void> _loadSettings() async {
    final settings = await _printerService.getReceiptSettings();
    if (mounted) setState(() => _receiptSettings = settings);
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });
    try {
      // Request Bluetooth permissions directly
      final permissionsGranted = await _requestBluetoothPermissions();
      if (!permissionsGranted) {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
        return;
      }

      final devices = await _printerService.getPairedDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = false;
          if (devices.isEmpty) {
            _errorMessage = 'Tidak ada perangkat Bluetooth ditemukan. '
                'Pastikan printer sudah di-pair di pengaturan Bluetooth.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = 'Gagal scan: $e';
        });
      }
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    // Check current permission status
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final locationWhenInUse = await Permission.locationWhenInUse.status;

    // If all permissions are granted, return true
    if (bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        locationWhenInUse.isGranted) {
      return true;
    }

    // Request permissions
    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final scanGranted = results[Permission.bluetoothScan]?.isGranted ?? false;
    final connectGranted = results[Permission.bluetoothConnect]?.isGranted ?? false;
    final locationGranted = results[Permission.locationWhenInUse]?.isGranted ?? false;

    if (!scanGranted || !connectGranted || !locationGranted) {
      // Check if any permission is permanently denied
      final isPermanentlyDenied =
          results[Permission.bluetoothScan]?.isPermanentlyDenied == true ||
          results[Permission.bluetoothConnect]?.isPermanentlyDenied == true ||
          results[Permission.locationWhenInUse]?.isPermanentlyDenied == true;

      if (isPermanentlyDenied && mounted) {
        // Show dialog to open settings
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Izin Bluetooth diperlukan untuk mencari printer. '
              'Silakan aktifkan izin di Pengaturan aplikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Izin Bluetooth ditolak. Silakan coba lagi.';
        });
      }
      return false;
    }

    return true;
  }

  Future<void> _connectDevice(BluetoothInfo device) async {
    setState(() => _errorMessage = null);
    final success = await _printerService.connect(device);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terhubung ke ${device.name}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() => _errorMessage = 'Gagal terhubung ke ${device.name}');
      }
      setState(() {});
    }
  }

  Future<void> _disconnectDevice() async {
    await _printerService.disconnect();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer terputus')),
      );
    }
  }

  Future<void> _removeSavedPrinter() async {
    await _printerService.removeSavedPrinter();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer dihapus')),
      );
    }
  }

  Future<void> _testPrint() async {
    setState(() => _isPrinting = true);
    final success = await _printerService.printTestPage();
    if (mounted) {
      setState(() => _isPrinting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test print berhasil!' : 'Test print gagal. Cek koneksi printer.'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateReceiptSetting({
    bool? showAddress,
    bool? showPhone,
    bool? showCashier,
    bool? showDateTime,
    bool? showThankYou,
    String? paperSize,
  }) async {
    await _printerService.saveReceiptSettings(
      showAddress: showAddress,
      showPhone: showPhone,
      showCashier: showCashier,
      showDateTime: showDateTime,
      showThankYou: showThankYou,
      paperSize: paperSize,
    );
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Printer & Struk',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),
          const Text(
            'Pengaturan printer dan format struk',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SpaceHeight.h24(),

          // ─── Connection Status ─────────────────────────────
          _SettingsSection(
            title: 'Printer Tersambung',
            child: StreamBuilder<PrinterConnectionState>(
              stream: _printerService.connectionStateStream,
              initialData: _printerService.connectionState,
              builder: (context, snapshot) {
                final state = snapshot.data ?? PrinterConnectionState.disconnected;
                final device = _printerService.connectedDevice;
                final isConnected = state == PrinterConnectionState.connected;
                final isConnecting = state == PrinterConnectionState.connecting;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppColors.success.withValues(alpha: 0.1)
                        : isConnecting
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isConnected
                          ? AppColors.success.withValues(alpha: 0.3)
                          : isConnecting
                              ? AppColors.warning.withValues(alpha: 0.3)
                              : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isConnected
                            ? Icons.print
                            : isConnecting
                                ? Icons.bluetooth_searching
                                : Icons.print_disabled,
                        color: isConnected
                            ? AppColors.success
                            : isConnecting
                                ? AppColors.warning
                                : AppColors.textMuted,
                      ),
                      const SpaceWidth.w12(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isConnected
                                  ? device?.name ?? 'Printer'
                                  : isConnecting
                                      ? 'Menghubungkan...'
                                      : 'Belum terhubung',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              isConnected
                                  ? 'Bluetooth - Tersambung'
                                  : isConnecting
                                      ? 'Mohon tunggu...'
                                      : 'Tap "Cari Printer" untuk menghubungkan',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (isConnected) ...[
                        OutlinedButton(
                          onPressed: _isPrinting ? null : _testPrint,
                          child: _isPrinting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Test Print'),
                        ),
                        const SpaceWidth.w8(),
                        IconButton(
                          onPressed: _disconnectDevice,
                          icon: const Icon(Icons.link_off, size: 20),
                          tooltip: 'Putuskan',
                          color: AppColors.error,
                        ),
                      ],
                      if (isConnecting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SpaceHeight.h20(),

          // ─── Scan & Device List ────────────────────────────
          _SettingsSection(
            title: 'Perangkat Bluetooth',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isScanning ? null : _scanDevices,
                      icon: _isScanning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bluetooth_searching, size: 18),
                      label: Text(_isScanning ? 'Mencari...' : 'Cari Printer'),
                    ),
                    if (_printerService.connectedDevice != null) ...[
                      const SpaceWidth.w12(),
                      TextButton.icon(
                        onPressed: _removeSavedPrinter,
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        label: const Text('Hapus Printer', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SpaceHeight.h12(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SpaceWidth.w8(),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_devices.isNotEmpty) ...[
                  const SpaceHeight.h12(),
                  ...List.generate(_devices.length, (index) {
                    final device = _devices[index];
                    final isCurrentDevice = _printerService.connectedDevice?.macAdress == device.macAdress;
                    final isConnected = isCurrentDevice && _printerService.isConnected;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppColors.success.withValues(alpha: 0.05)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isConnected
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bluetooth,
                            size: 20,
                            color: isConnected ? AppColors.success : AppColors.textSecondary,
                          ),
                          const SpaceWidth.w12(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isConnected ? AppColors.success : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  device.macAdress,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Tersambung',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => _connectDevice(device),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('Hubungkan', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SpaceHeight.h20(),

          // ─── Paper Size ────────────────────────────────────
          if (_receiptSettings != null) ...[
            _SettingsSection(
              title: 'Ukuran Kertas',
              child: Row(
                children: [
                  _PaperSizeOption(
                    label: '58mm',
                    isSelected: _receiptSettings!.paperSize == '58mm',
                    onTap: () => _updateReceiptSetting(paperSize: '58mm'),
                  ),
                  const SpaceWidth.w12(),
                  _PaperSizeOption(
                    label: '80mm',
                    isSelected: _receiptSettings!.paperSize == '80mm',
                    onTap: () => _updateReceiptSetting(paperSize: '80mm'),
                  ),
                ],
              ),
            ),
            const SpaceHeight.h20(),

            // ─── Receipt Format ──────────────────────────────
            _SettingsSection(
              title: 'Format Struk',
              child: Column(
                children: [
                  _ReceiptToggle(
                    label: 'Tampilkan Alamat',
                    value: _receiptSettings!.showAddress,
                    onChanged: (v) => _updateReceiptSetting(showAddress: v),
                  ),
                  _ReceiptToggle(
                    label: 'Tampilkan No. Telepon',
                    value: _receiptSettings!.showPhone,
                    onChanged: (v) => _updateReceiptSetting(showPhone: v),
                  ),
                  _ReceiptToggle(
                    label: 'Tampilkan Kasir',
                    value: _receiptSettings!.showCashier,
                    onChanged: (v) => _updateReceiptSetting(showCashier: v),
                  ),
                  _ReceiptToggle(
                    label: 'Tampilkan Tanggal & Waktu',
                    value: _receiptSettings!.showDateTime,
                    onChanged: (v) => _updateReceiptSetting(showDateTime: v),
                  ),
                  _ReceiptToggle(
                    label: 'Tampilkan Terima Kasih',
                    value: _receiptSettings!.showThankYou,
                    onChanged: (v) => _updateReceiptSetting(showThankYou: v),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaperSizeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaperSizeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SpaceWidth.w8(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReceiptToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}


class _HelpSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bantuan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),
          const Text(
            'FAQ dan dukungan pelanggan',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SpaceHeight.h24(),

          _HelpItem(
            icon: Icons.menu_book,
            label: 'Panduan Pengguna',
            description: 'Pelajari cara menggunakan aplikasi',
          ),
          _HelpItem(
            icon: Icons.help_outline,
            label: 'FAQ',
            description: 'Pertanyaan yang sering diajukan',
          ),
          _HelpItem(
            icon: Icons.video_library,
            label: 'Video Tutorial',
            description: 'Tutorial video lengkap',
          ),
          _HelpItem(
            icon: Icons.chat_outlined,
            label: 'Hubungi Support',
            description: 'Chat dengan tim support kami',
          ),
          _HelpItem(
            icon: Icons.email_outlined,
            label: 'Email',
            description: 'support@glowupapp.com',
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _AboutSettings extends StatefulWidget {
  @override
  State<_AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends State<_AboutSettings> {
  String _appVersion = '-';
  String _buildNumber = '-';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    // Get version from pubspec.yaml (configured in app)
    // Using hardcoded for now, should use package_info_plus in production
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appVersion = prefs.getString('app_version') ?? '1.0.0';
      _buildNumber = prefs.getString('app_build_number') ?? '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final clinicName = state.settings?.clinic.name ?? 'GlowUp Clinic';
        final clinicWebsite = state.settings?.clinic.website ?? '-';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SpaceHeight.h24(),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.spa, color: Colors.white, size: 40),
                    ),
                    const SpaceHeight.h16(),
                    Text(
                      clinicName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SpaceHeight.h4(),
                    Text(
                      'Versi $_appVersion',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SpaceHeight.h32(),

              _AboutItem(label: 'Versi Aplikasi', value: _appVersion),
              _AboutItem(label: 'Build Number', value: _buildNumber),
              _AboutItem(label: 'Website', value: clinicWebsite),
              const SpaceHeight.h20(),

              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Kebijakan Privasi'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Syarat & Ketentuan'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lisensi Open Source'),
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
}

class _AboutItem extends StatelessWidget {
  final String label;
  final String value;

  const _AboutItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Common Widgets
class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SpaceHeight.h12(),
        child,
      ],
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController? controller;

  const _SettingsTextField({
    required this.label,
    required this.value,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller ?? TextEditingController(text: value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
