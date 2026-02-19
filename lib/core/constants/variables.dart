class Variables {
  Variables._();

  // Base URL - Ganti dengan URL server production
  // static const String baseUrl = 'https://afc8.jagofullstack.com';
  // static const String baseUrl = 'https://glowup.jagofullstack.com';
  static const String baseUrl = 'http://192.168.1.4:8000';
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // Auth Endpoints
  static const String login = '$apiBaseUrl/login';
  static const String logout = '$apiBaseUrl/logout';
  static const String profile = '$apiBaseUrl/profile';

  // Service Categories & Services
  static const String serviceCategories = '$apiBaseUrl/service-categories';
  static const String services = '$apiBaseUrl/services';

  // Customers
  static const String customers = '$apiBaseUrl/customers';

  // Appointments
  static const String appointments = '$apiBaseUrl/appointments';
  static const String appointmentsToday = '$apiBaseUrl/appointments-today';
  static const String availableSlots =
      '$apiBaseUrl/appointments-available-slots';
  static const String calendar = '$apiBaseUrl/appointments-calendar';

  // Treatment Records
  static const String treatments = '$apiBaseUrl/treatments';

  // Packages
  static const String packages = '$apiBaseUrl/packages';
  static const String customerPackages = '$apiBaseUrl/customer-packages';

  // Transactions
  static const String transactions = '$apiBaseUrl/transactions';

  // Dashboard
  static const String dashboard = '$apiBaseUrl/dashboard';
  static const String dashboardSummary = '$apiBaseUrl/dashboard/summary';

  // Reports
  static const String reports = '$apiBaseUrl/reports';
  static const String reportsRevenue = '$apiBaseUrl/reports/revenue';
  static const String reportsServices = '$apiBaseUrl/reports/services';
  static const String reportsCustomers = '$apiBaseUrl/reports/customers';
  static const String reportsStaff = '$apiBaseUrl/reports/staff';

  // Staff
  static const String staff = '$apiBaseUrl/staff';
  static const String beauticians = '$apiBaseUrl/staff/beauticians';

  // Settings
  static const String settings = '$apiBaseUrl/settings';
  static const String settingsBranding = '$apiBaseUrl/settings/branding';

  // Loyalty
  static const String loyaltyRewards = '$apiBaseUrl/loyalty/rewards';
  static const String loyaltyRedemptions = '$apiBaseUrl/loyalty/redemptions';
  static const String loyaltyCheckCode = '$apiBaseUrl/loyalty/check-code';
  static const String loyaltyUseCode = '$apiBaseUrl/loyalty/use-code';

  // Referral
  static const String referralValidate = '$apiBaseUrl/referral/validate';
  static const String referralProgram = '$apiBaseUrl/referral/program-info';

  // Products
  static const String productCategories = '$apiBaseUrl/product-categories';
  static const String products = '$apiBaseUrl/products';
}
