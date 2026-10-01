import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/theme/app_theme.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/primary_button.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ThemePreviewScreen(),
    );
  }
}

// Temporary screen to preview the theme. We replace it in Step 3.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: controller,
              label: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            PrimaryButton(text: 'Primary Button', onPressed: () {}),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
          ],
        ),
      ),
    );
  }
}