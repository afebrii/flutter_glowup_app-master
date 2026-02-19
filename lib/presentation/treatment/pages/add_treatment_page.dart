import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/appointment_remote_datasource.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/responses/appointment_model.dart';
import '../../../data/models/responses/product_model.dart';
import '../bloc/treatment_bloc.dart';
import '../bloc/treatment_event.dart';
import '../bloc/treatment_state.dart';

class AddTreatmentPage extends StatefulWidget {
  /// Pre-filled appointment data (from appointment detail flow)
  final int? appointmentId;
  final int? customerId;
  final String? customerName;
  final String? serviceName;

  const AddTreatmentPage({
    super.key,
    this.appointmentId,
    this.customerId,
    this.customerName,
    this.serviceName,
  });

  bool get hasPrefilledAppointment => appointmentId != null;

  @override
  State<AddTreatmentPage> createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _productController = TextEditingController();

  // Appointment selection (standalone mode)
  List<AppointmentModel> _completedAppointments = [];
  AppointmentModel? _selectedAppointment;
  bool _isLoadingAppointments = false;

  DateTime? _followUpDate;
  final List<File> _beforePhotos = [];
  final List<File> _afterPhotos = [];
  final List<String> _productsUsed = [];

  // Product search
  List<ProductModel> _productSearchResults = [];
  bool _isSearchingProducts = false;
  Timer? _searchDebounce;
  late final ProductRemoteDatasource _productDatasource;

  final _picker = ImagePicker();

  static const int _maxPhotos = 5;

  @override
  void initState() {
    super.initState();
    final authLocal = AuthLocalDatasource();
    _productDatasource = ProductRemoteDatasource(
      api: ApiService(authLocal: authLocal),
    );
    if (!widget.hasPrefilledAppointment) {
      _loadCompletedAppointments();
    }
  }

  Future<void> _loadCompletedAppointments() async {
    setState(() => _isLoadingAppointments = true);

    final datasource = AppointmentRemoteDatasource();
    final result = await datasource.getAppointments(status: 'completed');

    if (mounted) {
      setState(() {
        result.fold(
          (error) => _completedAppointments = [],
          (appointments) => _completedAppointments = appointments,
        );
        _isLoadingAppointments = false;
      });
    }
  }

  int get _effectiveAppointmentId =>
      widget.appointmentId ?? _selectedAppointment!.id;

  int get _effectiveCustomerId =>
      widget.customerId ?? _selectedAppointment!.customerId;

  String get _effectiveCustomerName =>
      widget.customerName ?? _selectedAppointment?.customer?.name ?? 'Pelanggan';

  String get _effectiveServiceName =>
      widget.serviceName ?? _selectedAppointment?.service?.name ?? 'Service';

  bool get _hasAppointment =>
      widget.hasPrefilledAppointment || _selectedAppointment != null;

