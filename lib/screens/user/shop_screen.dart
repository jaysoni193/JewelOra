import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: const EmptyView(message: 'Products coming soon', icon: Icons.diamond_outlined),
    );
  }
}