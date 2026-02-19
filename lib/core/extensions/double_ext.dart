import 'package:intl/intl.dart';

extension DoubleExt on double {
  /// Format angka ke format currency Indonesia
  String get currencyFormat {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(this);
  }

  /// Format currency dengan decimal
  String get currencyFormatWithDecimal {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(this);
  }

  /// Format persentase
  /// Example: 0.85.toPercent => "85%"
  String get toPercent {
    return '${(this * 100).toStringAsFixed(0)}%';
  }

  /// Format persentase dengan decimal
  /// Example: 0.856.toPercentDecimal => "85.6%"
  String get toPercentDecimal {
    return '${(this * 100).toStringAsFixed(1)}%';
  }
}
