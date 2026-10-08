import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      // Remove this screen so AuthGate (the first route) becomes visible.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      showAppSnackBar(
        context,
        auth.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.joinExclusivity,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameCtrl,
                  label: AppStrings.fullName,
                  hintText: 'e.g. Eleanor Vance',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailCtrl,
                  label: AppStrings.email,
                  hintText: 'e.g. eleanor@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneCtrl,
                  label: AppStrings.phoneNumber,
                  hintText: '10 digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.optionalPhone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordCtrl,
                  label: AppStrings.password,
                  hintText: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmCtrl,
                  label: AppStrings.confirmPassword,
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.confirmPassword(() => _passwordCtrl.text),
                ),
                const SizedBox(height: 32),
                AppButton(
                  title: AppStrings.createAccount,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text(
                        AppStrings.login,
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
    );
  }
}