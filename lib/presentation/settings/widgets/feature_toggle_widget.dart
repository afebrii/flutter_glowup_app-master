import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class FeatureToggleWidget extends StatelessWidget {
  final Map<String, bool> features;
  final bool isEditable;
  final Function(String, bool)? onToggle;

  const FeatureToggleWidget({
    super.key,
    required this.features,
    this.isEditable = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.entries.map((entry) {
        final featureInfo = _getFeatureInfo(entry.key);
        return FeatureToggleItem(
          feature: entry.key,
          label: featureInfo.label,
          description: featureInfo.description,
          icon: featureInfo.icon,
          isEnabled: entry.value,
          isEditable: isEditable,
          onToggle: (enabled) => onToggle?.call(entry.key, enabled),
        );
      }).toList(),
    );
  }

  ({String label, String description, IconData icon}) _getFeatureInfo(
      String feature) {
    switch (feature) {
      case 'products':
        return (
          label: 'Produk',
          description: 'Kelola dan jual produk kecantikan',
          icon: Icons.inventory_2_outlined,
        );
      case 'treatment_records':
        return (
          label: 'Rekam Medis',
          description: 'Catatan perawatan pelanggan',
          icon: Icons.medical_information_outlined,
        );
      case 'packages':
        return (
          label: 'Paket Layanan',
          description: 'Bundle layanan dengan harga khusus',
          icon: Icons.card_giftcard_outlined,
        );
      case 'loyalty':
        return (
          label: 'Loyalty Program',
          description: 'Sistem poin dan reward pelanggan',
          icon: Icons.stars_outlined,
        );
      case 'online_booking':
        return (
          label: 'Online Booking',
          description: 'Pelanggan booking via website/app',
          icon: Icons.calendar_today_outlined,
        );
      case 'referral':
        return (
          label: 'Referral Program',
          description: 'Program ajak teman',
          icon: Icons.people_outline,
        );
      default:
        return (
          label: feature,
          description: 'Feature $feature',
          icon: Icons.extension_outlined,
        );
    }
  }
}

class FeatureToggleItem extends StatelessWidget {
  final String feature;
  final String label;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final bool isEditable;
  final Function(bool)? onToggle;

  const FeatureToggleItem({
    super.key,
    required this.feature,
    required this.label,
    required this.description,
    required this.icon,
    required this.isEnabled,
    this.isEditable = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.background : AppColors.borderLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isEnabled ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primary,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEnabled ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? AppColors.success : AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact grid version
class FeatureToggleGrid extends StatelessWidget {
  final Map<String, bool> features;
  final int crossAxisCount;

  const FeatureToggleGrid({
    super.key,
    required this.features,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final entries = features.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final info = _getFeatureInfo(entry.key);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: entry.value
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: entry.value
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                info.icon,
                color: entry.value ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: entry.value
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
              Icon(
                entry.value ? Icons.check_circle : Icons.cancel,
                color: entry.value ? AppColors.success : AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  ({String label, IconData icon}) _getFeatureInfo(String feature) {
    switch (feature) {
      case 'products':
        return (label: 'Produk', icon: Icons.inventory_2_outlined);
      case 'treatment_records':
        return (label: 'Rekam Medis', icon: Icons.medical_information_outlined);
      case 'packages':
        return (label: 'Paket', icon: Icons.card_giftcard_outlined);
      case 'loyalty':
        return (label: 'Loyalty', icon: Icons.stars_outlined);
      case 'online_booking':
        return (label: 'Online Booking', icon: Icons.calendar_today_outlined);
      case 'referral':
        return (label: 'Referral', icon: Icons.people_outline);
      default:
        return (label: feature, icon: Icons.extension_outlined);
    }
  }
}
