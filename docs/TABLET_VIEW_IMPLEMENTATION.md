# Tablet View Implementation Guide - GlowUp Clinic

Dokumentasi step-by-step untuk mengimplementasikan tablet view pada aplikasi GlowUp Clinic, menggunakan pendekatan split-screen layout.

---

## Overview

Tablet view menggunakan pendekatan **split-screen layout** dimana:
- **Phone**: Layout single-column dengan navigation ke page terpisah
- **Tablet**: Layout split-screen dengan master-detail pattern

---

## Phase 1: Core Utilities & Responsive Foundation

### Step 1.1: Buat ScreenSize Utility

**File:** `lib/core/utils/screen_size.dart`

```dart
import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class ScreenSize {
  // Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  // Device Detection
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= phoneMaxWidth;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Responsive Value Helper
  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  // Grid Columns
  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3, desktop: 4);
  }

  static int serviceGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4, desktop: 5);
  }

  // Responsive Padding
  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0, desktop: 32.0);
  }

  // Responsive Font Size
  static double fontSize(BuildContext context, {double base = 14}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.1,
      desktop: base * 1.2,
    );
  }

  // Responsive Spacing
  static double spacing(BuildContext context, {double base = 16}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.25,
      desktop: base * 1.5,
    );
  }
}
```

### Step 1.2: Buat ResponsiveWidget

**File:** `lib/core/widgets/responsive_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ScreenSize.isDesktop(context)) {
          return desktop ?? tablet ?? phone;
        }
        if (ScreenSize.isTablet(context)) {
          return tablet ?? phone;
        }
        return phone;
      },
    );
  }
}
```

### Step 1.3: Buat ResponsiveLayout Builder

**File:** `lib/core/widgets/responsive_layout.dart`

```dart
import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSize.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}
```

---

## Phase 2: Dashboard Tablet Layout

### Step 2.1: Restructure Dashboard Page

**File:** `lib/presentation/dashboard/pages/dashboard_page.dart`

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      phone: DashboardPhoneLayout(),
      tablet: DashboardTabletLayout(),
    );
  }
}
```

### Step 2.2: Dashboard Phone Layout

**File:** `lib/presentation/dashboard/widgets/dashboard_phone_layout.dart`

- Single column layout
- 2x2 grid untuk stats cards
- Revenue chart
- Today's appointments list (scrollable)

```dart
class DashboardPhoneLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards (2x2 grid)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatsCard(title: 'Pendapatan Hari Ini', value: 'Rp 2.5jt', icon: Icons.payments),
              StatsCard(title: 'Appointment', value: '12', icon: Icons.calendar_today),
              StatsCard(title: 'Pelanggan Baru', value: '5', icon: Icons.person_add),
              StatsCard(title: 'Treatment Selesai', value: '8', icon: Icons.check_circle),
            ],
          ),
          const SizedBox(height: 24),
          // Revenue Chart
          const Text('Pendapatan 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const RevenueChart(),
          const SizedBox(height: 24),
          // Today's Appointments
          const Text('Appointment Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const TodayAppointmentsList(),
        ],
      ),
    );
  }
}
```

### Step 2.3: Dashboard Tablet Layout

**File:** `lib/presentation/dashboard/widgets/dashboard_tablet_layout.dart`

Split layout (60% | 40%):

```dart
class DashboardTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (60%) - Main Stats
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards (4 columns)
                    Row(
                      children: [
                        Expanded(child: StatsCard(title: 'Pendapatan', value: 'Rp 2.5jt')),
                        const SizedBox(width: 16),
                        Expanded(child: StatsCard(title: 'Appointment', value: '12')),
                        const SizedBox(width: 16),
                        Expanded(child: StatsCard(title: 'Pelanggan Baru', value: '5')),
                        const SizedBox(width: 16),
                        Expanded(child: StatsCard(title: 'Treatment', value: '8')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Revenue Chart (larger)
                    const Text('Pendapatan 7 Hari Terakhir'),
                    const SizedBox(height: 12),
                    const SizedBox(
                      height: 300,
                      child: RevenueChart(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Right Column (40%) - Appointments & Quick Actions
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    // Today's Appointments
                    const Text('Appointment Hari Ini'),
                    const SizedBox(height: 12),
                    const TodayAppointmentsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add,
            label: 'Booking Baru',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add,
            label: 'Pelanggan Baru',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
```

---

## Phase 3: Customer List Tablet Layout (Master-Detail)

### Step 3.1: Restructure Customer List Page

**File:** `lib/presentation/customer/pages/customer_list_page.dart`

```dart
class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelanggan')),
      body: ResponsiveWidget(
        phone: const CustomerPhoneLayout(),
        tablet: const CustomerTabletLayout(),
      ),
    );
  }
}
```

### Step 3.2: Customer Phone Layout

**File:** `lib/presentation/customer/widgets/customer_phone_layout.dart`

- Full width customer list
- Tap untuk navigate ke detail page

```dart
class CustomerPhoneLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchInput(
            hintText: 'Cari nama atau no. HP...',
            onChanged: (value) {
              context.read<CustomerBloc>().add(FetchCustomers(search: value));
            },
          ),
        ),
        // Customer List
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CustomerLoaded) {
                return ListView.builder(
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
                    return CustomerListItem(
                      customer: customer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomerDetailPage(customer: customer),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return const EmptyState(message: 'Tidak ada pelanggan');
            },
          ),
        ),
      ],
    );
  }
}
```

### Step 3.3: Customer Tablet Layout (Master-Detail)

**File:** `lib/presentation/customer/widgets/customer_tablet_layout.dart`

Split layout (40% | 60%):

```dart
class CustomerTabletLayout extends StatefulWidget {
  const CustomerTabletLayout({super.key});

