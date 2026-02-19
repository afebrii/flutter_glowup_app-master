import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/extensions/int_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../../../data/datasources/package_remote_datasource.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/datasources/service_remote_datasource.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import '../../../data/models/responses/appointment_model.dart';
import '../../../data/models/responses/transaction_model.dart';
import '../../../injection.dart';
import '../bloc/checkout_bloc.dart';

class CheckoutPage extends StatelessWidget {
  final AppointmentModel? preselectedAppointment;
  final TransactionModel? existingTransaction;

  const CheckoutPage({
    super.key,
    this.preselectedAppointment,
    this.existingTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(
        transactionDatasource: getIt<TransactionRemoteDatasource>(),
      ),
      child: ResponsiveWidget(
        phone: _CheckoutPhoneLayout(
          preselectedAppointment: preselectedAppointment,
          existingTransaction: existingTransaction,
        ),
        tablet: _CheckoutTabletLayout(
          preselectedAppointment: preselectedAppointment,
          existingTransaction: existingTransaction,
        ),
      ),
    );
  }
}

// Tablet Layout - POS Style
class _CheckoutTabletLayout extends StatefulWidget {
  final AppointmentModel? preselectedAppointment;
  final TransactionModel? existingTransaction;

  const _CheckoutTabletLayout({
    this.preselectedAppointment,
    this.existingTransaction,
  });

  @override
  State<_CheckoutTabletLayout> createState() => _CheckoutTabletLayoutState();
}

class _CheckoutTabletLayoutState extends State<_CheckoutTabletLayout> {
  List<CartItem> _cartItems = [];
  CustomerInfo? _selectedCustomer;
  String _paymentMethod = 'cash';
  int _discountAmount = 0;
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Layanan, 1 = Paket, 2 = Produk

  // Loyalty points
  int _customerLoyaltyPoints = 0;
  bool _useLoyaltyPoints = false;
  int _pointsToUse = 0;
  static const int _pointsValue = 100; // 1 poin = Rp 100
  static const int _minPointsRedeem = 10;
  final _pointsController = TextEditingController();

  // API data
  List<ServiceItem> _services = [];
  List<PackageItem> _packages = [];
  List<ProductItem> _products = [];
  List<CustomerInfo> _customers = [];
  List<PaymentMethodInfo> _paymentMethods = [];
  bool _isLoadingData = true;
  bool _isLoadingPoints = false;

