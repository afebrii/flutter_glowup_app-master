import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  /// Format: "28 Jan 2025"
  String get toFormattedDate {
    return DateFormat('dd MMM yyyy', 'id_ID').format(this);
  }

  /// Format: "28 Januari 2025"
  String get toFullDate {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(this);
  }

  /// Format: "Selasa, 28 Jan 2025"
  String get toFormattedDateWithDay {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(this);
  }

  /// Format: "14:30"
  String get toFormattedTime {
    return DateFormat('HH:mm').format(this);
  }

  /// Format: "28 Jan 2025, 14:30"
  String get toFormattedDateTime {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(this);
  }

  /// Format API: "2025-01-28"
  String get toApiFormat {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format API dengan waktu: "2025-01-28 14:30:00"
  String get toApiFormatWithTime {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  /// Get nama hari
  /// Example: "Selasa"
  String get dayName {
    return DateFormat('EEEE', 'id_ID').format(this);
  }

  /// Get nama hari pendek
  /// Example: "Sel"
  String get dayNameShort {
    return DateFormat('EEE', 'id_ID').format(this);
  }

  /// Get nama bulan
  /// Example: "Januari"
  String get monthName {
    return DateFormat('MMMM', 'id_ID').format(this);
  }

  /// Get nama bulan pendek
  /// Example: "Jan"
  String get monthNameShort {
    return DateFormat('MMM', 'id_ID').format(this);
  }

  /// Check apakah hari ini
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check apakah kemarin
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check apakah besok
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check apakah di minggu ini
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get relative time (waktu relatif)
  /// Example: "2 jam lalu", "3 hari lalu", "kemarin"
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} hari lalu';
    } else if (isYesterday) {
      return 'Kemarin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  /// Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }

  /// Check apakah tanggal sama (ignore time)
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
