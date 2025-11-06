import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/index_export.dart';
import 'settings_section.dart';
import 'setting_row.dart';

/// 계정 관리 섹션
class AccountManagementSection extends ConsumerWidget {
  const AccountManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      title: '계정 관리',
      children: [
        ActionRow(
          title: '로그인',
          trailingText: '2020020@gmail.com',
        ),
        ActionRow(
          title: '현재 기기 모드 재설정',
          subtitle: '매니저모드와 캠모드 중 선택',
          onTap: () => _resetMode(context, ref),
        ),
        // 연결된 기기는 높이 제한 없이 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: const BoxConstraints(
            minHeight: 60,
            maxHeight: double.infinity,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('연결된 기기', style: TextStyle(fontSize: 16)),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '닉네임1(기기이름):매니저 모드\n닉네임2(기기이름):캠모드',
                          style: TextStyle(fontSize: 12, color: AppColors.grey8),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetMode(BuildContext context, WidgetRef ref) {
    // 모드 리셋 후 메인 화면으로 이동
    ref.read(appModeProvider.notifier).resetMode();
    context.go(AppRoutes.modeSelect);
  }
}

