// lib/manager/manager_home/widgets/event_count_card.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/widgets/app_cards.dart';
import '../../logic/provider/event_provider.dart';
import '../../logic/model/event_info.dart';
import '../../../features/pet/application/current_pet_provider.dart';

class EventStats {
  static int recentEventCount(
    List<EventInfo> events, {
    Duration window = const Duration(hours: 3),
  }) {
    final now = DateTime.now();
    final threshold = now.subtract(window);
    
    final filtered = events.where((event) {
      return !event.startTime.isBefore(threshold);
    }).toList();
    
    return filtered.length;
  }

  static int patellaAlertCount(List<EventInfo> events) {
    return events
        .where((event) => 
            (event.patellaAnalysisResult?.trim() ?? '') == '이상')
        .length;
  }
}

class EventCountCard extends ConsumerWidget {
  const EventCountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(currentPetProvider);
    final petId = pet?.petId;

    if (petId == null) {
      return AppCards.basic(
        child: Text(
          '반려동물 정보를 등록하면 건강 이벤트를 추적할 수 있어요.',
          style: TextStyle(
            fontSize: AppConstants.defaultFontSize,
            color: AppColors.grey8,
          ),
        ),
      );
    }

    // 최근 3시간 이벤트를 정확히 계산하기 위해 오늘과 어제 날짜의 이벤트를 모두 가져오기
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    
    // 오늘과 어제 날짜의 이벤트를 모두 가져오기
    final todayRequest = DailyEventRequest(petId: petId, date: todayDate);
    final yesterdayRequest = DailyEventRequest(petId: petId, date: yesterdayDate);
    
    final todayEventsAsync = ref.watch(dailyEventsProvider(todayRequest));
    final yesterdayEventsAsync = ref.watch(dailyEventsProvider(yesterdayRequest));

    return todayEventsAsync.when(
      data: (todayEvents) {
        return yesterdayEventsAsync.when(
          data: (yesterdayEvents) {
            // 오늘과 어제 이벤트를 합쳐서 최근 3시간 계산
            final allEvents = [...todayEvents.events, ...yesterdayEvents.events];
            
            final recentCount = EventStats.recentEventCount(allEvents);
            // 슬개골 이상은 오늘 날짜의 이벤트만 카운트
            final patellaCount = EventStats.patellaAlertCount(todayEvents.events);

        return AppCards.basic(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘 건강 추적',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey12,
                ),
              ),
              AppConstants.h12,
              _StatRow(
                label: '최근 3시간 감지된 이벤트',
                value: '$recentCount건',
                icon: Icons.radar,
                iconColor: AppColors.green5,
              ),
              AppConstants.h8,
              _StatRow(
                label: '슬개골 이상 감지',
                value: patellaCount > 0 ? '$patellaCount건' : '없음',
                icon: Icons.medical_services_outlined,
                iconColor:
                    patellaCount > 0 ? AppColors.coral4 : AppColors.grey6,
              ),
            ],
          ),
        );
          },
          loading: () => AppCards.basic(
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                AppConstants.w12,
                const Expanded(
                  child: Text(
                    '이벤트 데이터를 불러오는 중...',
                    style: TextStyle(color: AppColors.grey7),
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => AppCards.basic(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '건강 이벤트를 불러오지 못했어요',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppConstants.h8,
                Text(
                  error.toString(),
                  style: const TextStyle(color: AppColors.grey8),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => AppCards.basic(
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            AppConstants.w12,
            const Expanded(
              child: Text(
                '이벤트 데이터를 불러오는 중...',
                style: TextStyle(color: AppColors.grey7),
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => AppCards.basic(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '건강 이벤트를 불러오지 못했어요',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppConstants.h8,
            Text(
              error.toString(),
              style: const TextStyle(color: AppColors.grey8),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        AppConstants.w12,
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey9,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.grey12,
          ),
        ),
      ],
    );
  }
}
