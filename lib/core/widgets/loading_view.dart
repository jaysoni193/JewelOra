import 'package:flutter/material.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingView({
    super.key,
    this.message,
    this.size = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppLoader(
        size: size,
        message: message,
      ),
    );
  }
}