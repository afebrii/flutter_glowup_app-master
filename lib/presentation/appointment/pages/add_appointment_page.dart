import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/spaces.dart';
import '../../../data/datasources/appointment_remote_datasource.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../../../data/datasources/service_remote_datasource.dart';
import '../../../data/models/requests/appointment_request_model.dart';
import '../../../data/models/responses/appointment_model.dart';
import '../../../data/models/responses/customer_model.dart';
import '../../../data/models/responses/service_model.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  CustomerModel? _selectedCustomer;
  ServiceModel? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  AppointmentSource _selectedSource = AppointmentSource.walkIn;

  List<CustomerModel> _customers = [];
  List<ServiceModel> _services = [];
  List<TimeSlot> _availableSlots = [];
  bool _isLoadingData = true;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customerDatasource = CustomerRemoteDatasource();
    final serviceDatasource = ServiceRemoteDatasource();

    final customerResult = await customerDatasource.getCustomers();
    final serviceResult = await serviceDatasource.getServices();

    if (mounted) {
      setState(() {
        customerResult.fold(
          (error) => {},
          (customers) => _customers = customers,
        );
        serviceResult.fold(
          (error) => {},
          (services) => _services = services,
        );
        _isLoadingData = false;
      });
    }
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedService == null) return;

    setState(() => _isLoadingSlots = true);

    final datasource = AppointmentRemoteDatasource();
    final result = await datasource.getAvailableSlots(
      date: _selectedDate,
      serviceId: _selectedService!.id,
    );

    if (mounted) {
      setState(() {
        result.fold(
          (error) {
            _availableSlots = [];
            _showError('Gagal memuat slot: $error');
          },
          (slots) => _availableSlots = slots,
        );
        _isLoadingSlots = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Selection
                    _buildSectionTitle('Pelanggan'),
                    const SpaceHeight.h8(),
                    _buildCustomerDropdown(),
                    const SpaceHeight.h20(),

                    // Service Selection
                    _buildSectionTitle('Layanan'),
                    const SpaceHeight.h8(),
                    _buildServiceDropdown(),
                    const SpaceHeight.h20(),

                    // Date Selection
                    _buildSectionTitle('Tanggal'),
                    const SpaceHeight.h8(),
                    _buildDatePicker(),
                    const SpaceHeight.h20(),

                    // Time Selection
                    _buildSectionTitle('Waktu'),
                    const SpaceHeight.h8(),
                    _buildTimeSlots(),
                    const SpaceHeight.h20(),

                    // Source Selection
                    _buildSectionTitle('Sumber Booking'),
                    const SpaceHeight.h8(),
                    _buildSourceSelection(),
                    const SpaceHeight.h20(),

                    // Notes
                    _buildSectionTitle('Catatan (Opsional)'),
                    const SpaceHeight.h8(),
                    _buildNotesField(),
                    const SpaceHeight.h32(),

                    // Submit Button
                    _buildSubmitButton(),
                    const SpaceHeight.h16(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<CustomerModel>(
        initialValue: _selectedCustomer,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Pilih pelanggan',
        ),
        items: _customers.map((customer) {
          return DropdownMenuItem(
            value: customer,
            child: Text(
              '${customer.name} (${customer.phone})',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCustomer = value);
        },
        validator: (value) {
          if (value == null) return 'Pilih pelanggan';
          return null;
        },
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<ServiceModel>(
        initialValue: _selectedService,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Pilih layanan',
        ),
        items: _services.map((service) {
          return DropdownMenuItem(
            value: service,
            child: Text(
              '${service.name} (${service.durationFormatted} • ${_formatCurrency(service.price)})',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedService = value;
            _selectedTime = null;
            _availableSlots = [];
          });
          if (value != null) {
            _loadTimeSlots();
          }
        },
        validator: (value) {
          if (value == null) return 'Pilih layanan';
          return null;
        },
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _selectedDate,
        calendarFormat: CalendarFormat.week,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _selectedTime = null;
            _availableSlots = [];
          });
          if (_selectedService != null) {
            _loadTimeSlots();
          }
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        rowHeight: 40,
        daysOfWeekHeight: 32,
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedService == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Pilih layanan terlebih dahulu',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    if (_isLoadingSlots) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text(
            'Tidak ada slot tersedia',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _availableSlots.map((slot) {
          final isSelected = _selectedTime == slot.time;
          final isAvailable = slot.isAvailable;

          return InkWell(
            onTap: isAvailable
                ? () {
                    setState(() => _selectedTime = slot.time);
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isAvailable
                        ? AppColors.background
                        : AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                slot.time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSourceSelection() {
    final sources = [
      (AppointmentSource.walkIn, Icons.directions_walk, 'Walk-in'),
      (AppointmentSource.phone, Icons.phone, 'Telepon'),
      (AppointmentSource.whatsapp, Icons.chat, 'WhatsApp'),
      (AppointmentSource.online, Icons.language, 'Online'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: sources.map((source) {
          final isSelected = _selectedSource == source.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedSource = source.$1);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        source.$2,
                        size: 20,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        source.$3,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: 'Tambahkan catatan...',
          hintStyle: TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Buat Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomer == null) {
      _showError('Pilih pelanggan terlebih dahulu');
      return;
    }
    if (_selectedService == null) {
      _showError('Pilih layanan terlebih dahulu');
      return;
    }
    if (_selectedTime == null) {
      _showError('Pilih waktu appointment');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = AppointmentRequestModel(
      customerId: _selectedCustomer!.id,
      serviceId: _selectedService!.id,
      appointmentDate: _selectedDate.toIso8601String().split('T').first,
      startTime: _selectedTime!,
      source: _selectedSource.toApiString(),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    final datasource = AppointmentRemoteDatasource();
    final result = await datasource.createAppointment(request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    result.fold(
      (error) {
        _showErrorDialog(error);
      },
      (appointment) {
        _showSuccessDialog();
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SpaceHeight.h12(),
            const Text(
              'Berhasil!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Appointment untuk ${_selectedCustomer?.name ?? ''} berhasil dibuat.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_formatDate(_selectedDate)} • $_selectedTime',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SpaceHeight.h16(),
            const Text(
              'Gagal!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SpaceHeight.h8(),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return 'Rp $formatted';
  }
}
