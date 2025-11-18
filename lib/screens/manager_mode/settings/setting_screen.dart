import '../../../core/index_export.dart';
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

