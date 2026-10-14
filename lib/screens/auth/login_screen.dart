import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/brand_logo.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    GlobalLoader.show(
      message: 'Signing in to JewelOra...',
      subMessage: 'Verifying your credentials',
    );
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // On success, AuthGate switches the screen automatically.
      if (!ok && mounted) {
        showAppSnackBar(
          context,
          auth.errorMessage ?? AppStrings.somethingWentWrong,
          isError: true,
        );
      }
    } finally {
      GlobalLoader.hide();
    }
  }

  Future<void> _loginWithGoogle() async {
    GlobalLoader.show(
      message: 'Connecting with Google...',
      subMessage: 'Opening secure Google authentication',
    );
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.signInWithGoogle();
      if (!ok && mounted) {
        if (auth.errorMessage != null &&
            !auth.errorMessage!.contains('canceled')) {
          showAppSnackBar(
            context,
            auth.errorMessage ?? AppStrings.somethingWentWrong,
            isError: true,
          );
        }
      }
    } finally {
      GlobalLoader.hide();
    }
  }

  Future<void> _forgotPassword() async {
    if (Validators.email(_emailCtrl.text) != null) {
      showAppSnackBar(context, 'Enter your email above first', isError: true);
      return;
    }
    GlobalLoader.show(
      message: 'Sending Reset Link...',
      subMessage: 'Preparing your password recovery email',
    );
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      showAppSnackBar(
        context,
        ok
            ? 'Password reset link sent to your email'
            : (auth.errorMessage ?? AppStrings.somethingWentWrong),
        isError: !ok,
      );
    } finally {
      GlobalLoader.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo = the icon chosen in the Admin panel
                  const Center(child: BrandLogo(size: 96)),
                  const SizedBox(height: 20),

                  // App Title & Tagline
                  Text(
                    settings.appName.isNotEmpty ? settings.appName : AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Fields
                  AppTextField(
                    controller: _emailCtrl,
                    label: AppStrings.email,
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordCtrl,
                    label: AppStrings.password,
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: Validators.password,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login Button
                  AppButton(
                    title: AppStrings.login,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 20),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-In Button
                  _GoogleAuthButton(
                    label: AppStrings.continueWithGoogle,
                    isLoading: isLoading,
                    onPressed: _loginWithGoogle,
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          AppStrings.register,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
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
    );
  }
}

class _GoogleAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleAuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
            height: 20,
            width: 20,
            errorBuilder: (_, error, stack) => const Icon(
              Icons.g_mobiledata_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}