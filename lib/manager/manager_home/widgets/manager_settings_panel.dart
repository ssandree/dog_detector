// lib/manager/manager_home/widgets/manager_settings_panel.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/widgets/onoff_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/storage/app_prefs_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../manager/update_modal/pet_update_modal.dart';
import '../../../manager/update_modal/me_update_modal.dart';
import '../../../manager/logic/provider/notification_provider.dart';
import '../../../manager/logic/model/notification_models.dart';
import '../../../manager/logic/provider/user_provider.dart';
import '../../../features/pet/application/current_pet_provider.dart';
import '../../../features/pet/application/pet_provider.dart';

class ManagerSettingsPanel extends ConsumerStatefulWidget {
  const ManagerSettingsPanel({super.key});

  @override
  ConsumerState<ManagerSettingsPanel> createState() => _ManagerSettingsPanelState();
}

class _ManagerSettingsPanelState extends ConsumerState<ManagerSettingsPanel> {
  bool _isNotificationExpanded = false;

  @override
  void initState() {
    super.initState();
    // 알림 설정을 서버에서 한 번 불러와서 초기 상태를 동기화
    Future.microtask(() {
      ref.read(notificationSettingsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.85; // 화면 너비의 85%
    final notificationSettingsAsync = ref.watch(notificationSettingsProvider);

    return Container(
      width: panelWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: BaseScaffold(
        title: "설정",
        useSafeArea: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        body: Padding(
          padding: EdgeInsets.all(AppConstants.defaultSpacing),
      child: Column(
        children: [
              _notificationSettingItem(context, ref, notificationSettingsAsync),
              _settingItem(
                context,
                Icons.account_circle,
                "내 정보",
                onTap: () {
                  final userAsync = ref.read(currentUserProvider);
                  Navigator.of(context).pop();
                  if (userAsync.hasValue && userAsync.value != null) {
                    showMeUpdateModal(
                      context,
                      existingUserInfo: userAsync.value,
                    );
                  }
                },
              ),
              _settingItem(
                context,
                Icons.person,
                "반려동물 정보",
                onTap: () {
                  final pet = ref.read(currentPetProvider);
                  Navigator.of(context).pop();
                  showPetRegiModal(
                    context,
                    existingPetInfo: pet,
                  );
                },
              ),
              _settingItem(
                context,
                Icons.swap_horiz,
                "모드 재선택",
                onTap: () => _handleModeReselect(context, ref),
              ),
              const Divider(height: 32),
              _settingItem(
                context,
                Icons.logout,
                "로그아웃",
                textColor: Colors.red,
                onTap: () => _handleLogout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleModeReselect(BuildContext context, WidgetRef ref) async {
    // 확인 다이얼로그 표시
    final confirm = await showConfirmDialog(
      context: context,
      title: '모드 재선택',
      content: '모드 선택 화면으로 이동할까요?',
      confirmText: '이동',
      cancelText: '취소',
    );

    if (confirm == true && context.mounted) {
      // 설정 패널 닫기
      Navigator.of(context).pop();
      
      // 모드 선택 화면으로 이동
      if (context.mounted) {
        context.go(AppRoutes.modeSelect);
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // 확인 다이얼로그 표시
    final confirm = await showConfirmDialog(
      context: context,
      title: '로그아웃',
      content: '로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
    );

    if (confirm == true && context.mounted) {
      // 토큰 삭제
      await ref.read(secureStorageServiceProvider).deleteToken();
      
      // 모드 리셋
      await ref.read(appPrefsProvider.notifier).setMode(null);
      
      // 액세스 토큰 리셋 (petProvider가 자동으로 감지하여 리셋됨)
      await ref.read(appPrefsProvider.notifier).setAccessToken(null);
      
      // petProvider 명시적으로 리셋 (이전 사용자 데이터 제거)
      ref.read(petProvider.notifier).reset();
      
      // 설정 패널 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // 로그인 화면으로 이동
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  Widget _notificationSettingItem(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<NotificationSettings> notificationSettingsAsync,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isNotificationExpanded = !_isNotificationExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                const Text(
                  "알림 설정",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isNotificationExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (_isNotificationExpanded)
          notificationSettingsAsync.when(
            data: (settings) => Padding(
              padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    "즉시 알림",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  OnOffButton(
                    value: settings.instantAlert,
                    onChanged: (enabled) async {
                      try {
                        // Riverpod notifier를 통해 상태 + 서버 설정을 함께 갱신
                        final notifier =
                            ref.read(notificationSettingsProvider.notifier);
                        await notifier.toggleInstantAlert(enabled);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('알림 설정 변경에 실패했습니다: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(left: 40, top: 8, bottom: 8),
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
              child: Text(
                '설정을 불러올 수 없습니다',
            style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _settingItem(
    BuildContext context,
    IconData icon,
    String label, {
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
            Icon(
              icon,
              color: textColor ?? Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor ?? Colors.black87,
                fontWeight: textColor != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
