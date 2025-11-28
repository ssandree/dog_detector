import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/app_prefs_provider.dart';
import '../../../../core/provider/user_provider.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../auth/providers/auth_controller.dart';
import 'setting_row.dart';

/// 계정 관리 섹션
class AccountManagementSection extends ConsumerWidget {
  const AccountManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    String emailText = userAsync.maybeWhen(
      data: (user) => user.email.isNotEmpty ? user.email : '이메일 정보를 찾을 수 없어요',
      orElse: () => '이메일 정보를 불러오는 중...',
    );

    return SettingsSection(
      title: '계정 관리',
      children: [
        ActionRow(
          title: '로그인',
          trailingText: emailText,
          subtitle: userAsync.hasError
              ? '이메일 정보를 불러오지 못했습니다'
              : null,
          onTap: userAsync.hasError
              ? () => ref.refresh(currentUserProvider)
              : null,
        ),
        ActionRow(
          title: '현재 기기 모드 재설정',
          subtitle: '매니저모드/캠모드 중 선택하여 재설정',
          onTap: () => _resetMode(context, ref),
        ),
        ActionRow(
          title: '로그아웃',
          subtitle: '로그아웃 후 로그인 화면으로 이동합니다',
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }

  void _resetMode(BuildContext context, WidgetRef ref) {
    // 모드 리셋 후 메인 화면으로 이동
    ref.read(appPrefsProvider.notifier).setMode(null);
    context.go(AppRoutes.modeSelect);
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
      // 로그아웃 처리
      await ref.read(authControllerProvider.notifier).signOut();
      
      // 로그인 화면으로 이동
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

