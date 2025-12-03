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

  Color _statusColor(bool v) => v ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot("CAM", _statusColor(camRunning)),
            const SizedBox(width: 12),
            _buildDot("SCENE", _statusColor(sceneActive)),
            const SizedBox(width: 12),
            _buildDot(
              "RTC",
              streamingConnecting
                  ? Colors.orange
                  : _statusColor(streamingConnected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
