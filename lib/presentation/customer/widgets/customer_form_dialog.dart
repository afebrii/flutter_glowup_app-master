import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../data/models/requests/customer_request_model.dart';
import '../../../data/models/responses/customer_model.dart';

class CustomerFormDialog extends StatefulWidget {
  final CustomerModel? customer; // null for create, existing for edit
  final Function(CustomerRequestModel) onSubmit;
  final bool isLoading;

  const CustomerFormDialog({
    super.key,
    this.customer,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _allergiesController;
  late TextEditingController _notesController;

  String? _selectedGender;
  String? _selectedSkinType;
  DateTime? _selectedBirthdate;
  List<String> _selectedSkinConcerns = [];

  final _skinConcernOptions = [
    'acne',
    'dark_spots',
    'wrinkles',
    'large_pores',
    'dullness',
    'fine_lines',
    'redness',
    'dryness',
    'blackheads',
    'sagging',
    'aging',
  ];

  final _skinConcernLabels = {
    'acne': 'Jerawat',
    'dark_spots': 'Flek Hitam',
    'wrinkles': 'Kerutan',
    'large_pores': 'Pori Besar',
    'dullness': 'Kusam',
    'fine_lines': 'Garis Halus',
    'redness': 'Kemerahan',
    'dryness': 'Kering',
    'blackheads': 'Komedo',
    'sagging': 'Kendur',
    'aging': 'Penuaan',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _allergiesController = TextEditingController(text: widget.customer?.allergies ?? '');
    _notesController = TextEditingController(text: widget.customer?.notes ?? '');

    _selectedGender = widget.customer?.gender;
    _selectedSkinType = widget.customer?.skinType;
    _selectedBirthdate = widget.customer?.birthdate;
    _selectedSkinConcerns = List.from(widget.customer?.skinConcerns ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit : Icons.person_add,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SpaceWidth.w12(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Pelanggan' : 'Pelanggan Baru',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isEdit ? 'Perbarui data pelanggan' : 'Tambah pelanggan baru',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      _buildSectionTitle('Informasi Dasar'),
                      const SpaceHeight.h12(),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        prefixIconData: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SpaceHeight.h12(),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hint: '081234567890',
                        prefixIconData: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SpaceHeight.h12(),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email (Opsional)',
                        hint: 'email@example.com',
                        prefixIconData: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SpaceHeight.h12(),

                      // Gender & Birthdate
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Jenis Kelamin',
                              value: _selectedGender,
                              items: const [
                                DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                                DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                          const SpaceWidth.w12(),
                          Expanded(
                            child: _buildDatePicker(),
                          ),
                        ],
                      ),
                      const SpaceHeight.h20(),

                      // Skin Profile Section
                      _buildSectionTitle('Profil Kulit'),
                      const SpaceHeight.h12(),
                      _buildDropdown(
                        label: 'Tipe Kulit',
                        value: _selectedSkinType,
                        items: const [
                          DropdownMenuItem(value: 'normal', child: Text('Normal')),
                          DropdownMenuItem(value: 'oily', child: Text('Berminyak')),
                          DropdownMenuItem(value: 'dry', child: Text('Kering')),
                          DropdownMenuItem(value: 'combination', child: Text('Kombinasi')),
                          DropdownMenuItem(value: 'sensitive', child: Text('Sensitif')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSkinType = value;
                          });
                        },
                      ),
                      const SpaceHeight.h12(),

                      // Skin Concerns
                      const Text(
                        'Masalah Kulit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SpaceHeight.h8(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skinConcernOptions.map((concern) {
                          final isSelected = _selectedSkinConcerns.contains(concern);
                          return FilterChip(
                            label: Text(_skinConcernLabels[concern] ?? concern),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSkinConcerns.add(concern);
                                } else {
                                  _selectedSkinConcerns.remove(concern);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          );
                        }).toList(),
                      ),
                      const SpaceHeight.h12(),

                      CustomTextField(
                        controller: _allergiesController,
                        label: 'Alergi (Opsional)',
                        hint: 'Contoh: Fragrance, Retinol',
                        prefixIconData: Icons.warning_amber_outlined,
                      ),
                      const SpaceHeight.h20(),

                      // Additional Info
                      _buildSectionTitle('Informasi Tambahan'),
                      const SpaceHeight.h12(),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Alamat (Opsional)',
                        hint: 'Masukkan alamat',
                        prefixIconData: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SpaceHeight.h12(),
                      CustomTextField(
                        controller: _notesController,
                        label: 'Catatan (Opsional)',
                        hint: 'Catatan tambahan tentang pelanggan',
                        prefixIconData: Icons.note_outlined,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () => Navigator.pop(context),
                      label: 'Batal',
                    ),
                  ),
                  const SpaceWidth.w12(),
                  Expanded(
                    child: Button.filled(
                      onPressed: _submitForm,
                      label: isEdit ? 'Simpan' : 'Tambah',
                      isLoading: widget.isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SpaceHeight.h6(),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: Text('Pilih $label'),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SpaceHeight.h6(),
        InkWell(
          onTap: _selectBirthdate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBirthdate != null
                        ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                        : 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedBirthdate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBirthdate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedBirthdate = date;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final request = CustomerRequestModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        birthdate: _selectedBirthdate?.toIso8601String().split('T').first,
        gender: _selectedGender,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        skinType: _selectedSkinType,
        skinConcerns: _selectedSkinConcerns.isNotEmpty ? _selectedSkinConcerns : null,
        allergies: _allergiesController.text.trim().isNotEmpty ? _allergiesController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      widget.onSubmit(request);
    }
  }
}
