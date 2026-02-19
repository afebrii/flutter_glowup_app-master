import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/settings_model.dart';

class OperatingHoursWidget extends StatelessWidget {
  final List<OperatingHourModel> hours;
  final bool isEditable;
  final Function(OperatingHourModel)? onHourChanged;

  const OperatingHoursWidget({
    super.key,
    required this.hours,
    this.isEditable = false,
    this.onHourChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by day_of_week
    final sortedHours = List<OperatingHourModel>.from(hours)
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedHours.map((hour) {
        return OperatingHourItem(
          hour: hour,
          isEditable: isEditable,
          onChanged: onHourChanged,
        );
      }).toList(),
    );
  }
}

class OperatingHourItem extends StatelessWidget {
  final OperatingHourModel hour;
  final bool isEditable;
  final Function(OperatingHourModel)? onChanged;

  const OperatingHourItem({
    super.key,
    required this.hour,
    this.isEditable = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hour.isClosed
            ? AppColors.borderLight
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              hour.dayNameId,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hour.isClosed
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (isEditable) ...[
            Switch(
              value: !hour.isClosed,
              onChanged: (value) {
                if (onChanged != null) {
                  onChanged!(OperatingHourModel(
                    id: hour.id,
                    dayOfWeek: hour.dayOfWeek,
                    dayName: hour.dayName,
                    dayNameId: hour.dayNameId,
                    openTime: hour.openTime,
                    closeTime: hour.closeTime,
                    isClosed: !value,
                  ));
                }
              },
              activeThumbColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: hour.isClosed
                ? Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          value: hour.openTime,
                          isEditable: isEditable,
                          onChanged: (time) {
                            if (onChanged != null) {
                              onChanged!(OperatingHourModel(
                                id: hour.id,
                                dayOfWeek: hour.dayOfWeek,
                                dayName: hour.dayName,
                                dayNameId: hour.dayNameId,
                                openTime: time,
                                closeTime: hour.closeTime,
                                isClosed: hour.isClosed,
                              ));
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      Expanded(
                        child: _TimeField(
                          value: hour.closeTime,
                          isEditable: isEditable,
                          onChanged: (time) {
                            if (onChanged != null) {
                              onChanged!(OperatingHourModel(
                                id: hour.id,
                                dayOfWeek: hour.dayOfWeek,
                                dayName: hour.dayName,
                                dayNameId: hour.dayNameId,
                                openTime: hour.openTime,
                                closeTime: time,
                                isClosed: hour.isClosed,
                              ));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          if (_isToday(hour.dayOfWeek))
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Hari ini',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isToday(int dayOfWeek) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    return DateTime.now().weekday == dayOfWeek;
  }
}

class _TimeField extends StatelessWidget {
  final String? value;
  final bool isEditable;
  final Function(String)? onChanged;

  const _TimeField({
    this.value,
    this.isEditable = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditable
          ? () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _parseTime(value),
              );
              if (time != null) {
                final formattedTime =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                onChanged?.call(formattedTime);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          _formatDisplay(value),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            color: value != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  String _formatDisplay(String? time) {
    if (time == null) return '-';
    // Strip seconds: "09:00:00" -> "09:00"
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  TimeOfDay _parseTime(String? time) {
    if (time == null) return const TimeOfDay(hour: 9, minute: 0);
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}

/// Compact display for clinic hours
class OperatingHoursCompact extends StatelessWidget {
  final List<OperatingHourModel> hours;
  final VoidCallback? onTap;

  const OperatingHoursCompact({
    super.key,
    required this.hours,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;
    final today = hours.where((h) => h.dayOfWeek == todayWeekday).firstOrNull;

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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (today != null)
                    Text(
                      today.isClosed
                          ? 'Hari ini: Tutup'
                          : 'Hari ini: ${today.openTime} - ${today.closeTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: today.isClosed
                            ? AppColors.error
                            : AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
