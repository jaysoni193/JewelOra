import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const EmptyState(
        title: 'Coming Soon',
        subtitle: 'We are curating exciting new pieces for this collection.',
        icon: Icons.diamond_outlined,
      ),
    );
  }
}