import 'dart:async';


import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola koneksi printer Bluetooth dan mencetak struk
class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  // Connection state
  final _connectionStateController =
      StreamController<PrinterConnectionState>.broadcast();
  Stream<PrinterConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  PrinterConnectionState _connectionState = PrinterConnectionState.disconnected;
  PrinterConnectionState get connectionState => _connectionState;

  BluetoothInfo? _connectedDevice;
  BluetoothInfo? get connectedDevice => _connectedDevice;

  bool get isConnected => _connectionState == PrinterConnectionState.connected;

  // SharedPreferences keys
  static const String _keyPrinterName = 'printer_name';
  static const String _keyPrinterMac = 'printer_mac';
  static const String _keyPaperSize = 'receipt_paper_size';
  static const String _keyShowAddress = 'receipt_show_address';
  static const String _keyShowPhone = 'receipt_show_phone';
  static const String _keyShowCashier = 'receipt_show_cashier';
  static const String _keyShowDateTime = 'receipt_show_datetime';
  static const String _keyShowThankYou = 'receipt_show_thankyou';
  static const String _keyClinicName = 'receipt_clinic_name';
  static const String _keyClinicAddress = 'receipt_clinic_address';
  static const String _keyClinicPhone = 'receipt_clinic_phone';
  static const String _keyFooterMessage = 'receipt_footer';

  // ─── Initialization ───────────────────────────────────────────────

  /// Inisialisasi service dan auto-connect ke printer yang tersimpan
  Future<void> initialize() async {
    final saved = await getSavedPrinter();
    if (saved != null) {
      await connect(saved);
    }
  }

  // ─── Device Discovery ─────────────────────────────────────────────

  /// Mendapatkan daftar perangkat Bluetooth yang sudah di-pair
  Future<List<BluetoothInfo>> getPairedDevices() async {
    _updateState(PrinterConnectionState.scanning);
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;
      _updateState(
        _connectedDevice != null
            ? PrinterConnectionState.connected
            : PrinterConnectionState.disconnected,
      );
      return devices;
    } catch (e) {
      _updateState(PrinterConnectionState.error);
      return [];
    }
  }

  // ─── Connection Management ────────────────────────────────────────

  /// Koneksikan ke printer Bluetooth
  Future<bool> connect(BluetoothInfo device) async {
    _updateState(PrinterConnectionState.connecting);
    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );
      if (result) {
        _connectedDevice = device;
        _updateState(PrinterConnectionState.connected);
        await savePrinter(device);
        return true;
      } else {
        _updateState(PrinterConnectionState.disconnected);
        return false;
      }
    } catch (e) {
      _updateState(PrinterConnectionState.error);
      return false;
    }
  }

  /// Putuskan koneksi printer
  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
    _connectedDevice = null;
    _updateState(PrinterConnectionState.disconnected);
  }

  /// Cek status koneksi printer
  Future<bool> checkConnection() async {
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;
      if (connected) {
        _updateState(PrinterConnectionState.connected);
      } else {
        _connectedDevice = null;
        _updateState(PrinterConnectionState.disconnected);
      }
      return connected;
    } catch (e) {
      _updateState(PrinterConnectionState.error);
      return false;
    }
  }

  // ─── Printer Persistence ──────────────────────────────────────────

  /// Simpan info printer ke SharedPreferences
  Future<void> savePrinter(BluetoothInfo device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterName, device.name);
    await prefs.setString(_keyPrinterMac, device.macAdress);
  }

  /// Ambil printer yang tersimpan
  Future<BluetoothInfo?> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyPrinterName);
    final mac = prefs.getString(_keyPrinterMac);
    if (name != null && mac != null) {
      return BluetoothInfo(name: name, macAdress: mac);
    }
    return null;
  }

  /// Hapus printer yang tersimpan
  Future<void> removeSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrinterName);
    await prefs.remove(_keyPrinterMac);
    _connectedDevice = null;
    _updateState(PrinterConnectionState.disconnected);
  }

  // ─── Receipt Settings ─────────────────────────────────────────────

  /// Simpan pengaturan struk
  Future<void> saveReceiptSettings({
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? footerMessage,
    String? paperSize,
    bool? showAddress,
    bool? showPhone,
    bool? showCashier,
    bool? showDateTime,
    bool? showThankYou,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (clinicName != null) await prefs.setString(_keyClinicName, clinicName);
    if (clinicAddress != null) {
      await prefs.setString(_keyClinicAddress, clinicAddress);
    }
    if (clinicPhone != null) {
      await prefs.setString(_keyClinicPhone, clinicPhone);
    }
    if (footerMessage != null) {
      await prefs.setString(_keyFooterMessage, footerMessage);
    }
    if (paperSize != null) await prefs.setString(_keyPaperSize, paperSize);
    if (showAddress != null) await prefs.setBool(_keyShowAddress, showAddress);
    if (showPhone != null) await prefs.setBool(_keyShowPhone, showPhone);
    if (showCashier != null) await prefs.setBool(_keyShowCashier, showCashier);
    if (showDateTime != null) {
      await prefs.setBool(_keyShowDateTime, showDateTime);
    }
    if (showThankYou != null) {
      await prefs.setBool(_keyShowThankYou, showThankYou);
    }
  }

  /// Ambil pengaturan struk
  Future<ReceiptSettings> getReceiptSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ReceiptSettings(
      clinicName: prefs.getString(_keyClinicName) ?? 'GlowUp Clinic',
      clinicAddress: prefs.getString(_keyClinicAddress) ?? '',
      clinicPhone: prefs.getString(_keyClinicPhone) ?? '',
      footerMessage: prefs.getString(_keyFooterMessage) ??
          'Terima kasih atas kunjungan Anda',
      paperSize: prefs.getString(_keyPaperSize) ?? '80mm',
      showAddress: prefs.getBool(_keyShowAddress) ?? true,
      showPhone: prefs.getBool(_keyShowPhone) ?? true,
      showCashier: prefs.getBool(_keyShowCashier) ?? true,
      showDateTime: prefs.getBool(_keyShowDateTime) ?? true,
      showThankYou: prefs.getBool(_keyShowThankYou) ?? true,
    );
  }

  // ─── Print Receipt ────────────────────────────────────────────────

  /// Cetak struk transaksi
  ///
  /// Gunakan method ini setelah checkout/transaksi selesai.
  /// [items] berisi daftar item (service, product, package).
  /// [payments] berisi daftar metode pembayaran yang digunakan.
  Future<bool> printReceipt({
    required String invoiceNumber,
    required DateTime transactionDate,
    required List<PrintReceiptItem> items,
    required double subtotal,
    double discountAmount = 0,
    String? discountLabel,
    int? pointsUsed,
    double pointsDiscount = 0,
    double taxAmount = 0,
    required double totalAmount,
    required List<PrintPaymentInfo> payments,
    double changeAmount = 0,
    String? cashierName,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final connected = await checkConnection();
    if (!connected) return false;

    try {
      final settings = await getReceiptSettings();
      final paperSize =
          settings.paperSize == '80mm' ? PaperSize.mm80 : PaperSize.mm58;
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      // ═══════════════════════════════════════════
      //              HEADER - CLINIC INFO
      // ═══════════════════════════════════════════
      bytes += generator.text(
        settings.clinicName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      if (settings.showAddress && settings.clinicAddress.isNotEmpty) {
        bytes += generator.text(
          settings.clinicAddress,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      if (settings.showPhone && settings.clinicPhone.isNotEmpty) {
        bytes += generator.text(
          'Telp: ${settings.clinicPhone}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.hr();

      // ═══════════════════════════════════════════
      //           TRANSACTION INFO
      // ═══════════════════════════════════════════
      if (settings.showDateTime) {
        final dateStr = DateFormat('dd/MM/yyyy').format(transactionDate);
        final timeStr = DateFormat('HH:mm').format(transactionDate);
        bytes += generator.row([
          PosColumn(text: dateStr, width: 6),
          PosColumn(
            text: timeStr,
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.text('No: $invoiceNumber');

      if (settings.showCashier && cashierName != null) {
        bytes += generator.text('Kasir: $cashierName');
      }

      if (customerName != null) {
        bytes += generator.text('Pelanggan: $customerName');
      }

      if (customerPhone != null) {
        bytes += generator.text('Telp: $customerPhone');
      }

      bytes += generator.hr();

      // ═══════════════════════════════════════════
      //              ITEMS
      // ═══════════════════════════════════════════
      for (final item in items) {
        // Nama item + tipe (Service/Product/Package)
        final typeLabel = _getItemTypeLabel(item.itemType);
        bytes += generator.text(
          '${item.name} [$typeLabel]',
          styles: const PosStyles(bold: true),
        );

        // Qty x harga          subtotal
        bytes += generator.row([
          PosColumn(
            text: '  ${item.qty}x ${_formatCurrency(item.unitPrice)}',
            width: 8,
          ),
          PosColumn(
            text: _formatCurrency(item.subtotal),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);

        // Beautician/staff jika ada
        if (item.staffName != null) {
          bytes += generator.text(
            '  Staff: ${item.staffName}',
            styles: const PosStyles(
              align: PosAlign.left,
            ),
          );
        }
      }

      bytes += generator.hr();

      // ═══════════════════════════════════════════
      //              SUMMARY
      // ═══════════════════════════════════════════
      // Subtotal
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 7),
        PosColumn(
          text: _formatCurrency(subtotal),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Diskon
      if (discountAmount > 0) {
        bytes += generator.row([
          PosColumn(
            text: discountLabel ?? 'Diskon',
            width: 7,
          ),
          PosColumn(
            text: '-${_formatCurrency(discountAmount)}',
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // Poin loyalitas
      if (pointsUsed != null && pointsUsed > 0) {
        bytes += generator.row([
          PosColumn(text: 'Poin ($pointsUsed pts)', width: 7),
          PosColumn(
            text: '-${_formatCurrency(pointsDiscount)}',
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // Pajak
      if (taxAmount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Pajak', width: 7),
          PosColumn(
            text: _formatCurrency(taxAmount),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr(ch: '=');

      // TOTAL
      bytes += generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 7,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: _formatCurrency(totalAmount),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]);

      bytes += generator.hr(ch: '=');

      // ═══════════════════════════════════════════
      //              PAYMENT INFO
      // ═══════════════════════════════════════════
      for (final payment in payments) {
        bytes += generator.row([
          PosColumn(
            text: _getPaymentMethodLabel(payment.method),
            width: 7,
          ),
          PosColumn(
            text: _formatCurrency(payment.amount),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);

        // Referensi pembayaran (e.g. no kartu, ref transfer)
        if (payment.referenceNumber != null) {
          bytes += generator.text(
            '  Ref: ${payment.referenceNumber}',
          );
        }
      }

      // Kembalian
      if (changeAmount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Kembali', width: 7),
          PosColumn(
            text: _formatCurrency(changeAmount),
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      // ═══════════════════════════════════════════
      //              NOTES
      // ═══════════════════════════════════════════
      if (notes != null && notes.isNotEmpty) {
        bytes += generator.hr();
        bytes += generator.text('Catatan: $notes');
      }

      // ═══════════════════════════════════════════
      //              FOOTER
      // ═══════════════════════════════════════════
      bytes += generator.hr();

      if (settings.showThankYou) {
        bytes += generator.text(
          settings.footerMessage,
          styles: const PosStyles(align: PosAlign.center),
        );
        bytes += generator.text(
          'www.glowupclinic.com',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.feed(3);
      bytes += generator.cut();

      // Kirim ke printer
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      return false;
    }
  }

  // ─── Test Print ───────────────────────────────────────────────────

  /// Cetak halaman test untuk mengecek koneksi printer
  Future<bool> printTestPage() async {
    final connected = await checkConnection();
    if (!connected) return false;

    try {
      final settings = await getReceiptSettings();
      final paperSize =
          settings.paperSize == '80mm' ? PaperSize.mm80 : PaperSize.mm58;
      final profile = await CapabilityProfile.load();
      final generator = Generator(paperSize, profile);
      List<int> bytes = [];

      bytes += generator.text(
        settings.clinicName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.hr();
      bytes += generator.text(
        'TEST PRINT',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      );
      bytes += generator.text(
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();
      bytes += generator.text(
        'Printer terhubung dengan baik!',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Paper: ${settings.paperSize}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();
      bytes += generator.feed(3);
      bytes += generator.cut();

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      return result;
    } catch (e) {
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  void _updateState(PrinterConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String _getItemTypeLabel(String itemType) {
    switch (itemType) {
      case 'service':
        return 'Layanan';
      case 'product':
        return 'Produk';
      case 'package':
        return 'Paket';
      default:
        return itemType;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'debit_card':
        return 'Kartu Debit';
      case 'credit_card':
        return 'Kartu Kredit';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'ovo':
        return 'OVO';
      case 'gopay':
        return 'GoPay';
      case 'dana':
        return 'DANA';
      case 'qris':
        return 'QRIS';
      default:
        return method;
    }
  }

  /// Dispose stream controller
  void dispose() {
    _connectionStateController.close();
  }
}

// ─── Enums & Models ─────────────────────────────────────────────────

/// Status koneksi printer
enum PrinterConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Pengaturan struk
class ReceiptSettings {
  final String clinicName;
  final String clinicAddress;
  final String clinicPhone;
  final String footerMessage;
  final String paperSize;
  final bool showAddress;
  final bool showPhone;
  final bool showCashier;
  final bool showDateTime;
  final bool showThankYou;

  const ReceiptSettings({
    required this.clinicName,
    required this.clinicAddress,
    required this.clinicPhone,
    required this.footerMessage,
    required this.paperSize,
    required this.showAddress,
    required this.showPhone,
    required this.showCashier,
    required this.showDateTime,
    required this.showThankYou,
  });
}

/// Item yang akan dicetak di struk
class PrintReceiptItem {
  final String name;
  final String itemType; // 'service', 'product', 'package'
  final int qty;
  final double unitPrice;
  final double subtotal;
  final String? staffName; // beautician/terapis

  const PrintReceiptItem({
    required this.name,
    required this.itemType,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
    this.staffName,
  });
}

/// Info pembayaran untuk struk
class PrintPaymentInfo {
  final String method; // 'cash', 'debit_card', 'credit_card', 'bank_transfer', 'qris', dll
  final double amount;
  final String? referenceNumber;

  const PrintPaymentInfo({
    required this.method,
    required this.amount,
    this.referenceNumber,
  });
}
