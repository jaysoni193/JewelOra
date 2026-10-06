import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/empty_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: const EmptyView(message: 'Your cart is empty', icon: Icons.shopping_bag_outlined),
    );
  }
}