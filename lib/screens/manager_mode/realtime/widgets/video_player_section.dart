import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

class VideoPlayerSection extends StatelessWidget {
const VideoPlayerSection({super.key});

@override
Widget build(BuildContext context) {
  return AppCards.videoPlayer(
  liveBadgeText: 'LIVE',
  overlayWidgets: [
      // 비디오 배경 (강아지 이미지 시뮬레이션)
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: const Center(
        child: Icon(
            Icons.pets,
            size: 80,
            color: Colors.grey,
        ),
        ),
      ),
      
      // LIVE 배지
      Positioned(
        bottom: 12,
        left: 12,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
              Icons.pets,
              color: Colors.white,
              size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
              'LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
              ),
              ),
            ],
        ),
        ),
      ),
      
      // 컨트롤 버튼들
      Positioned(
        bottom: 12,
        right: 12,
        child: Row(
        children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              ),
              child: const Icon(
              Icons.volume_off,
              color: Colors.black,
              size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              ),
              child: const Icon(
              Icons.fullscreen,
              color: Colors.black,
              size: 20,
              ),
            ),
        ],
        ),
      ),
  ],
  child: Container(
    height: 200, // 고정 높이 설정
    width: double.infinity,
  ),
  );
}
}
