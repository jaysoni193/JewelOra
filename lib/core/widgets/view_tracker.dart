import 'package:flutter/material.dart';
import 'package:jewel_ora/services/stats_service.dart';

class ViewTracker extends StatefulWidget {
  final String productId;
  const ViewTracker({super.key, required this.productId});

  @override
  State<ViewTracker> createState() => _ViewTrackerState();
}

class _ViewTrackerState extends State<ViewTracker> {
  @override
  void initState() {
    super.initState();
    StatsService.recordView(widget.productId);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}