  @override
  void initState() {
    super.initState();
    _initFromAppointment();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    await Future.wait([
      _loadServices(),
      _loadPackages(),
      _loadProducts(),
      _loadCustomers(),
      _loadPaymentMethods(),
    ]);

    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _loadServices() async {
    final datasource = getIt<ServiceRemoteDatasource>();
    final result = await datasource.getServices();
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout] Failed to load services: $error'),
      (services) {
        setState(() {
          _services = services
              .where((s) => s.isActive)
              .map(
                (s) => ServiceItem(
                  id: s.id,
                  name: s.name,
                  category: s.category?.name ?? 'Umum',
                  price: s.price,
                  duration: s.durationMinutes,
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadPackages() async {
    final datasource = getIt<PackageRemoteDatasource>();
    final result = await datasource.getPackages();
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout] Failed to load packages: $error'),
      (packages) {
        setState(() {
          _packages = packages
              .where((p) => p.isActive)
              .map(
                (p) => PackageItem(
                  id: p.id,
                  name: p.name,
                  price: p.packagePrice.toInt(),
                  originalPrice: p.originalPrice.toInt(),
                  sessions: p.totalSessions,
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadProducts() async {
    final datasource = getIt<ProductRemoteDatasource>();
    final result = await datasource.getProducts(perPage: 100);
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout] Failed to load products: $error'),
      (response) {
        setState(() {
          _products = response.data
              .where((p) => p.isActive && !p.isOutOfStock)
              .map(
                (p) => ProductItem(
                  id: p.id,
                  name: p.name,
                  category: p.category?.name ?? 'Umum',
                  price: p.price.toInt(),
                  stock: p.stock,
                  unit: p.unit ?? 'pcs',
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadCustomers() async {
    final datasource = getIt<CustomerRemoteDatasource>();
    final result = await datasource.getCustomers(perPage: 100);
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout] Failed to load customers: $error'),
      (customers) {
        setState(() {
          _customers = customers
              .map((c) => CustomerInfo(id: c.id, name: c.name, phone: c.phone))
              .toList();
        });
      },
    );
  }

  Future<void> _loadPaymentMethods() async {
    final authLocal = AuthLocalDatasource();
    final api = ApiService(authLocal: authLocal);
    final result = await api.get('/settings/payment-methods');
    if (!mounted) return;
    result.fold(
      (error) {
        debugPrint('[Checkout] Failed to load payment methods: $error');
        // Use default payment methods if API fails
        setState(() {
          _paymentMethods = [
            PaymentMethodInfo(
              key: 'cash',
              label: 'Cash',
              description: 'Pembayaran tunai',
              icon: 'payments',
            ),
            PaymentMethodInfo(
              key: 'debit_card',
              label: 'Kartu',
              description: 'Debit/Kredit',
              icon: 'credit_card',
            ),
            PaymentMethodInfo(
              key: 'qris',
              label: 'QRIS',
              description: 'Scan QR',
              icon: 'qr_code',
            ),
          ];
        });
      },
      (data) {
        final methods = (data['data'] as List?) ?? [];
        setState(() {
          _paymentMethods = methods
              .map(
                (m) => PaymentMethodInfo(
                  key: m['key'] ?? '',
                  label: m['label'] ?? '',
                  description: m['description'] ?? '',
                  icon: m['icon'] ?? 'payments',
                ),
              )
              .toList();
          // Set default payment method to first one if available
          if (_paymentMethods.isNotEmpty) {
            _paymentMethod = _paymentMethods.first.key;
          }
        });
      },
    );
  }

  void _initFromAppointment() {
    if (widget.preselectedAppointment != null) {
      final apt = widget.preselectedAppointment!;
      // Set customer
      if (apt.customer != null) {
        _selectedCustomer = CustomerInfo(
          id: apt.customer!.id,
          name: apt.customer!.name,
          phone: apt.customer!.phone,
        );
        // Load loyalty points for preselected customer
        _loadCustomerLoyaltyPoints(apt.customer!.id);
      }
      // Add service to cart
      if (apt.service != null) {
        _cartItems = [
          CartItem(
            serviceId: apt.service!.id,
            name: apt.service!.name,
            price: apt.service!.price,
            quantity: 1,
            isPackage: false,
          ),
        ];
      }
    }
  }

  Future<void> _loadCustomerLoyaltyPoints(int customerId) async {
    setState(() => _isLoadingPoints = true);

    final authLocal = AuthLocalDatasource();
    final api = ApiService(authLocal: authLocal);

    final result = await api.get('/customers/$customerId');

    if (!mounted) return;

    result.fold(
      (error) {
        debugPrint('[Checkout] Failed to load customer points: $error');
        setState(() {
          _customerLoyaltyPoints = 0;
          _isLoadingPoints = false;
        });
      },
      (data) {
        final points = data['data']?['loyalty_points'] ?? 0;
        setState(() {
          _customerLoyaltyPoints = points is int
              ? points
              : int.tryParse(points.toString()) ?? 0;
          _isLoadingPoints = false;
          // Reset points usage when customer changes
          _useLoyaltyPoints = false;
          _pointsToUse = 0;
          _pointsController.clear();
        });
        debugPrint(
          '[Checkout] Customer loyalty points: $_customerLoyaltyPoints',
        );
      },
    );
  }

  void _resetLoyaltyPoints() {
    _customerLoyaltyPoints = 0;
    _useLoyaltyPoints = false;
    _pointsToUse = 0;
    _pointsController.clear();
  }

  int get _maxPointsToUse {
    // Maximum points = minimum of (customer points, (subtotal - discount) / points_value)
    final maxBySubtotal = ((_subtotal - _discountAmount) / _pointsValue)
        .floor();
    return _customerLoyaltyPoints < maxBySubtotal
        ? _customerLoyaltyPoints
        : maxBySubtotal;
  }

  int get _pointsDiscount {
    if (!_useLoyaltyPoints || _pointsToUse <= 0) return 0;
    return _pointsToUse * _pointsValue;
  }

  List<ServiceItem> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services
        .where(
          (s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<PackageItem> get _filteredPackages {
    if (_searchQuery.isEmpty) return _packages;
    return _packages
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ProductItem> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  int get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get _total => _subtotal - _discountAmount - _pointsDiscount;

  void _addToCart(ServiceItem service) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) =>
            item.serviceId == service.id && !item.isPackage && !item.isProduct,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItem(
            serviceId: service.id,
            name: service.name,
            price: service.price,
            quantity: 1,
            isPackage: false,
            isProduct: false,
          ),
        );
      }
    });
  }

  void _addPackageToCart(PackageItem package) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.serviceId == package.id && item.isPackage,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItem(
            serviceId: package.id,
            name: package.name,
            price: package.price,
            quantity: 1,
            isPackage: true,
            isProduct: false,
          ),
        );
      }
    });
  }

  void _addProductToCart(ProductItem product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.serviceId == product.id && item.isProduct,
      );
      if (existingIndex >= 0) {
        // Check stock limit
        if (_cartItems[existingIndex].quantity < product.stock) {
          _cartItems[existingIndex].quantity++;
        }
      } else {
        _cartItems.add(
          CartItem(
            serviceId: product.id,
            name: product.name,
            price: product.price,
            quantity: 1,
            isPackage: false,
            isProduct: true,
          ),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName) {
      case 'payments':
        return Icons.payments;
      case 'credit_card':
        return Icons.credit_card;
      case 'qr_code':
        return Icons.qr_code;
      case 'account_balance':
        return Icons.account_balance;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Services Grid (60%)
            Expanded(
              flex: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Selector + Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Tab Selector
                        Row(
                          children: [
                            _TabButton(
                              icon: Icons.spa,
                              label: 'Layanan',
                              isSelected: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                            const SpaceWidth.w8(),
                            _TabButton(
                              icon: Icons.card_giftcard,
                              label: 'Paket',
                              isSelected: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                            const SpaceWidth.w8(),
                            _TabButton(
                              icon: Icons.inventory_2,
                              label: 'Produk',
                              isSelected: _selectedTab == 2,
                              onTap: () => setState(() => _selectedTab = 2),
                            ),
                            const Spacer(),
                            Expanded(
                              child: SearchInput(
                                hint: _selectedTab == 0
                                    ? 'Cari layanan...'
                                    : _selectedTab == 1
                                    ? 'Cari paket...'
                                    : 'Cari produk...',
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SpaceHeight.h16(),

                  // Content Grid (Services or Packages)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedTab == 0
                                    ? Icons.spa
                                    : _selectedTab == 1
                                    ? Icons.card_giftcard
                                    : Icons.inventory_2,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SpaceWidth.w8(),
                              Text(
                                _selectedTab == 0
                                    ? 'Pilih Layanan'
                                    : _selectedTab == 1
                                    ? 'Pilih Paket'
                                    : 'Pilih Produk',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _selectedTab == 0
                                    ? '${_filteredServices.length} layanan'
                                    : _selectedTab == 1
                                    ? '${_filteredPackages.length} paket'
                                    : '${_filteredProducts.length} produk',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SpaceHeight.h16(),
                          Expanded(
                            child: _selectedTab == 0
                                ? GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 1.4,
                                        ),
                                    itemCount: _filteredServices.length,
                                    itemBuilder: (context, index) {
                                      final service = _filteredServices[index];
                                      return _ServiceTile(
                                        service: service,
                                        onTap: () => _addToCart(service),
                                      );
                                    },
                                  )
                                : _selectedTab == 1
                                ? GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 1.2,
                                        ),
                                    itemCount: _filteredPackages.length,
                                    itemBuilder: (context, index) {
                                      final package = _filteredPackages[index];
                                      return _PackageTile(
                                        package: package,
                                        onTap: () => _addPackageToCart(package),
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 1.4,
                                        ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      return _ProductTile(
                                        product: product,
                                        onTap: () => _addProductToCart(product),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SpaceWidth.w20(),

            // Right Panel - Cart (40%)
            Expanded(
              flex: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_cart,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SpaceWidth.w8(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keranjang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${_cartItems.length} item',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_cartItems.isNotEmpty)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _cartItems.clear()),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Hapus',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Scrollable content: Customer + Cart Items + Summary
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Customer Selection
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: InkWell(
                              onTap: () => _showCustomerPicker(),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedCustomer != null
                                        ? AppColors.primary.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: _selectedCustomer != null
                                          ? AppColors.primary
                                          : AppColors.textMuted.withValues(
                                              alpha: 0.2,
                                            ),
                                      child: Icon(
                                        Icons.person,
                                        size: 14,
                                        color: _selectedCustomer != null
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedCustomer != null
                                            ? '${_selectedCustomer!.name} • ${_selectedCustomer!.phone}'
                                            : 'Pilih Pelanggan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _selectedCustomer != null
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: _selectedCustomer != null
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textMuted,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Cart Items
                          if (_cartItems.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_shopping_cart,
                                    size: 40,
                                    color: AppColors.textMuted.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SpaceHeight.h8(),
                                  const Text(
                                    'Keranjang kosong',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...List.generate(_cartItems.length, (index) {
                              final item = _cartItems[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: _CartItemTile(
                                      item: item,
                                      onQuantityChanged: (delta) =>
                                          _updateQuantity(index, delta),
                                      onRemove: () => _removeFromCart(index),
                                    ),
                                  ),
                                  if (index < _cartItems.length - 1)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Divider(height: 1),
                                    ),
                                ],
                              );
                            }),

                          // Summary & Checkout
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Loyalty Points (show only if customer has points)
                                if (_customerLoyaltyPoints > 0 &&
                                    _customerLoyaltyPoints >=
                                        _minPointsRedeem) ...[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.amber.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.stars,
                                              size: 16,
                                              color: Colors.amber[700],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Poin Tersedia: $_customerLoyaltyPoints',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.amber[800],
                                              ),
                                            ),
                                            const Spacer(),
                                            Transform.scale(
                                              scale: 0.8,
                                              child: Switch(
                                                value: _useLoyaltyPoints,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _useLoyaltyPoints = value;
                                                    if (value) {
                                                      _pointsToUse =
                                                          _maxPointsToUse;
                                                      _pointsController.text =
                                                          _pointsToUse
                                                              .toString();
                                                    } else {
                                                      _pointsToUse = 0;
                                                      _pointsController.clear();
                                                    }
                                                  });
                                                },
                                                activeColor: Colors.amber[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_useLoyaltyPoints) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 32,
                                                  child: TextField(
                                                    controller:
                                                        _pointsController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: 'Jumlah poin',
                                                      hintStyle:
                                                          const TextStyle(
                                                            fontSize: 11,
                                                          ),
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .amber[300]!,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                            borderSide: BorderSide(
                                                              color: Colors
                                                                  .amber[600]!,
                                                            ),
                                                          ),
                                                    ),
                                                    onChanged: (value) {
                                                      int parsed =
                                                          int.tryParse(value) ??
                                                          0;
                                                      if (parsed >
                                                          _maxPointsToUse)
                                                        parsed =
                                                            _maxPointsToUse;
                                                      if (parsed < 0)
                                                        parsed = 0;
                                                      setState(
                                                        () => _pointsToUse =
                                                            parsed,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _pointsToUse =
                                                        _maxPointsToUse;
                                                    _pointsController.text =
                                                        _maxPointsToUse
                                                            .toString();
                                                  });
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.amber[800],
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Maks',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_pointsToUse > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '$_pointsToUse poin = ${_pointsDiscount.currencyFormat}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.amber[700],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Discount input
                                Row(
                                  children: [
                                    const Text(
                                      'Diskon',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 32,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: const TextStyle(
                                              fontSize: 11,
                                            ),
                                            prefixText: 'Rp ',
                                            prefixStyle: const TextStyle(
                                              fontSize: 11,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              borderSide: const BorderSide(
                                                color: AppColors.border,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _discountAmount =
                                                  int.tryParse(
                                                    value.replaceAll('.', ''),
                                                  ) ??
                                                  0;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Subtotal
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Subtotal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _subtotal.currencyFormat,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_discountAmount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Diskon',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        '- ${_discountAmount.currencyFormat}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_pointsDiscount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Poin ($_pointsToUse)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber[700],
                                        ),
                                      ),
                                      Text(
                                        '- ${_pointsDiscount.currencyFormat}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.amber[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 6),
                                const Divider(height: 1),
                                const SizedBox(height: 6),
                                // Total
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _total.currencyFormat,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Payment Method - compact inline
                                Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < _paymentMethods.length;
                                      i++
                                    ) ...[
                                      if (i > 0) const SizedBox(width: 6),
                                      Expanded(
                                        child: _PaymentMethodButton(
                                          icon: _getPaymentIcon(
                                            _paymentMethods[i].icon,
                                          ),
                                          label: _paymentMethods[i].label,
                                          isSelected:
                                              _paymentMethod ==
                                              _paymentMethods[i].key,
                                          onTap: () => setState(
                                            () => _paymentMethod =
                                                _paymentMethods[i].key,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Checkout Button
                                Button.filled(
                                  onPressed: _cartItems.isEmpty
                                      ? null
                                      : () => _processCheckout(),
                                  label: 'Proses Pembayaran',
                                  icon: Icons.check,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Pelanggan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SpaceHeight.h16(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        customer.name[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.phone),
                    onTap: () {
                      setState(() => _selectedCustomer = customer);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SpaceHeight.h16(),
            Button.outlined(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Open add customer dialog
              },
              label: 'Tambah Pelanggan Baru',
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSubmitting = false;

  Future<void> _submitToApi(BuildContext dialogContext) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final datasource = getIt<TransactionRemoteDatasource>();
    final items = _cartItems.map((item) {
      final map = <String, dynamic>{
        'item_type': item.isPackage ? 'package' : 'service',
        'item_name': item.name,
        'quantity': item.quantity,
        'unit_price': item.price,
      };
      if (item.isPackage) {
        map['package_id'] = item.serviceId;
      } else {
        map['service_id'] = item.serviceId;
      }
      return map;
    }).toList();

    debugPrint('[Checkout] 🚀 Submitting transaction...');
    debugPrint(
      '[Checkout] Customer: ${_selectedCustomer!.name} (ID: ${_selectedCustomer!.id})',
    );
    debugPrint('[Checkout] Appointment: ${widget.preselectedAppointment?.id}');
    debugPrint('[Checkout] Items: $items');
    debugPrint(
      '[Checkout] Payment: $_paymentMethod, Discount: $_discountAmount, Points: $_pointsToUse',
    );

    final result = await datasource.createTransaction(
      customerId: _selectedCustomer!.id,
      appointmentId: widget.preselectedAppointment?.id,
      items: items,
      discountType: _discountAmount > 0 ? 'fixed' : null,
      discountAmount: _discountAmount > 0 ? _discountAmount.toDouble() : null,
      pointsUsed: _useLoyaltyPoints && _pointsToUse > 0 ? _pointsToUse : null,
    );

    if (!mounted) return;

    await result.fold(
      (error) async {
        setState(() => _isSubmitting = false);
        debugPrint('[Checkout] ❌ Error: $error');
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (transaction) async {
        debugPrint(
          '[Checkout] ✅ Transaction created: ID=${transaction.id}, code=${transaction.invoiceNumber}',
        );

        // Step 2: Record payment
        // Convert payment method to backend format: cash, debit_card, credit_card, transfer, qris, other
        final backendPaymentMethod = _paymentMethod == 'card'
            ? 'debit_card'
            : _paymentMethod;
        final payResult = await datasource.addPayment(
          transaction.id,
          amount: _total.toDouble(),
          paymentMethod: backendPaymentMethod,
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        payResult.fold(
          (error) {
            debugPrint('[Checkout] ⚠️ Payment failed: $error');
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaksi dibuat tapi gagal bayar: $error'),
                backgroundColor: AppColors.warning,
              ),
            );
          },
          (paidTransaction) {
            debugPrint(
              '[Checkout] ✅ Payment recorded: status=${paidTransaction.status}',
            );
            Navigator.pop(dialogContext);
            _showSuccessDialog();
          },
        );
      },
    );
  }

  void _processCheckout() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih pelanggan terlebih dahulu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Show confirmation dialog first
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 450,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SpaceWidth.w12(),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Periksa kembali pesanan Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer info
                      const Text(
                        'Pelanggan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SpaceHeight.h8(),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                _selectedCustomer!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SpaceWidth.w12(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _selectedCustomer!.phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SpaceHeight.h20(),

                      // Order items
                      Row(
                        children: [
                          const Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_cartItems.length} item',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SpaceHeight.h8(),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: List.generate(_cartItems.length, (index) {
                            final item = _cartItems[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: index < _cartItems.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: item.isPackage
                                          ? AppColors.secondary.withValues(
                                              alpha: 0.1,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item.isPackage
                                          ? Icons.card_giftcard
                                          : Icons.spa,
                                      size: 18,
                                      color: item.isPackage
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SpaceWidth.w12(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (item.isPackage) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Paket',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.secondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (item.isProduct) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.info
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Produk',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.info,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.quantity}x ${item.price.currencyFormat}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (item.price * item.quantity).currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      const SpaceHeight.h20(),

                      // Payment summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Payment method
                            Row(
                              children: [
                                const Text(
                                  'Metode Pembayaran',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _paymentMethod == 'cash'
                                            ? Icons.payments
                                            : _paymentMethod == 'card'
                                            ? Icons.credit_card
                                            : Icons.qr_code,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _paymentMethod == 'cash'
                                            ? 'Cash'
                                            : _paymentMethod == 'card'
                                            ? 'Kartu'
                                            : 'QRIS',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SpaceHeight.h12(),

                            // Subtotal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _subtotal.currencyFormat,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_discountAmount > 0) ...[
                              const SpaceHeight.h8(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Diskon',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    '- ${_discountAmount.currencyFormat}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_pointsDiscount > 0) ...[
                              const SpaceHeight.h8(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Poin ($_pointsToUse)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  Text(
                                    '- ${_pointsDiscount.currencyFormat}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SpaceHeight.h12(),
                            const Divider(height: 1),
                            const SpaceHeight.h12(),

                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _total.currencyFormat,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
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
                      flex: 2,
                      child: Button.filled(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitToApi(context),
                        label: _isSubmitting
                            ? 'Memproses...'
                            : 'Konfirmasi Pembayaran',
                        icon: _isSubmitting
                            ? Icons.hourglass_empty
                            : Icons.check,
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

  Future<void> _printReceipt({
    required String transactionId,
    required String paymentMethod,
  }) async {
    final printerService = PrinterService();
    final isConnected = await printerService.checkConnection();

    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Printer belum terhubung. Buka Pengaturan > Printer & Struk.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

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

    // Map cart items to print items
    final printItems = _cartItems
        .map(
          (item) => PrintReceiptItem(
            name: item.name,
            itemType: item.isPackage ? 'package' : 'service',
            qty: item.quantity,
            unitPrice: item.price.toDouble(),
            subtotal: (item.price * item.quantity).toDouble(),
          ),
        )
        .toList();

    // Map payment
    final payments = [
      PrintPaymentInfo(
        method: paymentMethod == 'card' ? 'debit_card' : paymentMethod,
        amount: _total.toDouble(),
      ),
    ];

    final success = await printerService.printReceipt(
      invoiceNumber: transactionId,
      transactionDate: DateTime.now(),
      items: printItems,
      subtotal: _subtotal.toDouble(),
      discountAmount: _discountAmount.toDouble(),
      discountLabel: 'Diskon',
      pointsUsed: _useLoyaltyPoints && _pointsToUse > 0 ? _pointsToUse : null,
      pointsDiscount: _pointsDiscount.toDouble(),
      totalAmount: _total.toDouble(),
      payments: payments,
      cashierName: cashierName,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    final totalAmount = _total;
    final customerName = _selectedCustomer!.name;
    final itemCount = _cartItems.length;
    final paymentMethod = _paymentMethod;
    final transactionId =
        'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 400,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success.withValues(alpha: 0.2),
                        AppColors.success.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SpaceHeight.h16(),

                // Success text
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SpaceHeight.h8(),
                Text(
                  'Transaksi telah selesai diproses',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SpaceHeight.h24(),

                // Transaction details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Total amount
                      Text(
                        totalAmount.currencyFormat,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SpaceHeight.h16(),
                      const Divider(height: 1),
                      const SpaceHeight.h16(),

                      // Transaction info rows
                      _buildInfoRow('No. Transaksi', transactionId),
                      const SpaceHeight.h12(),
                      _buildInfoRow('Pelanggan', customerName),
                      const SpaceHeight.h12(),
                      _buildInfoRow('Jumlah Item', '$itemCount item'),
                      const SpaceHeight.h12(),
                      _buildInfoRow(
                        'Metode Bayar',
                        paymentMethod == 'cash'
                            ? 'Cash'
                            : paymentMethod == 'card'
                            ? 'Kartu Debit/Kredit'
                            : 'QRIS',
                      ),
                      const SpaceHeight.h12(),
                      _buildInfoRow(
                        'Waktu',
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                const SpaceHeight.h24(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Button.outlined(
                        onPressed: () {
                          _printReceipt(
                            transactionId: transactionId,
                            paymentMethod: paymentMethod,
                          );
                        },
                        label: 'Cetak Struk',
                        icon: Icons.print,
                      ),
                    ),
                    const SpaceWidth.w12(),
                    Expanded(
                      child: Button.filled(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // Rendered inline from sidebar, reset state
                            setState(() {
                              _cartItems = [];
                              _selectedCustomer = null;
                              _paymentMethod = 'cash';
                              _discountAmount = 0;
                              _customerLoyaltyPoints = 0;
                              _useLoyaltyPoints = false;
                              _pointsToUse = 0;
                              _pointsController.clear();
                            });
                          }
                        },
                        label: 'Selesai',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Phone Layout - Full Implementation
class _CheckoutPhoneLayout extends StatefulWidget {
  final AppointmentModel? preselectedAppointment;
  final TransactionModel? existingTransaction;

  const _CheckoutPhoneLayout({
    this.preselectedAppointment,
    this.existingTransaction,
  });

  @override
  State<_CheckoutPhoneLayout> createState() => _CheckoutPhoneLayoutState();
}

class _CheckoutPhoneLayoutState extends State<_CheckoutPhoneLayout> {
  List<CartItem> _cartItems = [];
  CustomerInfo? _selectedCustomer;
  String _paymentMethod = 'cash';
  int _discountAmount = 0;
  String _searchQuery = '';
  int _selectedTab = 0; // 0 = Layanan, 1 = Paket, 2 = Produk

  // Loyalty points
  int _customerLoyaltyPoints = 0;
  bool _useLoyaltyPoints = false;
  int _pointsToUse = 0;
  static const int _pointsValue = 100; // 1 poin = Rp 100
  static const int _minPointsRedeem = 10;
  final _pointsController = TextEditingController();

  // API data
  List<ServiceItem> _services = [];
  List<PackageItem> _packages = [];
  List<ProductItem> _products = [];
  List<CustomerInfo> _customers = [];
  List<PaymentMethodInfo> _paymentMethods = [];
  bool _isLoadingData = true;
  bool _isLoadingPoints = false;

  @override
  void initState() {
    super.initState();
    _initFromAppointment();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    await Future.wait([
      _loadServices(),
      _loadPackages(),
      _loadProducts(),
      _loadCustomers(),
      _loadPaymentMethods(),
    ]);

    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _loadServices() async {
    final datasource = getIt<ServiceRemoteDatasource>();
    final result = await datasource.getServices();
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout-Phone] Failed to load services: $error'),
      (services) {
        setState(() {
          _services = services
              .where((s) => s.isActive)
              .map(
                (s) => ServiceItem(
                  id: s.id,
                  name: s.name,
                  category: s.category?.name ?? 'Umum',
                  price: s.price,
                  duration: s.durationMinutes,
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadPackages() async {
    final datasource = getIt<PackageRemoteDatasource>();
    final result = await datasource.getPackages();
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout-Phone] Failed to load packages: $error'),
      (packages) {
        setState(() {
          _packages = packages
              .where((p) => p.isActive)
              .map(
                (p) => PackageItem(
                  id: p.id,
                  name: p.name,
                  price: p.packagePrice.toInt(),
                  originalPrice: p.originalPrice.toInt(),
                  sessions: p.totalSessions,
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadProducts() async {
    final datasource = getIt<ProductRemoteDatasource>();
    final result = await datasource.getProducts(perPage: 100);
    if (!mounted) return;
    result.fold(
      (error) => debugPrint('[Checkout-Phone] Failed to load products: $error'),
      (response) {
        setState(() {
          _products = response.data
              .where((p) => p.isActive && !p.isOutOfStock)
              .map(
                (p) => ProductItem(
                  id: p.id,
                  name: p.name,
                  category: p.category?.name ?? 'Umum',
                  price: p.price.toInt(),
                  stock: p.stock,
                  unit: p.unit ?? 'pcs',
                ),
              )
              .toList();
        });
      },
    );
  }

  Future<void> _loadCustomers() async {
    final datasource = getIt<CustomerRemoteDatasource>();
    final result = await datasource.getCustomers(perPage: 100);
    if (!mounted) return;
    result.fold(
      (error) =>
          debugPrint('[Checkout-Phone] Failed to load customers: $error'),
      (customers) {
        setState(() {
          _customers = customers
              .map((c) => CustomerInfo(id: c.id, name: c.name, phone: c.phone))
              .toList();
        });
      },
    );
  }

  Future<void> _loadPaymentMethods() async {
    final authLocal = AuthLocalDatasource();
    final api = ApiService(authLocal: authLocal);
    final result = await api.get('/settings/payment-methods');
    if (!mounted) return;
    result.fold(
      (error) {
        debugPrint('[Checkout-Phone] Failed to load payment methods: $error');
        // Use default payment methods if API fails
        setState(() {
          _paymentMethods = [
            PaymentMethodInfo(
              key: 'cash',
              label: 'Cash',
              description: 'Pembayaran tunai',
              icon: 'payments',
            ),
            PaymentMethodInfo(
              key: 'debit_card',
              label: 'Kartu',
              description: 'Debit/Kredit',
              icon: 'credit_card',
            ),
            PaymentMethodInfo(
              key: 'qris',
              label: 'QRIS',
              description: 'Scan QR',
              icon: 'qr_code',
            ),
          ];
        });
      },
      (data) {
        final methods = (data['data'] as List?) ?? [];
        setState(() {
          _paymentMethods = methods
              .map(
                (m) => PaymentMethodInfo(
                  key: m['key'] ?? '',
                  label: m['label'] ?? '',
                  description: m['description'] ?? '',
                  icon: m['icon'] ?? 'payments',
                ),
              )
              .toList();
          // Set default payment method to first one if available
          if (_paymentMethods.isNotEmpty) {
            _paymentMethod = _paymentMethods.first.key;
          }
        });
      },
    );
  }

  void _initFromAppointment() {
    if (widget.preselectedAppointment != null) {
      final apt = widget.preselectedAppointment!;
      // Set customer
      if (apt.customer != null) {
        _selectedCustomer = CustomerInfo(
          id: apt.customer!.id,
          name: apt.customer!.name,
          phone: apt.customer!.phone,
        );
        // Load loyalty points for preselected customer
        _loadCustomerLoyaltyPoints(apt.customer!.id);
      }
      // Add service to cart
      if (apt.service != null) {
        _cartItems = [
          CartItem(
            serviceId: apt.service!.id,
            name: apt.service!.name,
            price: apt.service!.price,
            quantity: 1,
            isPackage: false,
          ),
        ];
      }
    }
  }

  Future<void> _loadCustomerLoyaltyPoints(int customerId) async {
    setState(() => _isLoadingPoints = true);

    final authLocal = AuthLocalDatasource();
    final api = ApiService(authLocal: authLocal);

    final result = await api.get('/customers/$customerId');

    if (!mounted) return;

    result.fold(
      (error) {
        debugPrint('[Checkout-Phone] Failed to load customer points: $error');
        setState(() {
          _customerLoyaltyPoints = 0;
          _isLoadingPoints = false;
        });
      },
      (data) {
        final points = data['data']?['loyalty_points'] ?? 0;
        setState(() {
          _customerLoyaltyPoints = points is int
              ? points
              : int.tryParse(points.toString()) ?? 0;
          _isLoadingPoints = false;
          // Reset points usage when customer changes
          _useLoyaltyPoints = false;
          _pointsToUse = 0;
          _pointsController.clear();
        });
        debugPrint(
          '[Checkout-Phone] Customer loyalty points: $_customerLoyaltyPoints',
        );
      },
    );
  }

  int get _maxPointsToUse {
    final maxBySubtotal = ((_subtotal - _discountAmount) / _pointsValue)
        .floor();
    return _customerLoyaltyPoints < maxBySubtotal
        ? _customerLoyaltyPoints
        : maxBySubtotal;
  }

  int get _pointsDiscount {
    if (!_useLoyaltyPoints || _pointsToUse <= 0) return 0;
    return _pointsToUse * _pointsValue;
  }

  List<ServiceItem> get _filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services
        .where(
          (s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<PackageItem> get _filteredPackages {
    if (_searchQuery.isEmpty) return _packages;
    return _packages
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ProductItem> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  int get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get _total => _subtotal - _discountAmount - _pointsDiscount;
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(ServiceItem service) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) =>
            item.serviceId == service.id && !item.isPackage && !item.isProduct,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItem(
            serviceId: service.id,
            name: service.name,
            price: service.price,
            quantity: 1,
            isPackage: false,
            isProduct: false,
          ),
        );
      }
    });
  }

  void _addPackageToCart(PackageItem package) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.serviceId == package.id && item.isPackage,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(
          CartItem(
            serviceId: package.id,
            name: package.name,
            price: package.price,
            quantity: 1,
            isPackage: true,
            isProduct: false,
          ),
        );
      }
    });
  }

  void _addProductToCart(ProductItem product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.serviceId == product.id && item.isProduct,
      );
      if (existingIndex >= 0) {
        // Check stock limit
        if (_cartItems[existingIndex].quantity < product.stock) {
          _cartItems[existingIndex].quantity++;
        }
      } else {
        _cartItems.add(
          CartItem(
            serviceId: product.id,
            name: product.name,
            price: product.price,
            quantity: 1,
            isPackage: false,
            isProduct: true,
          ),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName) {
      case 'payments':
        return Icons.payments;
      case 'credit_card':
        return Icons.credit_card;
      case 'qr_code':
        return Icons.qr_code;
      case 'account_balance':
        return Icons.account_balance;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: _showCartBottomSheet,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Selector + Search
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Tab Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _PhoneTabButton(
                            icon: Icons.spa,
                            label: 'Layanan',
                            isSelected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PhoneTabButton(
                            icon: Icons.card_giftcard,
                            label: 'Paket',
                            isSelected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PhoneTabButton(
                            icon: Icons.inventory_2,
                            label: 'Produk',
                            isSelected: _selectedTab == 2,
                            onTap: () => setState(() => _selectedTab = 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search Bar
                    SearchInput(
                      hint: _selectedTab == 0
                          ? 'Cari layanan...'
                          : _selectedTab == 1
                          ? 'Cari paket...'
                          : 'Cari produk...',
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ],
                ),
              ),

              // Services/Packages/Products Grid
              Expanded(
                child: _selectedTab == 0
                    ? _buildServicesGrid()
                    : _selectedTab == 1
                    ? _buildPackagesGrid()
                    : _buildProductsGrid(),
              ),
            ],
          ),

          // Floating Cart Button
          if (_cartItems.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildFloatingCartButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Layanan tidak ditemukan',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: _cartItems.isNotEmpty ? 100 : 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _PhoneServiceCard(
          service: service,
          onTap: () => _addToCart(service),
        );
      },
    );
  }

  Widget _buildPackagesGrid() {
    if (_filteredPackages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paket tidak ditemukan',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: _cartItems.isNotEmpty ? 100 : 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _filteredPackages.length,
      itemBuilder: (context, index) {
        final package = _filteredPackages[index];
        return _PhonePackageCard(
          package: package,
          onTap: () => _addPackageToCart(package),
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Produk tidak ditemukan',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: _cartItems.isNotEmpty ? 100 : 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _PhoneProductCard(
          product: product,
          onTap: () => _addProductToCart(product),
        );
      },
    );
  }

  Widget _buildFloatingCartButton() {
    return GestureDetector(
      onTap: () => _showCartBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_totalItems',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Lihat Keranjang',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              _subtotal.currencyFormat,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Keranjang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_cartItems.length} item',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_cartItems.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() => _cartItems.clear());
                            setModalState(() {});
                          },
                          child: const Text(
                            'Hapus Semua',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Customer Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showCustomerPicker(setModalState),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _selectedCustomer != null
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedCustomer != null
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: _selectedCustomer != null
                                ? AppColors.primary
                                : AppColors.textMuted.withValues(alpha: 0.2),
                            child: _selectedCustomer != null
                                ? Text(
                                    _selectedCustomer!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedCustomer?.name ?? 'Pilih Pelanggan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedCustomer != null
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _selectedCustomer != null
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                  ),
                                ),
                                if (_selectedCustomer != null)
                                  Text(
                                    _selectedCustomer!.phone,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cart Items
                Expanded(
                  child: _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart,
                                size: 64,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Keranjang kosong',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pilih layanan atau paket untuk ditambahkan',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _cartItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return _PhoneCartItem(
                              item: item,
                              onQuantityChanged: (delta) {
                                _updateQuantity(index, delta);
                                setModalState(() {});
                              },
                              onRemove: () {
                                _removeFromCart(index);
                                setModalState(() {});
                                if (_cartItems.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        ),
                ),

                // Bottom Section
                if (_cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Loyalty Points (show only if customer has points)
                        if (_customerLoyaltyPoints > 0 &&
                            _customerLoyaltyPoints >= _minPointsRedeem) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 18,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Poin Tersedia: $_customerLoyaltyPoints',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber[800],
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: _useLoyaltyPoints,
                                      onChanged: (value) {
                                        setState(() {
                                          _useLoyaltyPoints = value;
                                          if (value) {
                                            _pointsToUse = _maxPointsToUse;
                                            _pointsController.text =
                                                _pointsToUse.toString();
                                          } else {
                                            _pointsToUse = 0;
                                            _pointsController.clear();
                                          }
                                        });
                                        setModalState(() {});
                                      },
                                      activeColor: Colors.amber[700],
                                    ),
                                  ],
                                ),
                                if (_useLoyaltyPoints) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _pointsController,
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            hintText: 'Jumlah poin',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.amber[300]!,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.amber[600]!,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            int parsed =
                                                int.tryParse(value) ?? 0;
                                            if (parsed > _maxPointsToUse)
                                              parsed = _maxPointsToUse;
                                            if (parsed < 0) parsed = 0;
                                            setState(
                                              () => _pointsToUse = parsed,
                                            );
                                            setModalState(() {});
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _pointsToUse = _maxPointsToUse;
                                            _pointsController.text =
                                                _maxPointsToUse.toString();
                                          });
                                          setModalState(() {});
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.amber[800],
                                        ),
                                        child: const Text(
                                          'Maks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_pointsToUse > 0) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '$_pointsToUse poin = ${_pointsDiscount.currencyFormat}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Discount Input
                        Row(
                          children: [
                            const Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 140,
                              height: 40,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  prefixText: 'Rp ',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _discountAmount =
                                        int.tryParse(
                                          value.replaceAll('.', ''),
                                        ) ??
                                        0;
                                  });
                                  setModalState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Payment Method
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final method in _paymentMethods)
                              _PhonePaymentOption(
                                icon: _getPaymentIcon(method.icon),
                                label: method.label,
                                isSelected: _paymentMethod == method.key,
                                onTap: () {
                                  setState(() => _paymentMethod = method.key);
                                  setModalState(() {});
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Subtotal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _subtotal.currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              if (_discountAmount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Diskon',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      '- ${_discountAmount.currencyFormat}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_pointsDiscount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Poin ($_pointsToUse)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                    Text(
                                      '- ${_pointsDiscount.currencyFormat}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.amber[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _total.currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Checkout Button
                        Button.filled(
                          onPressed: () {
                            Navigator.pop(context);
                            _processCheckout();
                          },
                          label: 'Proses Pembayaran',
                          icon: Icons.check,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerPicker(StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Pelanggan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          customer.name[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(customer.name),
                      subtitle: Text(customer.phone),
                      trailing: _selectedCustomer?.id == customer.id
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedCustomer = customer);
                        setModalState(() {});
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Button.outlined(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Open add customer dialog
                },
                label: 'Tambah Pelanggan Baru',
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSubmitting = false;

  Future<void> _submitToApi(BuildContext dialogContext) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final datasource = getIt<TransactionRemoteDatasource>();
    final items = _cartItems.map((item) {
      final map = <String, dynamic>{
        'item_type': item.isPackage ? 'package' : 'service',
        'item_name': item.name,
        'quantity': item.quantity,
        'unit_price': item.price,
      };
      if (item.isPackage) {
        map['package_id'] = item.serviceId;
      } else {
        map['service_id'] = item.serviceId;
      }
      return map;
    }).toList();

    debugPrint('[Checkout-Phone] 🚀 Submitting transaction...');
    debugPrint(
      '[Checkout-Phone] Customer: ${_selectedCustomer!.name} (ID: ${_selectedCustomer!.id})',
    );
    debugPrint(
      '[Checkout-Phone] Appointment: ${widget.preselectedAppointment?.id}',
    );
    debugPrint('[Checkout-Phone] Items: $items');
    debugPrint(
      '[Checkout-Phone] Payment: $_paymentMethod, Discount: $_discountAmount, Points: $_pointsToUse',
    );

    final result = await datasource.createTransaction(
      customerId: _selectedCustomer!.id,
      appointmentId: widget.preselectedAppointment?.id,
      items: items,
      discountType: _discountAmount > 0 ? 'fixed' : null,
      discountAmount: _discountAmount > 0 ? _discountAmount.toDouble() : null,
      pointsUsed: _useLoyaltyPoints && _pointsToUse > 0 ? _pointsToUse : null,
    );

    if (!mounted) return;

    await result.fold(
      (error) async {
        setState(() => _isSubmitting = false);
        debugPrint('[Checkout-Phone] ❌ Error: $error');
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (transaction) async {
        debugPrint(
          '[Checkout-Phone] ✅ Transaction created: ID=${transaction.id}, code=${transaction.invoiceNumber}',
        );

        // Step 2: Record payment
        // Convert payment method to backend format: cash, debit_card, credit_card, transfer, qris, other
        final backendPaymentMethod = _paymentMethod == 'card'
            ? 'debit_card'
            : _paymentMethod;
        final payResult = await datasource.addPayment(
          transaction.id,
          amount: _total.toDouble(),
          paymentMethod: backendPaymentMethod,
        );

        if (!mounted) return;
        setState(() => _isSubmitting = false);

        payResult.fold(
          (error) {
            debugPrint('[Checkout-Phone] ⚠️ Payment failed: $error');
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaksi dibuat tapi gagal bayar: $error'),
                backgroundColor: AppColors.warning,
              ),
            );
          },
          (paidTransaction) {
            debugPrint(
              '[Checkout-Phone] ✅ Payment recorded: status=${paidTransaction.status}',
            );
            Navigator.pop(dialogContext);
            _showSuccessDialog();
          },
        );
      },
    );
  }

  void _processCheckout() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih pelanggan terlebih dahulu'),
          backgroundColor: AppColors.warning,
        ),
      );
      _showCartBottomSheet();
      return;
    }

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Container(
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi Pembayaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Periksa kembali pesanan Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer info
                      const Text(
                        'Pelanggan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                _selectedCustomer!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _selectedCustomer!.phone,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order items
                      Row(
                        children: [
                          const Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_cartItems.length} item',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: List.generate(_cartItems.length, (index) {
                            final item = _cartItems[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: index < _cartItems.length - 1
                                    ? const Border(
                                        bottom: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: item.isPackage
                                          ? AppColors.secondary.withValues(
                                              alpha: 0.1,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      item.isPackage
                                          ? Icons.card_giftcard
                                          : Icons.spa,
                                      size: 16,
                                      color: item.isPackage
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${item.quantity}x ${item.price.currencyFormat}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (item.price * item.quantity).currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Payment method
                            Row(
                              children: [
                                const Text(
                                  'Metode Pembayaran',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _paymentMethod == 'cash'
                                      ? Icons.payments
                                      : _paymentMethod == 'card'
                                      ? Icons.credit_card
                                      : Icons.qr_code,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _paymentMethod == 'cash'
                                      ? 'Cash'
                                      : _paymentMethod == 'card'
                                      ? 'Kartu'
                                      : 'QRIS',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    _subtotal.currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            if (_discountAmount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Diskon',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '- ${_discountAmount.currencyFormat}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_pointsDiscount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Poin ($_pointsToUse)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '- ${_pointsDiscount.currencyFormat}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.amber[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    _total.currencyFormat,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Button.outlined(
                        onPressed: () => Navigator.pop(context),
                        label: 'Batal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Button.filled(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitToApi(context),
                        label: _isSubmitting ? 'Memproses...' : 'Konfirmasi',
                        icon: _isSubmitting
                            ? Icons.hourglass_empty
                            : Icons.check,
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

  void _showSuccessDialog() {
    final totalAmount = _total;
    final customerName = _selectedCustomer!.name;
    final itemCount = _cartItems.length;
    final paymentMethod = _paymentMethod;
    final transactionId =
        'TRX${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withValues(alpha: 0.2),
                      AppColors.success.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Transaksi telah selesai diproses',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Transaction details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      totalAmount.currencyFormat,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildPhoneInfoRow('No. Transaksi', transactionId),
                    const SizedBox(height: 8),
                    _buildPhoneInfoRow('Pelanggan', customerName),
                    const SizedBox(height: 8),
                    _buildPhoneInfoRow('Jumlah Item', '$itemCount item'),
                    const SizedBox(height: 8),
                    _buildPhoneInfoRow(
                      'Metode Bayar',
                      paymentMethod == 'cash'
                          ? 'Cash'
                          : paymentMethod == 'card'
                          ? 'Kartu'
                          : 'QRIS',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: Button.outlined(
                      onPressed: () {
                        _printReceipt(
                          transactionId: transactionId,
                          paymentMethod: paymentMethod,
                        );
                      },
                      label: 'Cetak Struk',
                      icon: Icons.print,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Button.filled(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          // Rendered inline from sidebar, reset state
                          setState(() {
                            _cartItems = [];
                            _selectedCustomer = null;
                            _paymentMethod = 'cash';
                            _discountAmount = 0;
                            _customerLoyaltyPoints = 0;
                            _useLoyaltyPoints = false;
                            _pointsToUse = 0;
                            _pointsController.clear();
                          });
                        }
                      },
                      label: 'Selesai',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printReceipt({
    required String transactionId,
    required String paymentMethod,
  }) async {
    final printerService = PrinterService();
    final isConnected = await printerService.checkConnection();

    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Printer belum terhubung. Buka Pengaturan > Printer & Struk.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mencetak struk...'),
          backgroundColor: AppColors.info,
        ),
      );
    }

    final user = await AuthLocalDatasource().getUser();
    final cashierName = user?.name ?? 'Kasir';

    final printItems = _cartItems
        .map(
          (item) => PrintReceiptItem(
            name: item.name,
            itemType: item.isPackage ? 'package' : 'service',
            qty: item.quantity,
            unitPrice: item.price.toDouble(),
            subtotal: (item.price * item.quantity).toDouble(),
          ),
        )
        .toList();

    final payments = [
      PrintPaymentInfo(
        method: paymentMethod == 'card' ? 'debit_card' : paymentMethod,
        amount: _total.toDouble(),
      ),
    ];

    final success = await printerService.printReceipt(
      invoiceNumber: transactionId,
      transactionDate: DateTime.now(),
      items: printItems,
      subtotal: _subtotal.toDouble(),
      discountAmount: _discountAmount.toDouble(),
      discountLabel: 'Diskon',
      pointsUsed: _useLoyaltyPoints && _pointsToUse > 0 ? _pointsToUse : null,
      pointsDiscount: _pointsDiscount.toDouble(),
      totalAmount: _total.toDouble(),
      payments: payments,
      cashierName: cashierName,
      customerName: _selectedCustomer?.name,
      customerPhone: _selectedCustomer?.phone,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Struk berhasil dicetak!' : 'Gagal mencetak struk.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Widget _buildPhoneInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Phone-specific Widgets
class _PhoneTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhoneTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneServiceCard extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const _PhoneServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Duration
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${service.duration}m',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Name
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Price
              Text(
                service.price.currencyFormat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhonePackageCard extends StatelessWidget {
  final PackageItem package;
  final VoidCallback onTap;

  const _PhonePackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discount =
        ((package.originalPrice - package.price) / package.originalPrice * 100)
            .round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Discount
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-$discount%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Name
              Text(
                package.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Sessions
              Text(
                '${package.sessions} sesi',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                package.price.currencyFormat,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;

  const _PhoneProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Stock
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: AppColors.info,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Stok: ${product.stock}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Name
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Price
              Text(
                product.price.currencyFormat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneCartItem extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _PhoneCartItem({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.isProduct
                  ? AppColors.info.withValues(alpha: 0.1)
                  : item.isPackage
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.isProduct
                  ? Icons.inventory_2
                  : item.isPackage
                  ? Icons.card_giftcard
                  : Icons.spa,
              color: item.isProduct
                  ? AppColors.info
                  : item.isPackage
                  ? AppColors.secondary
                  : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isPackage) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Paket',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                    if (item.isProduct) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Produk',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.price.currencyFormat,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(-1),
                  icon: const Icon(Icons.remove, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(1),
                  icon: const Icon(Icons.add, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.error,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _PhonePaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhonePaymentOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceItem service;
  final VoidCallback onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${service.duration}m',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.price.currencyFormat,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
}

class _ProductTile extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: AppColors.info,
                    size: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Stok: ${product.stock}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.price.currencyFormat,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isPackage) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Paket',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                    if (item.isProduct) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Produk',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.price.currencyFormat,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => onQuantityChanged(-1),
                  icon: const Icon(Icons.remove, size: 16),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onQuantityChanged(1),
                  icon: const Icon(Icons.add, size: 16),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SpaceWidth.w12(),
          Text(
            (item.price * item.quantity).currencyFormat,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 16, color: AppColors.error),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final PackageItem package;
  final VoidCallback onTap;

  const _PackageTile({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final discount =
        ((package.originalPrice - package.price) / package.originalPrice * 100)
            .round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: AppColors.secondary,
                    size: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-$discount%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${package.sessions} sesi',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.originalPrice.currencyFormat,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        package.price.currencyFormat,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class ServiceItem {
  final int id;
  final String name;
  final String category;
  final int price;
  final int duration;

  ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
  });
}

class CartItem {
  final int serviceId;
  final String name;
  final int price;
  final bool isPackage;
  final bool isProduct;
  int quantity;

  CartItem({
    required this.serviceId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.isPackage = false,
    this.isProduct = false,
  });
}

class PackageItem {
  final int id;
  final String name;
  final int price;
  final int originalPrice;
  final int sessions;

  PackageItem({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.sessions,
  });
}

class ProductItem {
  final int id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String unit;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
  });
}

class CustomerInfo {
  final int id;
  final String name;
  final String phone;

  CustomerInfo({required this.id, required this.name, required this.phone});
}

class PaymentMethodInfo {
  final String key;
  final String label;
  final String description;
  final String icon;

  PaymentMethodInfo({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}
