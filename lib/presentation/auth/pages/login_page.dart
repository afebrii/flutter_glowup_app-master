import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/widgets/responsive_widget.dart';
import '../../home/pages/home_page.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return ResponsiveWidget(
            phone: _LoginPhoneLayout(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              onLogin: _handleLogin,
              isLoading: state is LoginLoading,
            ),
            tablet: _LoginTabletLayout(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              onLogin: _handleLogin,
              isLoading: state is LoginLoading,
            ),
          );
        },
      ),
    );
  }
}

// Phone Layout
class _LoginPhoneLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final bool isLoading;

  const _LoginPhoneLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Title
                _buildHeader(),
                const SpaceHeight.h48(),

                // Login Form
                _buildEmailField(),
                const SpaceHeight.h16(),
                _buildPasswordField(),
                const SpaceHeight.h24(),

                // Login Button
                Button.filled(
                  onPressed: isLoading ? null : onLogin,
                  label: 'Masuk',
                  isLoading: isLoading,
                ),
                const SpaceHeight.h24(),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.spa, size: 40, color: Colors.white),
        ),
        const SpaceHeight.h24(),
        const Text(
          'GlowUp Clinic',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SpaceHeight.h8(),
        const Text(
          'Selamat datang kembali',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: emailController,
      label: 'Email',
      hint: 'Masukkan email Anda',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIconData: Icons.email_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
        if (!value.contains('@')) return 'Email tidak valid';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: passwordController,
      label: 'Password',
      hint: 'Masukkan password Anda',
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      prefixIconData: Icons.lock_outline,
      suffixIconData: obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      onSuffixIconTap: onTogglePassword,
      onSubmitted: (_) => onLogin(),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
        if (value.length < 6) return 'Password minimal 6 karakter';
        return null;
      },
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'Hubungi admin jika lupa password',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        SpaceHeight.h8(),
        Text(
          'GlowUp Clinic v1.0.0',
          style: TextStyle(fontSize: 12, color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Tablet Layout
class _LoginTabletLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final bool isLoading;

  const _LoginTabletLayout({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Panel - Branding (50%)
        Expanded(
          flex: 50,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
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
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.spa, size: 50, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          'GlowUp Clinic',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
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
          ),
        ),

        // Right Panel - Login Form (50%)
        Expanded(
          flex: 50,
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masuk ke akun Anda untuk melanjutkan',
                            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 48),

                          // Email Field
                          CustomTextField(
                            controller: emailController,
                            label: 'Email',
                            hint: 'Masukkan email Anda',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIconData: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                              if (!value.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            controller: passwordController,
                            label: 'Password',
                            hint: 'Masukkan password Anda',
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIconData: Icons.lock_outline,
                            suffixIconData: obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            onSuffixIconTap: onTogglePassword,
                            onSubmitted: (_) => onLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                              if (value.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Lupa password?',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            height: 52,
                            child: Button.filled(
                              onPressed: isLoading ? null : onLogin,
                              label: 'Masuk',
                              isLoading: isLoading,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Butuh bantuan? ',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Hubungi Admin',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
