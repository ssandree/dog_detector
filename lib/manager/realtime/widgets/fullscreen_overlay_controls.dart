import 'dart:async';

import 'package:flutter/material.dart';

import '../realtime_types.dart';
import 'overlay_control_button.dart';

class FullscreenOverlayControls extends StatefulWidget {
  final String cameraId;
  final StreamConnectionState connectionState;
  final int videoWidth;
  final bool soundMuted;
  final bool micEnabled;
  final VoidCallback onExitFullscreen;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleMic;

  const FullscreenOverlayControls({
    super.key,
    required this.cameraId,
    required this.connectionState,
    required this.videoWidth,
    required this.soundMuted,
    required this.micEnabled,
    required this.onExitFullscreen,
    required this.onToggleMute,
    required this.onToggleMic,
  });

  @override
  State<FullscreenOverlayControls> createState() =>
      _FullscreenOverlayControlsState();
}

class _FullscreenOverlayControlsState extends State<FullscreenOverlayControls> {
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _visible = false);
    });
  }

  void _toggleVisibility() {
    setState(() => _visible = !_visible);
    if (_visible) {
      _scheduleHide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _connectionMeta(widget.connectionState);
    final quality = widget.videoWidth >= 1280
        ? '720p'
        : widget.videoWidth >= 854
        ? '480p'
        : '360p';

    return GestureDetector(
      onTap: _toggleVisibility,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.cameraId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(meta.icon, color: meta.color, size: 16),
                        const SizedBox(width: 4),
                        Text(meta.label, style: TextStyle(color: meta.color)),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.high_quality,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          quality,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              top: 70,
              child: Column(
                children: [
                  OverlayControlButton(
                    icon: widget.soundMuted
                        ? Icons.volume_off
                        : Icons.volume_up,
                    onTap: () {
                      widget.onToggleMute();
                      _scheduleHide();
                    },
                    tooltip: widget.soundMuted ? '음소거 해제' : '음소거',
                  ),
                  const SizedBox(height: 12),
                  OverlayControlButton(
                    icon: widget.micEnabled ? Icons.mic : Icons.mic_off,
                    onTap: () {
                      widget.onToggleMic();
                      _scheduleHide();
                    },
                    tooltip: widget.micEnabled ? '마이크 끄기' : '마이크 켜기',
                  ),
                  const SizedBox(height: 12),
                  OverlayControlButton(
                    icon: Icons.fullscreen_exit,
                    onTap: widget.onExitFullscreen,
                    tooltip: '전체 화면 종료',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusMeta _connectionMeta(StreamConnectionState state) {
    switch (state) {
      case StreamConnectionState.connecting:
        return const _StatusMeta(
          color: Colors.grey,
          icon: Icons.sync,
          label: '연결 중',
        );
      case StreamConnectionState.connected:
        return const _StatusMeta(
          color: Colors.green,
          icon: Icons.check_circle,
          label: '연결됨',
        );
      case StreamConnectionState.reconnecting:
        return const _StatusMeta(
          color: Colors.orange,
          icon: Icons.wifi_find,
          label: '재연결 중',
        );
      case StreamConnectionState.failed:
        return const _StatusMeta(
          color: Colors.red,
          icon: Icons.error,
          label: '실패',
        );
    }
  }
}

class _StatusMeta {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusMeta({
    required this.color,
    required this.icon,
    required this.label,
  });
}
