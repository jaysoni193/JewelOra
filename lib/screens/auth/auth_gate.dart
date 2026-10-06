import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/loading_view.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/screens/admin/admin_dashboard.dart';
import 'package:jewel_ora/screens/auth/login_screen.dart';
import 'package:jewel_ora/screens/user/user_shell.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
        return const Scaffold(body: LoadingView());
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return auth.isAdmin ? const AdminDashboard() : const UserShell();
    }
  }
}