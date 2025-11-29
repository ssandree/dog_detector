import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/app_constants.dart';
import '../../../core/widgets/base_scaffold.dart';
import '../../../core/provider/notification_provider.dart';
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
      final settingsAsync = ref.watch(notificationSettingsProvider);
      final settingsNotifier = ref.read(notificationSettingsProvider.notifier);

      return BaseScaffold(
         title: '환경설정',
         showBackButton: bottomNavigationBar == null,
         showNotification: false,
         bottomNavigationBar: bottomNavigationBar,
         body: SingleChildScrollView(
            child: HorizontalPadding(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     // 알림 설정 섹션
                     NotificationSettingsSection(
                        settings: settingsAsync,
                        onToggleInstantAlert: settingsNotifier.toggleInstantAlert,
                     ),
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

