import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/responses/user_model.dart';
import '../../appointment/pages/appointment_calendar_page.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/bloc/logout/logout_event.dart';
import '../../auth/bloc/logout/logout_state.dart';
import '../../auth/pages/login_page.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../service/pages/service_list_page.dart';
import '../../checkout/pages/checkout_page.dart';
import '../../transaction/pages/transaction_page.dart';
import '../../package/pages/package_page.dart';
import '../../package/pages/customer_package_page.dart';
import '../../report/pages/report_page.dart';
import '../../settings/pages/settings_page.dart';
import '../../product/pages/product_page.dart';
import '../../treatment/pages/treatment_page.dart';
import '../../staff/pages/staff_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthLocalDatasource().getUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      phone: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildMobileAppBar(),
        body: _buildMobileBody(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _user?.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Badge(
            smallSize: 8,
            backgroundColor: Colors.amber,
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _user?.name.isNotEmpty == true
                  ? _user!.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.name ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _user?.email ?? '',
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
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Pengaturan'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text('Keluar', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog();
            } else if (value == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(onNavigate: (index) => setState(() => _selectedIndex = index));
      case 1:
        return const AppointmentCalendarPage();
      case 2:
        return const CustomerListPage();
      case 3:
        return const ServiceListPage();
      case 4:
        return _buildMorePage();
      default:
        return DashboardPage(onNavigate: (index) => setState(() => _selectedIndex = index));
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Beranda',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today,
                label: 'Jadwal',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                label: 'Pelanggan',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.spa_outlined,
                selectedIcon: Icons.spa,
                label: 'Layanan',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view,
                label: 'Lainnya',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Lainnya',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildMenuSection(
            title: 'Transaksi',
            items: [
              _MenuItem(
                icon: Icons.point_of_sale,
                label: 'Checkout',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.receipt_long,
                label: 'Riwayat Transaksi',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.card_giftcard,
                label: 'Paket',
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PackagePage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.card_membership,
                label: 'Paket Pelanggan',
                color: AppColors.statusInProgress,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerPackagePage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildMenuSection(
            title: 'Fitur Pelanggan',
            items: [
              _MenuItem(
                icon: Icons.medical_services_outlined,
                label: 'Treatment',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TreatmentPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.badge_outlined,
                label: 'Staff',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StaffPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'Produk',
                color: AppColors.statusInProgress,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.loyalty_outlined,
                label: 'Loyalty',
                color: AppColors.warning,
                onTap: () {
                  setState(() => _selectedIndex = 2); // Navigate to Pelanggan tab
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih pelanggan untuk melihat loyalty'),
                    ),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.share_outlined,
                label: 'Referral',
                color: AppColors.success,
                onTap: () {
                  setState(() => _selectedIndex = 2); // Navigate to Pelanggan tab
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih pelanggan untuk melihat referral'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildMenuSection(
            title: 'Laporan',
            items: [
              _MenuItem(
                icon: Icons.bar_chart,
                label: 'Laporan Penjualan',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.analytics_outlined,
                label: 'Analitik',
                color: AppColors.statusInProgress,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildMenuSection(
            title: 'Pengaturan',
            items: [
              _MenuItem(
                icon: Icons.settings,
                label: 'Pengaturan Aplikasi',
                color: AppColors.textSecondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.help_outline,
                label: 'Bantuan',
                color: AppColors.info,
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
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
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    title: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 68),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, color: AppColors.info, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Bantuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpItem(Icons.phone, 'Hubungi Kami', '021-1234567'),
            const SizedBox(height: 12),
            _helpItem(Icons.email, 'Email', 'support@glowup.com'),
            const SizedBox(height: 12),
            _helpItem(Icons.chat, 'WhatsApp', '+62 812-3456-7890'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'GlowUp Clinic App v1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // ==================== TABLET LAYOUT ====================
  Widget _buildTabletLayout() {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            // Side Navigation for Tablet
            _buildSideNav(),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  _buildTabletAppBar(),
                  Expanded(child: _buildTabletBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            _getTabletTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Badge(
              smallSize: 8,
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Pengaturan'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text('Keluar', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _user?.name.isNotEmpty == true
                        ? _user!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _user?.roleDisplayName ?? 'Staff',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.spa, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GlowUp',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildSideNavItem(
                  Icons.home_outlined,
                  Icons.home,
                  'Beranda',
                  0,
                ),
                _buildSideNavItem(
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Jadwal',
                  1,
                ),
                _buildSideNavItem(
                  Icons.people_outline,
                  Icons.people,
                  'Pelanggan',
                  2,
                ),
                _buildSideNavItem(Icons.spa_outlined, Icons.spa, 'Layanan', 3),
                _buildSideNavItem(
                  Icons.inventory_2_outlined,
                  Icons.inventory_2,
                  'Produk',
                  4,
                ),
                _buildSideNavItem(
                  Icons.card_giftcard_outlined,
                  Icons.card_giftcard,
                  'Paket',
                  5,
                ),
                _buildSideNavItem(
                  Icons.medical_services_outlined,
                  Icons.medical_services,
                  'Treatment',
                  6,
                ),
                _buildSideNavItem(
                  Icons.badge_outlined,
                  Icons.badge,
                  'Staff',
                  7,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _buildSideNavItem(
                  Icons.point_of_sale_outlined,
                  Icons.point_of_sale,
                  'Checkout',
                  8,
                ),
                _buildSideNavItem(
                  Icons.receipt_long_outlined,
                  Icons.receipt_long,
                  'Transaksi',
                  9,
                ),
                _buildSideNavItem(
                  Icons.bar_chart_outlined,
                  Icons.bar_chart,
                  'Laporan',
                  10,
                ),
                _buildSideNavItem(
                  Icons.card_membership_outlined,
                  Icons.card_membership,
                  'Paket Pelanggan',
                  11,
                ),
              ],
            ),
          ),

          // Settings
          const Divider(height: 1),
          _buildSideNavItem(
            Icons.settings_outlined,
            Icons.settings,
            'Pengaturan',
            12,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: () => setState(() => _selectedIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabletBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(onNavigate: (index) => setState(() => _selectedIndex = index));
      case 1:
        return const AppointmentCalendarPage();
      case 2:
        return const CustomerListPage();
      case 3:
        return const ServiceListPage();
      case 4:
        return const ProductPage();
      case 5:
        return PackagePage(onNavigate: (index) => setState(() => _selectedIndex = index));
      case 6:
        return const TreatmentPage();
      case 7:
        return const StaffPage();
      case 8:
        return const CheckoutPage();
      case 9:
        return const TransactionPage();
      case 10:
        return const ReportPage();
      case 11:
        return const CustomerPackagePage();
      case 12:
        return const SettingsPage();
      default:
        return DashboardPage(onNavigate: (index) => setState(() => _selectedIndex = index));
    }
  }

  // ==================== HELPERS ====================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  String _getTabletTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Beranda';
      case 1:
        return 'Jadwal Appointment';
      case 2:
        return 'Daftar Pelanggan';
      case 3:
        return 'Daftar Layanan';
      case 4:
        return 'Produk';
      case 5:
        return 'Paket';
      case 6:
        return 'Treatment Records';
      case 7:
        return 'Daftar Staff';
      case 8:
        return 'Checkout';
      case 9:
        return 'Riwayat Transaksi';
      case 10:
        return 'Laporan';
      case 11:
        return 'Paket Pelanggan';
      case 12:
        return 'Pengaturan';
      default:
        return 'GlowUp Clinic';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LogoutBloc>().add(LogoutSubmitted());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
