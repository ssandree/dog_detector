import 'package:flutter/material.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../realtime_types.dart';

class StreamSummaryBar extends StatelessWidget {
  final String cameraId;
  final Duration usageDuration;
  final Duration totalUptime;
  final StreamConnectionState connectionState;
  final int videoWidth;

  const StreamSummaryBar({
    super.key,
    required this.cameraId,
    required this.usageDuration,
    required this.totalUptime,
    required this.connectionState,
    required this.videoWidth,
  });

  @override
  Widget build(BuildContext context) {
    final connectionInfo = _connectionMeta(connectionState);
    final quality = _qualityFromWidth(videoWidth);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: AppConstants.defaultSpacing / 2,
      ),
      padding: EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '카메라: $cameraId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusChip(meta: connectionInfo),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: '누적 탐지 시간',
                  value: _formatDuration(usageDuration),
                  icon: Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: '영상 화질',
                  value: quality ?? '측정 중…',
                  icon: Icons.high_quality_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SummaryTile(
            label: '캠 모드 누적 가동 시간',
            value: _formatDuration(totalUptime),
            icon: Icons.timelapse_outlined,
          ),
        ],
      ),
    );
  }

  _StatusMeta _connectionMeta(StreamConnectionState state) {
    switch (state) {
      case StreamConnectionState.connecting:
        return _StatusMeta(color: Colors.grey, icon: Icons.sync, label: '연결 중');
      case StreamConnectionState.connected:
        return _StatusMeta(
          color: Colors.green,
          icon: Icons.check_circle,
          label: '연결됨',
        );
      case StreamConnectionState.reconnecting:
        return _StatusMeta(
          color: Colors.orange,
          icon: Icons.wifi_find,
          label: '재연결 중',
        );
      case StreamConnectionState.failed:
        return _StatusMeta(color: Colors.red, icon: Icons.error, label: '실패');
    }
  }

  String? _qualityFromWidth(int width) {
    if (width == 0) return null;
    if (width >= 1280) return '720p';
    if (width >= 854) return '480p';
    return '360p';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey7),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.grey7),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _StatusMeta meta;

  const _StatusChip({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 14, color: meta.color),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: TextStyle(color: meta.color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
