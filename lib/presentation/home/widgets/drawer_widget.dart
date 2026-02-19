import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/responses/user_model.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/bloc/logout/logout_event.dart';
import '../../auth/bloc/logout/logout_state.dart';
import '../../auth/pages/login_page.dart';

class DrawerWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DrawerWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
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
      child: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // User Header
              _buildUserHeader(),
              const Divider(height: 1),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard,
                      label: 'Dashboard',
                      isSelected: widget.selectedIndex == 0,
                      onTap: () => _selectItem(0),
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_month_outlined,
                      selectedIcon: Icons.calendar_month,
                      label: 'Appointment',
                      isSelected: widget.selectedIndex == 1,
                      onTap: () => _selectItem(1),
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline,
                      selectedIcon: Icons.people,
                      label: 'Pelanggan',
                      isSelected: widget.selectedIndex == 2,
                      onTap: () => _selectItem(2),
                    ),
                    _DrawerItem(
                      icon: Icons.spa_outlined,
                      selectedIcon: Icons.spa,
                      label: 'Layanan',
                      isSelected: widget.selectedIndex == 3,
                      onTap: () => _selectItem(3),
                    ),
                    _DrawerItem(
                      icon: Icons.card_giftcard_outlined,
                      selectedIcon: Icons.card_giftcard,
                      label: 'Paket',
                      isSelected: widget.selectedIndex == 4,
                      onTap: () => _selectItem(4),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(),
                    ),
                    _DrawerItem(
                      icon: Icons.point_of_sale_outlined,
                      selectedIcon: Icons.point_of_sale,
                      label: 'Checkout',
                      isSelected: widget.selectedIndex == 5,
                      onTap: () => _selectItem(5),
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_outlined,
                      selectedIcon: Icons.receipt_long,
                      label: 'Transaksi',
                      isSelected: widget.selectedIndex == 6,
                      onTap: () => _selectItem(6),
                    ),
                    _DrawerItem(
                      icon: Icons.bar_chart_outlined,
                      selectedIcon: Icons.bar_chart,
                      label: 'Laporan',
                      isSelected: widget.selectedIndex == 7,
                      onTap: () => _selectItem(7),
                    ),
                  ],
                ),
              ),

              // Settings & Logout
              const Divider(height: 1),
              _DrawerItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Pengaturan',
                isSelected: widget.selectedIndex == 8,
                onTap: () => _selectItem(8),
              ),
              Builder(
                builder: (context) {
                  return _DrawerItem(
                    icon: Icons.logout,
                    selectedIcon: Icons.logout,
                    label: 'Keluar',
                    isSelected: false,
                    color: AppColors.error,
                    onTap: () => _showLogoutDialog(context),
                  );
                },
              ),
              const SpaceHeight.h8(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: _user?.avatar != null
                ? ClipOval(
                    child: Image.network(
                      _user!.avatar!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitials(),
                    ),
                  )
                : _buildInitials(),
          ),
          const SpaceWidth.w12(),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SpaceHeight.h4(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _user?.roleDisplayName ?? 'Staff',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Text(
      _user?.name.initials ?? 'U',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  void _selectItem(int index) {
    widget.onItemSelected(index);
    Navigator.pop(context);
  }

  void _showLogoutDialog(BuildContext context) {
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? (isSelected ? AppColors.primary : AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: itemColor,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: itemColor,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
      ),
    );
  }
}
