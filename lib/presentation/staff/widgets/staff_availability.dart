import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class StaffAvailabilityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> availability;
  final String? selectedSlot;
  final Function(String)? onSlotSelected;
  final bool isLoading;

  const StaffAvailabilityWidget({
    super.key,
    required this.availability,
    this.selectedSlot,
    this.onSlotSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (availability.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tidak ada slot tersedia',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availability.map((slot) {
        final time = slot['time'] as String;
        final isAvailable = slot['available'] as bool? ?? true;
        final isSelected = selectedSlot == time;

        return _TimeSlotChip(
          time: time,
          isAvailable: isAvailable,
          isSelected: isSelected,
          onTap: isAvailable ? () => onSlotSelected?.call(time) : null,
        );
      }).toList(),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotChip({
    required this.time,
    this.isAvailable = true,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) return AppColors.primary;
    if (!isAvailable) return AppColors.borderLight;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isSelected) return AppColors.primary;
    if (!isAvailable) return AppColors.border;
    return AppColors.border;
  }

  Color _getTextColor() {
    if (isSelected) return Colors.white;
    if (!isAvailable) return AppColors.textMuted;
    return AppColors.textPrimary;
  }
}

/// Card version showing staff availability summary
class StaffAvailabilitySummary extends StatelessWidget {
  final String staffName;
  final int availableSlots;
  final int totalSlots;
  final VoidCallback? onTap;

  const StaffAvailabilitySummary({
    super.key,
    required this.staffName,
    required this.availableSlots,
    required this.totalSlots,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Percentage could be used for accessibility or debugging
    // final percentage = totalSlots > 0 ? (availableSlots / totalSlots * 100).round() : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staffName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalSlots > 0 ? availableSlots / totalSlots : 0,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$availableSlots/$totalSlots',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (availableSlots == 0) return AppColors.error;
    if (availableSlots < totalSlots * 0.3) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (availableSlots == 0) return Icons.event_busy;
    if (availableSlots < totalSlots * 0.3) return Icons.event;
    return Icons.event_available;
  }
}
