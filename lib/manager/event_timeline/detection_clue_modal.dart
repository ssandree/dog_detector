import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../logic/model/event_info.dart';
import '../../../../core/widgets/app_status_tags.dart';

class DetectionClueModal extends StatefulWidget {
  final EventInfo event;

  const DetectionClueModal({super.key, required this.event});

  @override
  State<DetectionClueModal> createState() => _DetectionClueModalState();
}

class _DetectionClueModalState extends State<DetectionClueModal> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
    final url = widget.event.videoUrl;
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '비디오를 불러올 수 없습니다: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final features = event.detectedFeatures?.trim();
    final emotion = event.finalEmotion?.trim();
    final patella = event.patellaAnalysisResult?.trim();
    final hasPatellaAbnormal = patella == '이상';
    final startLabel =
        '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}:${event.startTime.second.toString().padLeft(2, '0')}';

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '탐지 영상 보기',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  child: _errorMessage != null
                      ? Container(
                          color: Colors.black87,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : _isInitialized
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_controller),
                            _ControlsOverlay(controller: _controller),
                            VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: AppColors.green4,
                                backgroundColor: Colors.black26,
                                bufferedColor: Colors.white24,
                              ),
                            ),
                          ],
                        )
                          : Container(
                              color: Colors.black87,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // 시작 시간 및 비디오 길이
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.grey8,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    startLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey9,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '·',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey7,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${event.videoDurationSec}초',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey9,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (features != null && features.isNotEmpty) ...[
                Text(
                  '탐지 특징',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  features,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              if ((emotion != null && emotion.isNotEmpty) || hasPatellaAbnormal) ...[
                Row(
                  children: [
                    if (emotion != null && emotion.isNotEmpty)
                      AppStatusTags.emotionTag(
                        emotion: emotion,
                      ),
                    if (hasPatellaAbnormal) ...[
                      if (emotion != null && emotion.isNotEmpty)
                        const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.error,
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          '슬개 이상',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool _showPlayButton = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      final isPlaying = widget.controller.value.isPlaying;
      setState(() {
        _isPlaying = isPlaying;
        // 재생 중이면 재생 버튼 숨기기, 일시정지면 다시 표시
        if (isPlaying) {
          _showPlayButton = false;
        } else {
          _showPlayButton = true;
        }
      });
    }
  }

  void _handleTap() {
    if (_isPlaying) {
      widget.controller.pause();
    } else {
      // 재생 버튼을 누르는 순간 즉시 숨기기
      setState(() {
        _showPlayButton = false;
      });
      widget.controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPlayButton) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
