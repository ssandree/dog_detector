// lib/features/cam/widgets/cam_status_bar.dart

import 'package:flutter/material.dart';

class CamStatusBar extends StatelessWidget {
  final bool camRunning;
  final bool sceneActive;
  final bool streamingConnected;
  final bool streamingConnecting;

  const CamStatusBar({
    super.key,
    required this.camRunning,
    required this.sceneActive,
    required this.streamingConnected,
    required this.streamingConnecting,
  });

  Color _dotColor(bool on) => on ? Colors.green : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: _dotColor(camRunning)),
              const SizedBox(width: 6),
              Text(
                'CAM 모드: ${camRunning ? "ON" : "OFF"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(Icons.pets,
                  size: 14, color: _dotColor(sceneActive)),
              const SizedBox(width: 6),
              Text(
                sceneActive ? '장면: 강아지 감지됨' : '장면: 대기 중',
                style: TextStyle(
                  color: sceneActive ? Colors.greenAccent : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(Icons.wifi_tethering,
                  size: 14,
                  color: streamingConnected
                      ? Colors.greenAccent
                      : (streamingConnecting ? Colors.orange : Colors.grey)),
              const SizedBox(width: 6),
              Text(
                streamingConnected
                    ? 'Streaming: CONNECTED'
                    : (streamingConnecting
                        ? 'Streaming: CONNECTING...'
                        : 'Streaming: OFF'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
