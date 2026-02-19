import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../data/models/responses/customer_model.dart';
import 'customer_card.dart';

class CustomerDetailPanel extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBookAppointment;
  final void Function(int points, String description)? onAdjustPoints;

  const CustomerDetailPanel({
    super.key,
    required this.customer,
    this.onEdit,
    this.onDelete,
    this.onBookAppointment,
    this.onAdjustPoints,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar and Actions
          _buildHeader(),
          const SpaceHeight.h24(),

          // Loyalty & Referral Section
          _buildLoyaltyReferralCard(context),
          const SpaceHeight.h16(),

          // Stats Card
          CustomerStatsCard(customer: customer),
          const SpaceHeight.h24(),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: Button.filled(
                  onPressed: onBookAppointment ?? () {},
                  label: 'Booking',
                  icon: Icons.calendar_today,
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Button.outlined(
                  onPressed: onEdit,
                  label: 'Edit',
                  icon: Icons.edit,
                ),
              ),
            ],
          ),
          const SpaceHeight.h24(),

          // Info Sections
          _buildInfoSection('Informasi Kontak', [
            _InfoRow(icon: Icons.phone_outlined, label: 'Telepon', value: customer.phone),
            if (customer.email != null)
              _InfoRow(icon: Icons.email_outlined, label: 'Email', value: customer.email!),
            if (customer.address != null)
              _InfoRow(icon: Icons.location_on_outlined, label: 'Alamat', value: customer.address!),
          ]),
          const SpaceHeight.h20(),

          _buildInfoSection('Informasi Pribadi', [
            _InfoRow(
              icon: Icons.cake_outlined,
              label: 'Tanggal Lahir',
              value: customer.birthdate?.toFormattedDate ?? '-',
            ),
            if (customer.age != null)
              _InfoRow(icon: Icons.person_outline, label: 'Usia', value: '${customer.age} tahun'),
            _InfoRow(icon: Icons.wc_outlined, label: 'Jenis Kelamin', value: customer.genderLabel),
          ]),
          const SpaceHeight.h20(),

          _buildInfoSection('Profil Kulit', [
            _InfoRow(icon: Icons.face_outlined, label: 'Tipe Kulit', value: customer.skinTypeLabel),
            if (customer.skinConcerns != null && customer.skinConcerns!.isNotEmpty)
              _InfoRow(
                icon: Icons.healing_outlined,
                label: 'Masalah Kulit',
                value: customer.skinConcerns!.map((c) => _getSkinConcernLabel(c)).join(', '),
              ),
            if (customer.allergies != null)
              _InfoRow(
                icon: Icons.warning_amber_outlined,
                label: 'Alergi',
                value: customer.allergies!,
                valueColor: AppColors.error,
              ),
          ]),

          if (customer.notes != null && customer.notes!.isNotEmpty) ...[
            const SpaceHeight.h20(),
            _buildInfoSection('Catatan', [
              _InfoRow(icon: Icons.note_outlined, label: '', value: customer.notes!),
            ]),
          ],

          const SpaceHeight.h24(),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                const SpaceWidth.w12(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zona Berbahaya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      const SpaceHeight.h4(),
                      const Text(
                        'Menghapus pelanggan tidak dapat dibatalkan',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            customer.initials,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SpaceWidth.w16(),
        // Name and Member Since
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (customer.loyaltyTier != null) ...[
                    const SpaceWidth.w8(),
                    _LoyaltyTierBadge(tier: customer.loyaltyTier!),
                  ],
                ],
              ),
              const SpaceHeight.h4(),
              Text(
                'Member sejak ${customer.createdAt.toFormattedDate}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<_InfoRow> rows) {
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
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: row,
              )),
        ],
      ),
    );
  }

  Widget _buildLoyaltyReferralCard(BuildContext context) {
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
          // Loyalty Points Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars, color: AppColors.warning, size: 20),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loyalty Points',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${customer.loyaltyPoints.formatted} pts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Lifetime',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    '${customer.lifetimePoints.formatted} pts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Adjust Points Button
          if (onAdjustPoints != null) ...[
            const SpaceHeight.h12(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAdjustPointsDialog(context),
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Sesuaikan Poin'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(
                      color: AppColors.warning.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],

          // Referral Code Section
          if (customer.hasReferralCode) ...[
            const SpaceHeight.h16(),
            const Divider(height: 1),
            const SpaceHeight.h16(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.share, color: AppColors.success, size: 20),
                ),
                const SpaceWidth.w12(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kode Referral',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        customer.referralCode!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.copy, size: 18, color: AppColors.textMuted),
                  tooltip: 'Salin kode',
                ),
              ],
            ),
            if (customer.referralStats != null) ...[
              const SpaceHeight.h12(),
              Row(
                children: [
                  _MiniStat(
                    label: 'Total Referral',
                    value: '${customer.referralStats!.totalReferrals}',
                  ),
                  const SpaceWidth.w16(),
                  _MiniStat(
                    label: 'Poin Didapat',
                    value: customer.referralStats!.totalPointsEarned.formatted,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showAdjustPointsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AdjustPointsDialog(
        onConfirm: (points, description) {
          onAdjustPoints?.call(points, description);
        },
      ),
    );
  }

  String _getSkinConcernLabel(String concern) {
    final labels = {
      'acne': 'Jerawat',
      'dark_spots': 'Flek Hitam',
      'wrinkles': 'Kerutan',
      'large_pores': 'Pori Besar',
      'dullness': 'Kusam',
      'fine_lines': 'Garis Halus',
      'redness': 'Kemerahan',
      'dryness': 'Kering',
      'blackheads': 'Komedo',
      'sagging': 'Kendur',
      'aging': 'Penuaan',
    };
    return labels[concern] ?? concern;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
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
        if (label.isNotEmpty) ...[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
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

class _LoyaltyTierBadge extends StatelessWidget {
  final String tier;

  const _LoyaltyTierBadge({required this.tier});

  Color get _color {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const Color(0xFF6366F1);
      case 'gold':
        return const Color(0xFFD97706);
      case 'silver':
        return const Color(0xFF6B7280);
      case 'bronze':
        return const Color(0xFFB45309);
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _bgColor {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const Color(0xFFEEF2FF);
      case 'gold':
        return const Color(0xFFFEF3C7);
      case 'silver':
        return const Color(0xFFF3F4F6);
      case 'bronze':
        return const Color(0xFFFEF3C7);
      default:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            tier[0].toUpperCase() + tier.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AdjustPointsDialog extends StatefulWidget {
  final void Function(int points, String description) onConfirm;

  const _AdjustPointsDialog({required this.onConfirm});

  @override
  State<_AdjustPointsDialog> createState() => _AdjustPointsDialogState();
}

class _AdjustPointsDialogState extends State<_AdjustPointsDialog> {
  bool _isAdd = true;
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sesuaikan Poin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add/Subtract Radio
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  value: true,
                  groupValue: _isAdd,
                  onChanged: (v) => setState(() => _isAdd = v!),
                  title: const Text('Tambah', style: TextStyle(fontSize: 14)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.success,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  value: false,
                  groupValue: _isAdd,
                  onChanged: (v) => setState(() => _isAdd = v!),
                  title: const Text('Kurangi', style: TextStyle(fontSize: 14)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.error,
                ),
              ),
            ],
          ),
          const SpaceHeight.h12(),

          // Points Input
          TextField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Poin',
              hintText: 'Masukkan jumlah poin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(
                _isAdd ? Icons.add : Icons.remove,
                color: _isAdd ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SpaceHeight.h12(),

          // Description Input
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Deskripsi / Alasan',
              hintText: 'Masukkan alasan penyesuaian',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final pointsText = _pointsController.text.trim();
            final description = _descriptionController.text.trim();
            if (pointsText.isEmpty || description.isEmpty) return;

            final points = int.tryParse(pointsText);
            if (points == null || points <= 0) return;

            final adjustedPoints = _isAdd ? points : -points;
            widget.onConfirm(adjustedPoints, description);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