  @override
  State<CustomerTabletLayout> createState() => _CustomerTabletLayoutState();
}

class _CustomerTabletLayoutState extends State<CustomerTabletLayout> {
  CustomerModel? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Customer List (40%)
        Expanded(
          flex: 40,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchInput(
                    hintText: 'Cari nama atau no. HP...',
                    onChanged: (value) {
                      context.read<CustomerBloc>().add(FetchCustomers(search: value));
                    },
                  ),
                ),
                // Customer List
                Expanded(
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CustomerLoaded) {
                        return ListView.builder(
                          itemCount: state.customers.length,
                          itemBuilder: (context, index) {
                            final customer = state.customers[index];
                            final isSelected = _selectedCustomer?.id == customer.id;
                            return CustomerListItem(
                              customer: customer,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                });
                              },
                            );
                          },
                        );
                      }
                      return const EmptyState(message: 'Tidak ada pelanggan');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Panel - Customer Detail (60%)
        Expanded(
          flex: 60,
          child: _selectedCustomer != null
              ? CustomerDetailPanel(customer: _selectedCustomer!)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Pilih pelanggan untuk melihat detail',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
```

---

## Phase 4: Appointment Calendar Tablet Layout

### Step 4.1: Calendar Phone Layout

**File:** `lib/presentation/appointment/widgets/calendar_phone_layout.dart`

- Calendar view (table_calendar)
- List appointments below calendar
- Tap untuk lihat detail

### Step 4.2: Calendar Tablet Layout

**File:** `lib/presentation/appointment/widgets/calendar_tablet_layout.dart`

Split layout (65% | 35%):

```dart
class CalendarTabletLayout extends StatefulWidget {
  @override
  State<CalendarTabletLayout> createState() => _CalendarTabletLayoutState();
}

class _CalendarTabletLayoutState extends State<CalendarTabletLayout> {
  DateTime _selectedDate = DateTime.now();
  AppointmentModel? _selectedAppointment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Calendar & Appointments (65%)
        Expanded(
          flex: 65,
          child: Column(
            children: [
              // Calendar
              TableCalendar(
                focusedDay: _selectedDate,
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                  context.read<CalendarBloc>().add(
                    FetchAppointmentsByDate(selectedDay),
                  );
                },
              ),
              const Divider(),
              // Appointments List
              Expanded(
                child: BlocBuilder<CalendarBloc, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = state.appointments[index];
                          return AppointmentCard(
                            appointment: appointment,
                            isSelected: _selectedAppointment?.id == appointment.id,
                            onTap: () {
                              setState(() {
                                _selectedAppointment = appointment;
                              });
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

        // Right Panel - Appointment Detail (35%)
        Expanded(
          flex: 35,
          child: _selectedAppointment != null
              ? AppointmentDetailPanel(appointment: _selectedAppointment!)
              : const Center(
                  child: Text('Pilih appointment untuk melihat detail'),
                ),
        ),
      ],
    );
  }
}
```

---

## Phase 5: Checkout/POS Tablet Layout

### Step 5.1: Checkout Phone Layout

- Service selection grid (2 columns)
- Bottom sheet for cart summary
- Navigate to payment page

### Step 5.2: Checkout Tablet Layout

**File:** `lib/presentation/pos/widgets/checkout_tablet_layout.dart`

Split layout (60% | 40%):

```dart
class CheckoutTabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Row(
        children: [
          // Left Panel - Items Selection (60%)
          Expanded(
            flex: 60,
            child: Column(
              children: [
                // Search & Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchInput(
                          hintText: 'Cari service...',
                          onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Category Filter
                      CategoryDropdown(),
                    ],
                  ),
                ),
                // Service Grid (4 columns)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return ServiceCard(
                        service: services[index],
                        onTap: () {
                          context.read<CheckoutBloc>().add(
                            AddToCart(services[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          // Right Panel - Cart Summary (40%)
          Expanded(
            flex: 40,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }
}
```

### Step 5.3: Cart Panel Widget

**File:** `lib/presentation/pos/widgets/cart_panel.dart`

```dart
class CartPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: 8),
                  const Text(
                    'Keranjang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  if (state.items.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        context.read<CheckoutBloc>().add(ClearCart());
                      },
                      child: const Text('Hapus Semua'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Cart Items
            Expanded(
              child: state.items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Keranjang kosong', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        return CartItemWidget(item: state.items[index]);
                      },
                    ),
            ),

            // Summary & Checkout
            if (state.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', state.subtotal.currencyFormat),
                    if (state.discount > 0)
                      _buildSummaryRow('Diskon', '-${state.discount.currencyFormat}'),
                    const Divider(),
                    _buildSummaryRow(
                      'Total',
                      state.total.currencyFormat,
                      isBold: true,
                    ),
                    const SizedBox(height: 16),
                    Button.filled(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(total: state.total),
                          ),
                        );
                      },
                      label: 'Bayar',
                      icon: Icons.payment,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
        ],
      ),
    );
  }
}
```

---

## Phase 6: Transaction History Tablet Layout

### Step 6.1: Split Layout untuk History

**Phone Layout:**
- List transaksi full width
- Tap untuk navigate ke detail page

**Tablet Layout:**
- Left: List transaksi (40%)
- Right: Detail transaksi selected (60%)

```dart
class TransactionHistoryTabletLayout extends StatefulWidget {
  @override
  State<TransactionHistoryTabletLayout> createState() => _TransactionHistoryTabletLayoutState();
}

