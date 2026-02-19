import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import '../../../data/models/responses/transaction_model.dart';
import '../../../injection.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionBloc(
        datasource: getIt<TransactionRemoteDatasource>(),
      )..add(const FetchTransactions()),
      child: const ResponsiveWidget(
        phone: _TransactionPhoneLayout(),
        tablet: _TransactionTabletLayout(),
      ),
    );
  }
}

// Tablet Layout
class _TransactionTabletLayout extends StatefulWidget {
  const _TransactionTabletLayout();

  @override
  State<_TransactionTabletLayout> createState() => _TransactionTabletLayoutState();
}

class _TransactionTabletLayoutState extends State<_TransactionTabletLayout> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  TransactionModel? _selectedTransaction;
  DateTimeRange? _dateRange;

  void _fetchFiltered() {
    context.read<TransactionBloc>().add(FetchTransactions(
      status: _selectedFilter == 'all' ? null : _selectedFilter,
      dateFrom: _dateRange?.start,
      dateTo: _dateRange?.end,
    ));
  }

  List<TransactionModel> _applyLocalSearch(List<TransactionModel> transactions) {
    if (_searchQuery.isEmpty) return transactions;
    return transactions.where((t) =>
      (t.customer?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
          context.read<TransactionBloc>().add(const ClearTransactionError());
        }
      },
      builder: (context, state) {
        final filteredTransactions = _applyLocalSearch(state.transactions);
        final totalRevenue = filteredTransactions
            .where((t) => t.status == 'paid')
            .fold(0.0, (sum, t) => sum + t.totalAmount);

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel - Transaction List (45%)
              Expanded(
                flex: 45,
                child: Column(
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Transaksi',
                            value: '${filteredTransactions.length}',
                            icon: Icons.receipt_long,
                            iconColor: AppColors.info,
                          ),
                        ),
                        const SpaceWidth.w12(),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Pendapatan',
                            value: totalRevenue.toInt().compactCurrency,
                            icon: Icons.payments,
                            iconColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SpaceHeight.h16(),

                    // Search & Filter
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SearchInput(
                                  hint: 'Cari transaksi...',
                                  onChanged: (value) {
                                    setState(() => _searchQuery = value);
                                  },
                                ),
                              ),
                              const SpaceWidth.w12(),
                              GestureDetector(
                                onTap: _selectDateRange,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                                      if (_dateRange != null) ...[
                                        const SpaceWidth.w8(),
                                        Text(
                                          '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SpaceHeight.h12(),
                          Row(
                            children: [
                              _FilterChip(
                                label: 'Semua',
                                isSelected: _selectedFilter == 'all',
                                onTap: () {
                                  setState(() => _selectedFilter = 'all');
                                  _fetchFiltered();
                                },
                              ),
                              const SpaceWidth.w8(),
                              _FilterChip(
                                label: 'Selesai',
                                isSelected: _selectedFilter == 'paid',
                                onTap: () {
                                  setState(() => _selectedFilter = 'paid');
                                  _fetchFiltered();
                                },
                                color: AppColors.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight.h16(),

                    // Transaction List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredTransactions.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt_long, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                        const SpaceHeight.h12(),
                                        const Text('Tidak ada transaksi', style: TextStyle(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: filteredTransactions.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final transaction = filteredTransactions[index];
                                      return _TransactionListItem(
                                        transaction: transaction,
                                        isSelected: _selectedTransaction?.id == transaction.id,
                                        onTap: () => setState(() => _selectedTransaction = transaction),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceWidth.w20(),

              // Right Panel - Transaction Detail (55%)
              Expanded(
                flex: 55,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: _selectedTransaction != null
                      ? _TransactionDetailPanel(transaction: _selectedTransaction!)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.receipt, size: 48, color: AppColors.textMuted),
                              ),
                              const SpaceHeight.h20(),
                              const Text('Pilih Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SpaceHeight.h8(),
                              const Text('Klik transaksi dari daftar untuk melihat detail', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _fetchFiltered();
    }
  }
}

// Phone Layout
class _TransactionPhoneLayout extends StatefulWidget {
  const _TransactionPhoneLayout();

  @override
  State<_TransactionPhoneLayout> createState() => _TransactionPhoneLayoutState();
}

class _TransactionPhoneLayoutState extends State<_TransactionPhoneLayout> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  void _fetchFiltered() {
    context.read<TransactionBloc>().add(FetchTransactions(
      status: _selectedFilter == 'all' ? null : _selectedFilter,
      dateFrom: _dateRange?.start,
      dateTo: _dateRange?.end,
    ));
  }

  List<TransactionModel> _applyLocalSearch(List<TransactionModel> transactions) {
    if (_searchQuery.isEmpty) return transactions;
    return transactions.where((t) =>
      (t.customer?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
      t.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
          );
          context.read<TransactionBloc>().add(const ClearTransactionError());
        }
      },
      builder: (context, state) {
        final filteredTransactions = _applyLocalSearch(state.transactions);
        final totalRevenue = filteredTransactions
            .where((t) => t.status == 'paid')
            .fold(0.0, (sum, t) => sum + t.totalAmount);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Riwayat Transaksi'),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Summary Cards
              Material(
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PhoneSummaryCard(
                              title: 'Total Transaksi',
                              value: '${filteredTransactions.length}',
                              icon: Icons.receipt_long,
                              iconColor: AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PhoneSummaryCard(
                              title: 'Pendapatan',
                              value: totalRevenue.toInt().compactCurrency,
                              icon: Icons.payments,
                              iconColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) => setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Cari transaksi...',
                                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _selectDateRange,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _dateRange != null ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _dateRange != null ? AppColors.primary : AppColors.border),
                              ),
                              child: Icon(Icons.calendar_today, size: 20, color: _dateRange != null ? Colors.white : AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _PhoneFilterChip(label: 'Semua', isSelected: _selectedFilter == 'all', onTap: () { setState(() => _selectedFilter = 'all'); _fetchFiltered(); }),
                            const SizedBox(width: 8),
                            _PhoneFilterChip(label: 'Selesai', isSelected: _selectedFilter == 'paid', onTap: () { setState(() => _selectedFilter = 'paid'); _fetchFiltered(); }, color: AppColors.success),
                            if (_dateRange != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () { setState(() => _dateRange = null); _fetchFiltered(); },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}', style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.close, size: 14, color: AppColors.info),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction List
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                const Text('Tidak ada transaksi', style: TextStyle(fontSize: 16, color: AppColors.textMuted)),
                                const SizedBox(height: 8),
                                const Text('Coba ubah filter pencarian', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = filteredTransactions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PhoneTransactionCard(
                                  transaction: transaction,
                                  onTap: () => _showTransactionDetail(transaction),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!);
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _fetchFiltered();
    }
  }

  void _showTransactionDetail(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.invoiceNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text(transaction.createdAt?.toFormattedDateTime ?? '-', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          _StatusBadge(status: transaction.status),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Customer Info
                      _PhoneDetailCard(
                        title: 'Pelanggan',
                        icon: Icons.person_outline,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                (transaction.customer?.name ?? '?')[0],
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(transaction.customer?.name ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Items
                      if (transaction.items != null)
                        _PhoneDetailCard(
                          title: 'Layanan',
                          icon: Icons.spa_outlined,
                          child: Column(
                            children: transaction.items!.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(item.itemName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                                  Text('x${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Payment Info
                      _PhoneDetailCard(
                        title: 'Pembayaran',
                        icon: Icons.payment_outlined,
                        child: Column(
                          children: [
                            if (transaction.payments != null && transaction.payments!.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Metode', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  Text(transaction.payments!.first.paymentMethodLabel ?? transaction.payments!.first.paymentMethod, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                ],
                              ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text(transaction.displayTotal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mencetak struk...'), backgroundColor: AppColors.info)); },
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Cetak'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          final items = (transaction.items ?? [])
                              .map((i) => '• ${i.itemName} x${i.quantity} = Rp ${i.totalPrice.toStringAsFixed(0)}')
                              .join('\n');
                          final receiptText = '''
===== STRUK TRANSAKSI =====
No: ${transaction.invoiceNumber}
Tanggal: ${transaction.createdAt?.toFormattedDateTime ?? '-'}

Pelanggan: ${transaction.customer?.name ?? '-'}

--- ITEM ---
$items

--- PEMBAYARAN ---
Subtotal: Rp ${transaction.subtotal.toStringAsFixed(0)}
${transaction.hasDiscount ? 'Diskon: - Rp ${transaction.discountAmount.toStringAsFixed(0)}\n' : ''}Total: ${transaction.displayTotal}

Terima kasih atas kunjungan Anda!
============================
''';
                          final phone = transaction.customer?.phone ?? '';
                          final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                          final waUrl = Uri.parse(
                            'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(receiptText)}',
                          );
                          final messenger = ScaffoldMessenger.of(context);
                          launchUrl(waUrl, mode: LaunchMode.externalApplication).catchError((_) {
                            Clipboard.setData(ClipboardData(text: receiptText));
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('WhatsApp tidak tersedia. Struk disalin ke clipboard.'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return false;
                          });
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Bagikan'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Shared Widgets ====================

class _PhoneSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _PhoneSummaryCard({required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _PhoneFilterChip({required this.label, required this.isSelected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? chipColor : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? chipColor : AppColors.textSecondary)),
      ),
    );
  }
}

class _PhoneTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const _PhoneTransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.receipt, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(transaction.invoiceNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            const SizedBox(width: 8),
                            _StatusBadge(status: transaction.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(transaction.customer?.name ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (transaction.items != null)
                Text(
                  transaction.items!.map((i) => i.itemName).join(', '),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (transaction.payments != null && transaction.payments!.isNotEmpty) ...[
                    Icon(_getPaymentIcon(transaction.payments!.first.paymentMethod), size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(_getPaymentLabel(transaction.payments!.first.paymentMethod), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(transaction.createdAt?.toFormattedDateTime ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(transaction.displayTotal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash': return Icons.payments;
      case 'debit_card': case 'credit_card': return Icons.credit_card;
      case 'qris': return Icons.qr_code;
      default: return Icons.payment;
    }
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'cash': return 'Cash';
      case 'debit_card': case 'credit_card': return 'Kartu';
      case 'qris': return 'QRIS';
      default: return method;
    }
  }
}

class _PhoneDetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _PhoneDetailCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SpaceWidth.w12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? chipColor : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? chipColor : AppColors.textSecondary)),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionListItem({required this.transaction, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: isSelected ? 1.5 : 0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(transaction.invoiceNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        const SpaceWidth.w8(),
                        _StatusBadge(status: transaction.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(transaction.customer?.name ?? '-', style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(transaction.createdAt?.toFormattedDateTime ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(transaction.displayTotal, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  if (transaction.payments != null && transaction.payments!.isNotEmpty)
                    Row(
                      children: [
                        Icon(_getPaymentIcon(transaction.payments!.first.paymentMethod), size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(_getPaymentLabel(transaction.payments!.first.paymentMethod), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash': return Icons.payments;
      case 'debit_card': case 'credit_card': return Icons.credit_card;
      case 'qris': return Icons.qr_code;
      default: return Icons.payment;
    }
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'cash': return 'Cash';
      case 'debit_card': case 'credit_card': return 'Kartu';
      case 'qris': return 'QRIS';
      default: return method;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = AppColors.success;
        label = 'Selesai';
        break;
      case 'pending':
        color = AppColors.info;
        label = 'Pending';
        break;
      case 'partial':
        color = AppColors.warning;
        label = 'Sebagian';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Batal';
        break;
      default:
        color = AppColors.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _TransactionDetailPanel extends StatefulWidget {
  final TransactionModel transaction;

  const _TransactionDetailPanel({required this.transaction});

  @override
  State<_TransactionDetailPanel> createState() => _TransactionDetailPanelState();
}

class _TransactionDetailPanelState extends State<_TransactionDetailPanel> {
  bool _isPrinting = false;

  Future<void> _printReceipt() async {
    final transaction = widget.transaction;
    final printerService = PrinterService();
    final isConnected = await printerService.checkConnection();

    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer belum terhubung. Buka Pengaturan > Printer & Struk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isPrinting = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mencetak struk...'),
          backgroundColor: AppColors.info,
        ),
      );
    }

    // Get cashier name
    final user = await AuthLocalDatasource().getUser();
    final cashierName = user?.name ?? 'Kasir';

    // Map transaction items to print items
    final printItems = (transaction.items ?? []).map((item) => PrintReceiptItem(
      name: item.itemName,
      itemType: item.itemType,
      qty: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: item.totalPrice,
    )).toList();

    // Map payments
    final payments = (transaction.payments ?? []).map((p) => PrintPaymentInfo(
      method: p.paymentMethod,
      amount: p.amount,
      referenceNumber: p.referenceNumber,
    )).toList();

    final success = await printerService.printReceipt(
      invoiceNumber: transaction.invoiceNumber,
      transactionDate: transaction.createdAt ?? DateTime.now(),
      items: printItems,
      subtotal: transaction.subtotal,
      discountAmount: transaction.discountAmount,
      discountLabel: transaction.discountType == 'percentage'
          ? 'Diskon %'
          : 'Diskon',
      totalAmount: transaction.totalAmount,
      payments: payments,
      cashierName: cashierName,
      customerName: transaction.customer?.name,
      customerPhone: transaction.customer?.phone,
      notes: transaction.notes,
    );

    if (mounted) {
      setState(() => _isPrinting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk.'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _shareReceipt() {
    final transaction = widget.transaction;
    final items = (transaction.items ?? [])
        .map((i) => '• ${i.itemName} x${i.quantity} = Rp ${i.totalPrice.toStringAsFixed(0)}')
        .join('\n');

    final receiptText = '''
===== STRUK TRANSAKSI =====
No: ${transaction.invoiceNumber}
Tanggal: ${transaction.createdAt?.toFormattedDateTime ?? '-'}

Pelanggan: ${transaction.customer?.name ?? '-'}

--- ITEM ---
$items

--- PEMBAYARAN ---
Subtotal: Rp ${transaction.subtotal.toStringAsFixed(0)}
${transaction.hasDiscount ? 'Diskon: - Rp ${transaction.discountAmount.toStringAsFixed(0)}\n' : ''}Total: ${transaction.displayTotal}

Terima kasih atas kunjungan Anda!
============================
''';

    // Open WhatsApp with receipt text
    final phone = transaction.customer?.phone ?? '';
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final waUrl = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(receiptText)}',
    );

    launchUrl(waUrl, mode: LaunchMode.externalApplication).catchError((_) {
      // Fallback: copy to clipboard
      Clipboard.setData(ClipboardData(text: receiptText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp tidak tersedia. Struk disalin ke clipboard.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.invoiceNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(transaction.createdAt?.toFormattedDateTime ?? '-', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _StatusBadge(status: transaction.status),
            ],
          ),
          const SpaceHeight.h24(),

          // Customer Info
          _DetailSection(
            title: 'Pelanggan',
            icon: Icons.person_outline,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text((transaction.customer?.name ?? '?')[0], style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
                const SpaceWidth.w12(),
                Text(transaction.customer?.name ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SpaceHeight.h16(),

          // Items
          if (transaction.items != null)
            _DetailSection(
              title: 'Layanan',
              icon: Icons.spa_outlined,
              child: Column(
                children: transaction.items!.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SpaceWidth.w12(),
                      Expanded(child: Text(item.itemName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
                      Text('x${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          const SpaceHeight.h16(),

          // Payment Info
          _DetailSection(
            title: 'Pembayaran',
            icon: Icons.payment_outlined,
            child: Column(
              children: [
                if (transaction.payments != null && transaction.payments!.isNotEmpty)
                  _PaymentRow(
                    label: 'Metode',
                    value: transaction.payments!.first.paymentMethodLabel ?? transaction.payments!.first.paymentMethod,
                  ),
                _PaymentRow(label: 'Subtotal', value: transaction.formattedSubtotal ?? 'Rp ${transaction.subtotal.toStringAsFixed(0)}'),
                if (transaction.hasDiscount)
                  _PaymentRow(label: 'Diskon', value: '- ${transaction.formattedDiscountAmount ?? 'Rp ${transaction.discountAmount.toStringAsFixed(0)}'}'),
                _PaymentRow(label: 'Total', value: transaction.displayTotal, isBold: true),
              ],
            ),
          ),
          const SpaceHeight.h24(),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPrinting ? null : _printReceipt,
                  icon: _isPrinting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.print, size: 18),
                  label: Text(_isPrinting ? 'Mencetak...' : 'Cetak'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareReceipt,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Bagikan'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSection({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SpaceWidth.w8(),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const SpaceHeight.h12(),
          child,
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PaymentRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isBold ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
