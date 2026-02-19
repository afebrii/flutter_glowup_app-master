import 'package:intl/intl.dart';

extension IntExt on int {
  /// Format angka ke format currency Indonesia
  /// Example: 50000.currencyFormat => "Rp 50.000"
  String get currencyFormat {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }

  /// Format currency tanpa symbol
  /// Example: 50000.currencyFormatNoSymbol => "50.000"
  String get currencyFormatNoSymbol {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(this);
  }

  /// Format compact untuk angka besar
  /// Example: 1500000.compactCurrency => "Rp 1.5jt"
  String get compactCurrency {
    if (this >= 1000000000) {
      return 'Rp ${(this / 1000000000).toStringAsFixed(1)}M';
    } else if (this >= 1000000) {
      return 'Rp ${(this / 1000000).toStringAsFixed(1)}jt';
    } else if (this >= 1000) {
      return 'Rp ${(this / 1000).toStringAsFixed(0)}rb';
    }
    return currencyFormat;
  }

  /// Format dengan separator ribuan
  /// Example: 1500000.formatted => "1.500.000"
  String get formatted {
    return NumberFormat('#,###', 'id_ID').format(this);
  }

  /// Konversi menit ke format jam:menit
  /// Example: 90.toHourMinute => "1j 30m"
  String get toHourMinute {
    if (this < 60) return '${this}m';
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (minutes == 0) return '${hours}j';
    return '${hours}j ${minutes}m';
  }
}
