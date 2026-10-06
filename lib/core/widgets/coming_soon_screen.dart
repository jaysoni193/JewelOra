import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const EmptyView(
        message: 'Coming soon',
        icon: Icons.construction_outlined,
      ),
    );
  }
}