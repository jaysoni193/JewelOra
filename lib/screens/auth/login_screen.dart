import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_images.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/image_url.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
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
  }

  Future<void> _forgotPassword() async {
    if (Validators.email(_emailCtrl.text) != null) {
      showAppSnackBar(context, 'Enter your email above first', isError: true);
      return;
    }
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
                  // Brand Logo / Icon with Halo
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.borderAccent.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: settings.logoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ImageUrl.optimized(settings.logoUrl, width: 250),
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => Image.asset(
                                  AppImages.logo,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                AppImages.logo,
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
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
                  const Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.primaryDark,
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
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
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
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.dontHaveAccount,
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                ),
                        child: const Text(
                          AppStrings.register,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
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