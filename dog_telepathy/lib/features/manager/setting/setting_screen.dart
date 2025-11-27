import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/provider/pet_provider.dart';
import 'widgets/notification_settings_section.dart';
import 'widgets/account_management_section.dart';

class SettingScreen extends ConsumerWidget {
   final Widget? bottomNavigationBar;
   
   const SettingScreen({
      super.key,
      this.bottomNavigationBar,
   });

   @override
   Widget build(BuildContext context, WidgetRef ref) {
      return BaseScaffold(
         title: '환경설정',
         showBackButton: bottomNavigationBar == null,
         showNotification: true,
         bottomNavigationBar: bottomNavigationBar,
         body: SingleChildScrollView(
            child: HorizontalPadding(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     // Pet 목록 새로고침 버튼
                     _PetListRefreshButton(),
                     AppConstants.h16,
                     
                     // 알림 설정 섹션
                     const NotificationSettingsSection(),
                     AppConstants.h16,
                     
                     // 계정 관리 섹션
                     const AccountManagementSection(),
                     AppConstants.h16,
                  ],
               ),
            ),
         ),
      );
   }
}

/// Pet 목록 새로고침 버튼
class _PetListRefreshButton extends ConsumerStatefulWidget {
  const _PetListRefreshButton();

  @override
  ConsumerState<_PetListRefreshButton> createState() => _PetListRefreshButtonState();
}

class _PetListRefreshButtonState extends ConsumerState<_PetListRefreshButton> {
  bool _isLoading = false;

  Future<void> _refreshPetList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(petProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('반려동물 목록을 새로고침했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('반려동물 목록을 불러오는데 실패했습니다: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: '반려동물 목록 새로고침',
      onPressed: () {
        if (!_isLoading) {
          _refreshPetList();
        }
      },
      isLoading: _isLoading,
    );
  }
}

