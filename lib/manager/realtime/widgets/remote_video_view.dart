import 'package:flutter/material.dart';

import '../../../../core/config/app_constants.dart';

class RemoteVideoView extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isFrozen;
  final bool isPaused;
  final int videoWidth;

  const RemoteVideoView({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isFrozen,
    required this.isPaused,
    required this.videoWidth,
  });

  @override
  Widget build(BuildContext context) {
    final qualityText = _qualityFromWidth(videoWidth);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: 1280,
                  height: 720,
                  color: Colors.black,
                  child: const Icon(
                    Icons.videocam,
                    size: 120,
                    color: Colors.white30,
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (hasError)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '영상 신호를 불러오지 못했습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isFrozen)
            const Positioned(
              top: 12,
              left: 12,
              child: _Badge(
                color: Colors.orange,
                icon: Icons.wifi_tethering_error,
                label: '네트워크 불안정',
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _Badge(
              color: Colors.black54,
              icon: Icons.high_quality,
              label: isPaused ? '일시정지' : qualityText,
            ),
          ),
        ],
      ),
    );
  }

  String _qualityFromWidth(int width) {
    if (width >= 1280) return '720p';
    if (width >= 854) return '480p';
    return '360p';
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _Badge({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
