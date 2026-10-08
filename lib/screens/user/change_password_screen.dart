import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/utils/validators.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, 'Password changed successfully');
      Navigator.of(context).pop();
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
    final isSaving = context.watch<AuthProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Credentials',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _currentCtrl,
                        label: 'Current Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => Validators.required(v, 'Current password'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _newCtrl,
                        label: 'New Password',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        validator: (v) {
                          final base = Validators.password(v);
                          if (base != null) return base;
                          if (v == _currentCtrl.text) {
                            return 'New password must be different';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmCtrl,
                        label: 'Confirm New Password',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        validator: Validators.confirmPassword(() => _newCtrl.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AppButton(
                  title: 'Update Password',
                  isLoading: isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}