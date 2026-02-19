import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/appointment_model.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<TimeSlot> slots;
  final String? selectedTime;
  final Function(String) onTimeSelected;
  final bool isLoading;
  final String? openTime;
  final String? closeTime;

  const TimeSlotPicker({
    super.key,
    required this.slots,
    this.selectedTime,
    required this.onTimeSelected,
    this.isLoading = false,
    this.openTime,
    this.closeTime,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tidak ada slot tersedia',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get time boundaries from operating hours or use defaults
    final openHour = _parseHour(openTime) ?? 9;
    final closeHour = _parseHour(closeTime) ?? 18;

    // Calculate dynamic time sections based on operating hours
    final totalHours = closeHour - openHour;
    final sectionHours = (totalHours / 3).ceil();

    final morningEnd = openHour + sectionHours;
    final afternoonEnd = morningEnd + sectionHours;

    // Group slots dynamically
    final morningSlots = slots.where((s) {
      final hour = int.parse(s.time.split(':')[0]);
      return hour >= openHour && hour < morningEnd;
    }).toList();

    final afternoonSlots = slots.where((s) {
      final hour = int.parse(s.time.split(':')[0]);
      return hour >= morningEnd && hour < afternoonEnd;
    }).toList();

    final eveningSlots = slots.where((s) {
      final hour = int.parse(s.time.split(':')[0]);
      return hour >= afternoonEnd && hour < closeHour;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morningSlots.isNotEmpty)
          _buildTimeSection(
            'Pagi (${_formatHour(openHour)} - ${_formatHour(morningEnd)})',
            morningSlots,
          ),
        if (afternoonSlots.isNotEmpty)
          _buildTimeSection(
            'Siang (${_formatHour(morningEnd)} - ${_formatHour(afternoonEnd)})',
            afternoonSlots,
          ),
        if (eveningSlots.isNotEmpty)
          _buildTimeSection(
            'Sore (${_formatHour(afternoonEnd)} - ${_formatHour(closeHour)})',
            eveningSlots,
          ),
      ],
    );
  }

  int? _parseHour(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.isEmpty) return null;
    return int.tryParse(parts[0]);
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Widget _buildTimeSection(String title, List<TimeSlot> sectionSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sectionSlots.map((slot) {
            final isSelected = selectedTime == slot.time;
            return TimeSlotChip(
              time: slot.time,
              isAvailable: slot.isAvailable,
              isSelected: isSelected,
              onTap: slot.isAvailable ? () => onTimeSelected(slot.time) : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class TimeSlotChip extends StatelessWidget {
  final String time;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    this.isAvailable = true,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!isAvailable) {
      return AppColors.border.withValues(alpha: 0.5);
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (!isAvailable) {
      return AppColors.border;
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return AppColors.border;
  }

  Color _getTextColor() {
    if (!isAvailable) {
      return AppColors.textMuted;
    }
    if (isSelected) {
      return Colors.white;
    }
    return AppColors.textPrimary;
  }
}

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlot> slots;
  final String? selectedTime;
  final Function(String) onTimeSelected;
  final int crossAxisCount;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedTime,
    required this.onTimeSelected,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = selectedTime == slot.time;
        return TimeSlotChip(
          time: slot.time,
          isAvailable: slot.isAvailable,
          isSelected: isSelected,
          onTap: slot.isAvailable ? () => onTimeSelected(slot.time) : null,
        );
      },
    );
  }
}
