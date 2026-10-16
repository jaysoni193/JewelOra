import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/providers/connectivity_provider.dart';
import 'package:provider/provider.dart';

/// Global overlay widget that shows a floating luxury banner whenever
/// the device has no internet connection, and a brief success pill when reconnected.
class ConnectivityBannerWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityBannerWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityProvider>();
    final isOffline = connectivity.isOffline;
    final showRestored = connectivity.showRestoredBanner;
    final isChecking = connectivity.isChecking;

    final isVisible = isOffline || showRestored;

    return Stack(
      children: [
        child,

        // Floating Animated Notification Banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              offset: isVisible ? Offset.zero : const Offset(0, -1.3),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !isVisible,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: showRestored
                                ? [
                                    const Color(0xFF1B5E20), // Dark green
                                    const Color(0xFF2E7D32), // Emerald
                                  ]
                                : [
                                    const Color(0xFF7F1D1D), // Deep crimson
                                    const Color(0xFF991B1B), // Luxury wine
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: showRestored
                                ? Colors.greenAccent.withValues(alpha: 0.6)
                                : const Color(0xFFFCA5A5).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: showRestored
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                showRestored
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    showRestored
                                        ? AppStrings.backOnline
                                        : AppStrings.pleaseCheckInternetConnection,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  if (!showRestored) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      AppStrings.checkInternetSubtitle,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!showRestored) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: isChecking
                                    ? null
                                    : () => connectivity.checkConnection(),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                                child: isChecking
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.refresh_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            AppStrings.retry,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