class _TransactionHistoryTabletLayoutState extends State<TransactionHistoryTabletLayout> {
  TransactionModel? _selectedTransaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left - Transaction List (40%)
        Expanded(
          flex: 40,
          child: Column(
            children: [
              // Date Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: DateRangePicker(
                  onChanged: (start, end) {
                    context.read<TransactionHistoryBloc>().add(
                      FetchTransactions(startDate: start, endDate: end),
                    );
                  },
                ),
              ),
              // Transaction List
              Expanded(
                child: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
                  builder: (context, state) {
                    if (state is TransactionHistoryLoaded) {
                      return ListView.builder(
                        itemCount: state.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = state.transactions[index];
                          return TransactionListItem(
                            transaction: transaction,
                            isSelected: _selectedTransaction?.id == transaction.id,
                            onTap: () {
                              setState(() {
                                _selectedTransaction = transaction;
                              });
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

        // Right - Transaction Detail (60%)
        Expanded(
          flex: 60,
          child: _selectedTransaction != null
              ? TransactionDetailPanel(transaction: _selectedTransaction!)
              : const Center(
                  child: Text('Pilih transaksi untuk melihat detail'),
                ),
        ),
      ],
    );
  }
}
```

---

## Phase 7: Settings Tablet Layout

### Step 7.1: Settings Page Tablet

**Tablet Layout:** Two-column settings

```dart
class SettingsTabletLayout extends StatefulWidget {
  @override
  State<SettingsTabletLayout> createState() => _SettingsTabletLayoutState();
}

class _SettingsTabletLayoutState extends State<SettingsTabletLayout> {
  int _selectedIndex = 0;

  final List<SettingsSection> _sections = [
    SettingsSection(icon: Icons.person, title: 'Profil', page: ProfileSettingsPage()),
    SettingsSection(icon: Icons.store, title: 'Klinik', page: ClinicSettingsPage()),
    SettingsSection(icon: Icons.print, title: 'Printer', page: PrinterSettingsPage()),
    SettingsSection(icon: Icons.info, title: 'Tentang', page: AboutPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left - Settings Menu (35%)
        Expanded(
          flex: 35,
          child: Container(
            color: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isSelected = _selectedIndex == index;
                return ListTile(
                  leading: Icon(
                    section.icon,
                    color: isSelected ? AppColors.primary : null,
                  ),
                  title: Text(
                    section.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : null,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),

        const VerticalDivider(width: 1),

        // Right - Settings Content (65%)
        Expanded(
          flex: 65,
          child: _sections[_selectedIndex].page,
        ),
      ],
    );
  }
}

class SettingsSection {
  final IconData icon;
  final String title;
  final Widget page;

  SettingsSection({
    required this.icon,
    required this.title,
    required this.page,
  });
}
```

---

## File Structure Summary

```
lib/
├── core/
│   ├── utils/
│   │   └── screen_size.dart          # Responsive utilities
│   └── widgets/
│       ├── responsive_widget.dart     # Phone/Tablet switcher
│       └── responsive_layout.dart     # Layout builder
│
├── presentation/
│   ├── dashboard/
│   │   ├── pages/
│   │   │   └── dashboard_page.dart
│   │   └── widgets/
│   │       ├── dashboard_phone_layout.dart
│   │       └── dashboard_tablet_layout.dart
│   │
│   ├── customer/
│   │   ├── pages/
│   │   │   └── customer_list_page.dart
│   │   └── widgets/
│   │       ├── customer_phone_layout.dart
│   │       ├── customer_tablet_layout.dart
│   │       └── customer_detail_panel.dart
│   │
│   ├── appointment/
│   │   ├── pages/
│   │   │   └── appointment_calendar_page.dart
│   │   └── widgets/
│   │       ├── calendar_phone_layout.dart
│   │       ├── calendar_tablet_layout.dart
│   │       └── appointment_detail_panel.dart
│   │
│   ├── pos/
│   │   ├── pages/
│   │   │   └── checkout_page.dart
│   │   └── widgets/
│   │       ├── checkout_phone_layout.dart
│   │       ├── checkout_tablet_layout.dart
│   │       └── cart_panel.dart
│   │
│   ├── transaction/
│   │   ├── pages/
│   │   │   └── transaction_history_page.dart
│   │   └── widgets/
│   │       ├── history_phone_layout.dart
│   │       ├── history_tablet_layout.dart
│   │       └── transaction_detail_panel.dart
│   │
│   └── settings/
│       └── widgets/
│           ├── settings_phone_layout.dart
│           └── settings_tablet_layout.dart
```

---

## Key Design Patterns

### 1. Split Screen Ratio

| Page | Left Panel | Right Panel |
|------|------------|-------------|
| Dashboard | 60% (Stats, Chart) | 40% (Appointments) |
| Customer List | 40% (List) | 60% (Detail) |
| Appointment Calendar | 65% (Calendar) | 35% (Detail) |
| Checkout/POS | 60% (Items) | 40% (Cart) |
| Transaction History | 40% (List) | 60% (Detail) |
| Settings | 35% (Menu) | 65% (Content) |

### 2. Grid Columns

| Device | Services | Cards | Products |
|--------|----------|-------|----------|
| Phone | 2 | 2 | 2 |
| Tablet | 4 | 4 | 4 |
| Desktop | 5 | 4 | 5 |

### 3. Padding Scale

| Device | Base Padding |
|--------|-------------|
| Phone | 16px |
| Tablet | 24px |
| Desktop | 32px |

---

## Testing Checklist

- [ ] Phone portrait (< 600px)
- [ ] Phone landscape
- [ ] Tablet portrait (600px - 900px)
- [ ] Tablet landscape (900px - 1024px)
- [ ] Desktop (> 1024px)

---

## Notes

1. **State Management**: Gunakan BLoC yang sama untuk phone dan tablet, hanya UI yang berbeda
2. **Navigation**: Untuk tablet, beberapa navigasi diganti dengan panel selection (master-detail)
3. **Performance**: Lazy load untuk grid items
4. **Orientation**: Test kedua orientasi (portrait & landscape)
5. **Selection State**: Untuk tablet layout, gunakan StatefulWidget untuk track selected item

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*
