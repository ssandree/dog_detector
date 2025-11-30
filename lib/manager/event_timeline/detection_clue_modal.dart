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

  @override
  void initState() {
    super.initState();
    final url = widget.event.videoUrl;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
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
                  child: _isInitialized
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
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // 시작 시간 (시:분)
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
                if (features != null && features.isNotEmpty) ...[
                  Text(
                    features,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey9,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
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

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
