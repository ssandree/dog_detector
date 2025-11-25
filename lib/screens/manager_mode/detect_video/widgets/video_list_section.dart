import '../../../../core/index_export.dart';
import '../../../../models/event_info.dart';
import 'video_item.dart';

/// 영상 목록 섹션 위젯
class VideoListSection extends StatelessWidget {
  final List<EventInfo> events;
  final void Function(EventInfo event)? onVideoTap;

  const VideoListSection({
    super.key,
    required this.events,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '영상 목록',
          style: TextStyle(
            fontSize: AppConstants.titleFontSize - 6,
            fontWeight: FontWeight.bold,
            color: AppColors.grey12,
          ),
        ),
        AppConstants.h12,
        ...events.map((event) => VideoItem(
              event: event,
              onTap: onVideoTap != null ? () => onVideoTap!(event) : null,
            )).toList(),
      ],
    );
  }
}