  @override
  void dispose() {
    _notesController.dispose();
    _recommendationsController.dispose();
    _productController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TreatmentBloc, TreatmentState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.read<TreatmentBloc>().add(const ClearTreatmentSuccess());
          Navigator.pop(context, true);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.read<TreatmentBloc>().add(const ClearTreatmentError());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Catat Treatment'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.border, height: 1),
          ),
        ),
        body: Form(
          key: _formKey,
          child: _isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppointmentSection(),
          const SpaceHeight.h20(),
          _buildSectionCard(
            title: 'Treatment Notes',
            icon: Icons.edit_note,
            children: [
              _buildSectionTitle('Notes'),
              const SpaceHeight.h8(),
              _buildNotesField(),
              const SpaceHeight.h16(),
              _buildSectionTitle('Recommendations'),
              const SpaceHeight.h8(),
              _buildRecommendationsField(),
              const SpaceHeight.h16(),
              _buildSectionTitle('Follow Up Date'),
              const SpaceHeight.h8(),
              _buildFollowUpDatePicker(),
            ],
          ),
          const SpaceHeight.h20(),
          _buildSectionTitle('Produk yang Digunakan'),
          const SpaceHeight.h8(),
          _buildProductsInput(),
          const SpaceHeight.h20(),
          _buildPhotosSection(),
          const SpaceHeight.h32(),
          _buildSubmitButton(),
          const SpaceHeight.h16(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Main Info
              Expanded(
                flex: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppointmentSection(),
                    const SpaceHeight.h20(),
                    _buildSectionCard(
                      title: 'Treatment Notes',
                      icon: Icons.edit_note,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Notes'),
                                  const SpaceHeight.h8(),
                                  _buildNotesField(),
                                ],
                              ),
                            ),
                            const SpaceWidth.w16(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Recommendations'),
                                  const SpaceHeight.h8(),
                                  _buildRecommendationsField(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SpaceHeight.h16(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Follow Up Date'),
                                  const SpaceHeight.h8(),
                                  _buildFollowUpDatePicker(),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                    const SpaceHeight.h20(),
                    _buildSectionTitle('Produk yang Digunakan'),
                    const SpaceHeight.h8(),
                    _buildProductsInput(),
                    const SpaceHeight.h24(),
                    _buildSubmitButton(),
                  ],
                ),
              ),
              const SpaceWidth.w24(),
              // Right Column - Photos
              Expanded(
                flex: 45,
                child: _buildPhotosSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return _buildSectionCard(
      title: 'Before & After Photos',
      icon: Icons.camera_alt,
      subtitle: 'Visual documentation of treatment results',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Before',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_beforePhotos.length}/$_maxPhotos',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight.h8(),
                  _buildPhotoGrid(_beforePhotos, isBeforePhotos: true),
                ],
              ),
            ),
            const SpaceWidth.w12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'After',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_afterPhotos.length}/$_maxPhotos',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight.h8(),
                  _buildPhotoGrid(_afterPhotos, isBeforePhotos: false),
                ],
              ),
            ),
          ],
        ),
        const SpaceHeight.h12(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photo Tips',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
              const SpaceHeight.h6(),
              _buildTip('Use consistent lighting'),
              _buildTip('Same angle for comparison'),
              _buildTip('Ensure area is clearly visible'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection() {
    return _buildSectionCard(
      title: 'Appointment',
      icon: Icons.event,
      children: [
        if (widget.hasPrefilledAppointment) ...[
          // Pre-filled: show info header
          _buildInfoHeader(),
        ] else ...[
          // Standalone: show dropdown
          const Text(
            'Select Appointment *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SpaceHeight.h8(),
          _buildAppointmentDropdown(),
          if (_selectedAppointment != null) ...[
            const SpaceHeight.h12(),
            _buildInfoHeader(),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SpaceWidth.w12(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SpaceHeight.h16(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAppointmentDropdown() {
    if (_isLoadingAppointments) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Memuat appointment...',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonFormField<AppointmentModel>(
        initialValue: _selectedAppointment,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Select Completed Appointment',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        items: _completedAppointments.map((appointment) {
          final customerName = appointment.customer?.name ?? 'Pelanggan';
          final serviceName = appointment.service?.name ?? 'Service';
          final date = appointment.appointmentDate.toFormattedDate;
          return DropdownMenuItem(
            value: appointment,
            child: Text(
              '$customerName - $serviceName ($date)',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedAppointment = value);
        },
        validator: (value) {
          if (!widget.hasPrefilledAppointment && value == null) {
            return 'Pilih appointment terlebih dahulu';
          }
          return null;
        },
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.spa, color: AppColors.primary, size: 20),
          ),
          const SpaceWidth.w12(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _effectiveCustomerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SpaceHeight.h4(),
                Text(
                  _effectiveServiceName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(14),
          border: InputBorder.none,
          hintText: 'Detailed notes about the treatment performed...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildProductsInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_productsUsed.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _productsUsed.asMap().entries.map((entry) {
                return Chip(
                  label: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  deleteIconColor: AppColors.textSecondary,
                  onDeleted: () {
                    setState(() => _productsUsed.removeAt(entry.key));
                  },
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SpaceHeight.h12(),
          ],
          // Search field
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _productController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: InputBorder.none,
                hintText: 'Cari produk...',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 0,
                ),
                suffixIcon: _isSearchingProducts
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: _onProductSearchChanged,
            ),
          ),
          // Search results
          if (_productSearchResults.isNotEmpty) ...[
            const SpaceHeight.h8(),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _productSearchResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final product = _productSearchResults[index];
                  final alreadyAdded = _productsUsed.contains(product.name);
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.inventory_2,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.inventory_2,
                              size: 18,
                              color: AppColors.primary,
                            ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      product.category?.name ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: alreadyAdded
                        ? const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.success,
                          )
                        : const Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                    onTap: alreadyAdded
                        ? null
                        : () {
                            setState(() {
                              _productsUsed.add(product.name);
                              _productController.clear();
                              _productSearchResults = [];
                            });
                          },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onProductSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _productSearchResults = [];
        _isSearchingProducts = false;
      });
      return;
    }

    setState(() => _isSearchingProducts = true);

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _productDatasource.searchProducts(query, limit: 10);
      if (mounted && _productController.text.trim() == query) {
        setState(() {
          _isSearchingProducts = false;
          result.fold(
            (_) => _productSearchResults = [],
            (products) => _productSearchResults = products,
          );
        });
      }
    });
  }

  Widget _buildRecommendationsField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _recommendationsController,
        maxLines: 3,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(14),
          border: InputBorder.none,
          hintText: 'Care recommendations for customer...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildFollowUpDatePicker() {
    return InkWell(
      onTap: _pickFollowUpDate,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: _followUpDate != null
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _followUpDate != null
                    ? _formatDate(_followUpDate!)
                    : 'dd/mm/yyyy',
                style: TextStyle(
                  fontSize: 13,
                  color: _followUpDate != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
            if (_followUpDate != null)
              GestureDetector(
                onTap: () => setState(() => _followUpDate = null),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _followUpDate = picked);
    }
  }

  Widget _buildPhotoGrid(List<File> photos, {required bool isBeforePhotos}) {
    final canAdd = photos.length < _maxPhotos;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (photos.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        photos[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => photos.removeAt(index));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SpaceHeight.h8(),
          ],
          if (canAdd)
            InkWell(
              onTap: () => _showPhotoSourcePicker(isBeforePhotos: isBeforePhotos),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add, size: 24, color: AppColors.textMuted),
                    const SizedBox(height: 4),
                    const Text(
                      'Add photos',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Text(
                      'JPG, PNG, WebP. Max 5MB',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoSourcePicker({required bool isBeforePhotos}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera, isBeforePhotos: isBeforePhotos);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery, isBeforePhotos: isBeforePhotos);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source, {
    required bool isBeforePhotos,
  }) async {
    final targetList = isBeforePhotos ? _beforePhotos : _afterPhotos;
    final remaining = _maxPhotos - targetList.length;
    if (remaining <= 0) return;

    try {
      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage(imageQuality: 80);
        if (images.isNotEmpty) {
          setState(() {
            final files = images
                .take(remaining)
                .map((xf) => File(xf.path))
                .toList();
            targetList.addAll(files);
          });
        }
      } else {
        final image = await _picker.pickImage(
          source: source,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            targetList.add(File(image.path));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TreatmentBloc, TreatmentState>(
      buildWhen: (prev, curr) => prev.isCreating != curr.isCreating,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: Button.filled(
                onPressed: state.isCreating ? null : _submitForm,
                label: 'Save Record',
                icon: Icons.save,
                isLoading: state.isCreating,
              ),
            ),
            const SizedBox(width: 12),
            Button.outlined(
              onPressed: state.isCreating ? null : () => Navigator.pop(context),
              label: 'Cancel',
              width: 100,
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasAppointment) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih appointment terlebih dahulu'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    context.read<TreatmentBloc>().add(
          CreateTreatment(
            appointmentId: _effectiveAppointmentId,
            customerId: _effectiveCustomerId,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
            recommendations: _recommendationsController.text.isNotEmpty
                ? _recommendationsController.text
                : null,
            followUpDate: _followUpDate,
            beforePhotos: _beforePhotos.isNotEmpty ? _beforePhotos : null,
            afterPhotos: _afterPhotos.isNotEmpty ? _afterPhotos : null,
            productsUsed: _productsUsed.isNotEmpty ? _productsUsed : null,
          ),
        );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
