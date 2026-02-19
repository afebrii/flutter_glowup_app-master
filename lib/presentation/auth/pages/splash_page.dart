import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../home/pages/home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final isLoggedIn = await AuthLocalDatasource().isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return isLoggedIn ? const HomePage() : const LoginPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ResponsiveWidget(
        phone: _SplashPhoneLayout(
          animationController: _animationController,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
        ),
        tablet: _SplashTabletLayout(
          animationController: _animationController,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
        ),
      ),
    );
  }
}

// Phone Layout - Centered content
class _SplashPhoneLayout extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _SplashPhoneLayout({
    required this.animationController,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: fadeAnimation.value,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  const Text(
                    'GlowUp',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Clinic Management',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Loading indicator
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Tablet Layout - Split screen with branding
class _SplashTabletLayout extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _SplashTabletLayout({
    required this.animationController,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Branding (50%)
        Expanded(
          flex: 50,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: fadeAnimation.value,
                    child: Transform.scale(
                      scale: scaleAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.spa, size: 60, color: AppColors.primary),
                                ),
                                const SizedBox(height: 40),
                                // Title
                                const Text(
                                  'GlowUp Clinic',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sistem manajemen klinik kecantikan yang membantu Anda mengelola operasional klinik dengan lebih efisien.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Features
                                _buildFeatureItem(Icons.calendar_today, 'Manajemen Appointment'),
                                const SizedBox(height: 16),
                                _buildFeatureItem(Icons.people, 'Database Pelanggan'),
                                const SizedBox(height: 16),
                                _buildFeatureItem(Icons.receipt_long, 'Point of Sale'),
                                const SizedBox(height: 16),
                                _buildFeatureItem(Icons.bar_chart, 'Laporan & Analitik'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Right Panel - Loading (50%)
        Expanded(
          flex: 50,
          child: Container(
            color: AppColors.background,
            child: Center(
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: fadeAnimation.value,
                    child: Transform.scale(
                      scale: scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo for right panel
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.spa,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Memuat...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Loading indicator
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            'GlowUp Clinic v1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
