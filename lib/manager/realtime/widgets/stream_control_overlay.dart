import 'package:flutter/material.dart';

import '../realtime_types.dart';
import 'overlay_control_button.dart';

class StreamControlOverlay extends StatelessWidget {
  final StreamConnectionState connectionState;
  final bool isPaused;
  final bool soundMuted;
  final bool micEnabled;
  final VoidCallback onTogglePause;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleFullscreen;

  const StreamControlOverlay({
    super.key,
    required this.connectionState,
    required this.isPaused,
    required this.soundMuted,
    required this.micEnabled,
    required this.onTogglePause,
    required this.onToggleMute,
    required this.onToggleMic,
    required this.onToggleFullscreen,
  });

  bool get _isInteractive => connectionState == StreamConnectionState.connected;

  @override
  Widget build(BuildContext context) {
    if (connectionState == StreamConnectionState.failed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: !_isInteractive,
      child: AnimatedOpacity(
        opacity: _isInteractive ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            Center(
              child: OverlayControlButton(
                icon: isPaused ? Icons.play_arrow : Icons.pause,
                onTap: onTogglePause,
                tooltip: isPaused ? '재생' : '일시정지',
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: OverlayControlButton(
                icon: soundMuted ? Icons.volume_off : Icons.volume_up,
                onTap: onToggleMute,
                tooltip: soundMuted ? '음소거 해제' : '음소거',
              ),
            ),
            Positioned(
              right: 12,
              top: 72,
              child: OverlayControlButton(
                icon: micEnabled ? Icons.mic : Icons.mic_off,
                onTap: onToggleMic,
                tooltip: micEnabled ? '마이크 끄기' : '마이크 켜기',
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: OverlayControlButton(
                icon: Icons.fullscreen,
                onTap: onToggleFullscreen,
                tooltip: '전체 화면',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
