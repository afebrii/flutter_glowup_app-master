import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/components/spaces.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_detail_panel.dart';
import '../widgets/customer_form_dialog.dart';
import '../../appointment/pages/add_appointment_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      phone: _CustomerPhoneLayout(),
      tablet: _CustomerTabletLayout(),
    );
  }
}

// Phone Layout
class _CustomerPhoneLayout extends StatelessWidget {
  const _CustomerPhoneLayout();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerCreated) {
          Navigator.pop(context); // Close form dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pelanggan ${state.customer.name} berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CustomerUpdated) {
          Navigator.pop(context); // Close form dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pelanggan berhasil diperbarui'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CustomerDeleted) {
          Navigator.pop(context); // Close detail page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pelanggan berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const LoadingIndicator(message: 'Memuat pelanggan...');
        }

        if (state is CustomerError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<CustomerBloc>().add(FetchCustomers()),
          );
        }

        if (state is CustomerLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, CustomerLoaded state) {
    return Column(
      children: [
        // Search Bar & Add Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SearchInput(
                  hint: 'Cari pelanggan...',
                  onChanged: (value) {
                    context.read<CustomerBloc>().add(SearchCustomers(value));
                  },
                ),
              ),
              const SpaceWidth.w12(),
              IconButton.filled(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Customer List
        Expanded(
          child: state.filteredCustomers.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline,
                  message: 'Tidak ada pelanggan',
                  subtitle: 'Tambah pelanggan baru untuk memulai',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<CustomerBloc>().add(RefreshCustomers());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = state.filteredCustomers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CustomerCard(
                          customer: customer,
                          onTap: () => _openCustomerDetail(context, customer),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final isLoading = state is CustomerLoaded && state.isCreating;
            return CustomerFormDialog(
              isLoading: isLoading,
              onSubmit: (request) {
                context.read<CustomerBloc>().add(CreateCustomer(request));
              },
            );
          },
        ),
      ),
    );
  }

  void _openCustomerDetail(BuildContext context, customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CustomerBloc>(),
          child: _CustomerDetailPage(customer: customer),
        ),
      ),
    );
  }
}

// Customer Detail Page for Phone
class _CustomerDetailPage extends StatelessWidget {
  final dynamic customer;

  const _CustomerDetailPage({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggan'),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: CustomerDetailPanel(
        customer: customer,
        onEdit: () => _showEditDialog(context),
        onDelete: () => _showDeleteConfirmation(context),
        onBookAppointment: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final isLoading = state is CustomerLoaded && state.isUpdating;
            return CustomerFormDialog(
              customer: customer,
              isLoading: isLoading,
              onSubmit: (request) {
                context.read<CustomerBloc>().add(UpdateCustomer(customer.id, request));
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Apakah Anda yakin ingin menghapus ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CustomerBloc>().add(DeleteCustomer(customer.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Tablet Layout
class _CustomerTabletLayout extends StatelessWidget {
  const _CustomerTabletLayout();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerCreated) {
          Navigator.pop(context); // Close form dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pelanggan ${state.customer.name} berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
          // Auto select newly created customer
          context.read<CustomerBloc>().add(SelectCustomer(state.customer.id));
        } else if (state is CustomerUpdated) {
          Navigator.pop(context); // Close form dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pelanggan berhasil diperbarui'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is CustomerDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pelanggan berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const LoadingIndicator(message: 'Memuat pelanggan...');
        }

        if (state is CustomerError) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<CustomerBloc>().add(FetchCustomers()),
          );
        }

        if (state is CustomerLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, CustomerLoaded state) {
    return Row(
      children: [
        // Left Panel - Customer List (40%)
        Expanded(
          flex: 40,
          child: Column(
            children: [
              // Header with Search and Add
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SearchInput(
                            hint: 'Cari pelanggan...',
                            onChanged: (value) {
                              context.read<CustomerBloc>().add(SearchCustomers(value));
                            },
                          ),
                        ),
                        const SpaceWidth.w12(),
                        Button.filled(
                          onPressed: () => _showAddCustomerDialog(context),
                          label: 'Tambah',
                          icon: Icons.add,
                          width: 120,
                        ),
                      ],
                    ),
                    const SpaceHeight.h12(),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people, size: 18, color: AppColors.primary),
                          const SpaceWidth.w8(),
                          Text(
                            '${state.filteredCustomers.length} Pelanggan',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Customer List
              Expanded(
                child: state.filteredCustomers.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        message: 'Tidak ada pelanggan',
                        subtitle: 'Tambah pelanggan baru',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = state.filteredCustomers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CustomerListTile(
                              customer: customer,
                              isSelected: state.selectedCustomer?.id == customer.id,
                              onTap: () {
                                context.read<CustomerBloc>().add(SelectCustomer(customer.id));
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // Divider
        Container(width: 1, color: AppColors.border),

        // Right Panel - Customer Detail (60%)
        Expanded(
          flex: 60,
          child: state.selectedCustomer != null
              ? CustomerDetailPanel(
                  customer: state.selectedCustomer!,
                  onEdit: () => _showEditDialog(context, state.selectedCustomer!),
                  onDelete: () => _showDeleteConfirmation(context, state.selectedCustomer!),
                  onBookAppointment: () {
                    // TODO: Navigate to booking
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64, color: AppColors.textMuted),
                      SpaceHeight.h16(),
                      Text(
                        'Pilih pelanggan untuk melihat detail',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final isLoading = state is CustomerLoaded && state.isCreating;
            return CustomerFormDialog(
              isLoading: isLoading,
              onSubmit: (request) {
                context.read<CustomerBloc>().add(CreateCustomer(request));
              },
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final isLoading = state is CustomerLoaded && state.isUpdating;
            return CustomerFormDialog(
              customer: customer,
              isLoading: isLoading,
              onSubmit: (request) {
                context.read<CustomerBloc>().add(UpdateCustomer(customer.id, request));
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Apakah Anda yakin ingin menghapus ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CustomerBloc>().add(DeleteCustomer(customer.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
