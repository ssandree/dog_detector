import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../logic/provider/event_provider.dart';
import '../calendar/report_modal_widgets/empty_state.dart';
import 'widgets/event_card.dart';
import 'widgets/event_date_picker_dialog.dart';

class EventTimelineRoutePage extends StatelessWidget {
  final GoRouterState state;

  const EventTimelineRoutePage({super.key, required this.state});

  DateTime? _parseInitialDate() {
    final dateStr = state.uri.queryParameters['date'];
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialDate = _parseInitialDate();
    return EventTimelineTabScreen(initialDate: initialDate);
  }
}

/// 탭에서 사용할 타임라인 화면 (날짜 선택 가능, 현재 반려동물 사용)
class EventTimelineTabScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const EventTimelineTabScreen({super.key, this.initialDate});

  @override
  ConsumerState<EventTimelineTabScreen> createState() =>
      _EventTimelineTabScreenState();
}

class _EventTimelineTabScreenState
    extends ConsumerState<EventTimelineTabScreen> {
  late DateTime _selectedDate;
  final Set<String> _selectedEmotions = {};

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  DateTime get _normalizedSelected =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _normalizedSelected.subtract(const Duration(days: 1));
      _selectedEmotions.clear();
    });
  }

  void _goToNextDay() {
    // 오늘 이후로는 이동 불가
    if (_normalizedSelected.isAtSameMomentAs(_today) ||
        _normalizedSelected.isAfter(_today)) {
      return;
    }
    setState(() {
      _selectedDate = _normalizedSelected.add(const Duration(days: 1));
      _selectedEmotions.clear();
    });
  }

  Future<void> _pickDate(BuildContext context, int petId) async {
    final picked = await showEventDatePickerDialog(
      context: context,
      petId: petId,
      initialDate: _normalizedSelected,
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _selectedEmotions.clear();
      });
    }
  }

  String _formatDateLabel(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final petInfo = ref.watch(currentPetProvider);
    final petId = petInfo?.petId;

    if (petId == null) {
      return Center(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: const ReportEmptyState(
            title: '반려견 정보를 찾을 수 없어요',
            message: '마이 펫 정보를 먼저 등록하고 다시 시도해 주세요.',
          ),
        ),
      );
    }

    final eventRequest =
        DailyEventRequest(petId: petId, date: _normalizedSelected);
    final dailyEventsAsync = ref.watch(dailyEventsProvider(eventRequest));

    return dailyEventsAsync.when(
      data: (daily) {
        final events = daily.events;
        final dateLabel = _formatDateLabel(_normalizedSelected);

        // 감정 목록 추출
        final emotionSet = events
            .map((e) => e.finalEmotion)
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet();
        
        // '슬개 이상'이 있는지 확인
        final hasPatellaAbnormal = events.any(
          (e) => e.patellaAnalysisResult?.trim() == '이상',
        );
        
        // 감정 목록에 '슬개 이상' 추가
        final emotions = emotionSet.toList()..sort();
        if (hasPatellaAbnormal) {
          emotions.add('슬개 이상');
        }

        // 필터링 로직
        final filteredEvents = _selectedEmotions.isEmpty
            ? events
            : events
                .where((e) {
                  // 감정 필터
                  if (e.finalEmotion != null &&
                      _selectedEmotions.contains(e.finalEmotion)) {
                    return true;
                  }
                  // '슬개 이상' 필터
                  if (_selectedEmotions.contains('슬개 이상') &&
                      e.patellaAnalysisResult?.trim() == '이상') {
                    return true;
                  }
                  return false;
                })
                .toList();

        return Column(
          children: [
            // 고정된 상단 영역 (날짜 선택기 + 감정 필터)
            Container(
              padding: AppConstants.defaultPadding,
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _DateSelector(
                      dateLabel: dateLabel,
                      onPrev: _goToPreviousDay,
                      onNext: _goToNextDay,
                      canGoNext:
                          _normalizedSelected.isBefore(_today), // 오늘 전날까지만 허용
                      onTapDate: () => _pickDate(context, petId),
                    ),
                  ),
                  if (events.isNotEmpty && (emotions.isNotEmpty || hasPatellaAbnormal)) ...[
                    const SizedBox(height: 16),
                    _EmotionFilterChips(
                      emotions: emotions,
                      selectedEmotions: _selectedEmotions,
                      onToggle: (emotion) {
                        setState(() {
                          if (_selectedEmotions.contains(emotion)) {
                            _selectedEmotions.remove(emotion);
                          } else {
                            _selectedEmotions.add(emotion);
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            // 스크롤 가능한 이벤트 리스트 영역
            Expanded(
              child: events.isEmpty
                  ? Padding(
                      padding: AppConstants.defaultPadding,
                      child: const Center(
                        child: ReportEmptyState(
                          title: '이날의 이벤트가 없어요',
                          message:
                              '카메라가 감지한 이벤트가 없어서 타임라인을 만들 수 없어요.',
                        ),
                      ),
                    )
                  : filteredEvents.isEmpty
                      ? Padding(
                          padding: AppConstants.defaultPadding,
                          child: const Center(
                            child: ReportEmptyState(
                              title: '선택한 감정의 이벤트가 없어요',
                              message: '다른 감정을 선택하거나 필터를 해제해 보세요.',
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: AppConstants.defaultPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: filteredEvents.map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: EventCard(event: event),
                              ),
                            ).toList(),
                          ),
                        ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: ReportEmptyState(
            title: '데이터를 불러오지 못했어요',
            message: error.toString(),
          ),
        ),
      ),
    );
  }
}

/// 상단 날짜 선택 위젯
class _DateSelector extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canGoNext;
  final VoidCallback onTapDate;

  const _DateSelector({
    required this.dateLabel,
    required this.onPrev,
    required this.onNext,
    required this.canGoNext,
    required this.onTapDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row( // 날짜 선택 위젯
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapDate,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text( // 날짜 라벨
                dateLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey12,
                ),
              ),
            ),
          ),
        ),
        IconButton( // 다음 날짜 버튼
          icon: Icon(
            Icons.chevron_right,
            color: canGoNext ? AppColors.grey9 : AppColors.grey5,
          ),
          onPressed: canGoNext ? onNext : null,
        ),
      ],
    );
  }
}

/// 감정 필터 태그 영역
class _EmotionFilterChips extends StatelessWidget {
  final List<String> emotions;
  final Set<String> selectedEmotions;
  final ValueChanged<String> onToggle;

  const _EmotionFilterChips({
    required this.emotions,
    required this.selectedEmotions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        return FilterChip(
          label: Text(
            emotion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.grey12,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onToggle(emotion),
          backgroundColor: AppColors.white,
          selectedColor: AppColors.green6,
          showCheckmark: false,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppColors.green6 : AppColors.grey4,
            ),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        );
      }).toList(),
    );
  }
}
