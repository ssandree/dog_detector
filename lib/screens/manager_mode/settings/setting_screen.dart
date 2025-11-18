import '../../../core/index_export.dart';
import 'widgets/pet_profile.dart';
import 'widgets/notification_settings_section.dart';
import 'widgets/data_management_section.dart';
import 'widgets/account_management_section.dart';

class SettingScreen extends ConsumerWidget {
   const SettingScreen({super.key});

   @override
   Widget build(BuildContext context, WidgetRef ref) {
      return StandardScaffold(
         title: '환경설정',
         showBackButton: true,
         body: SingleChildScrollView(
            child: HorizontalPadding(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     // 강아지 프로필
                     const PetProfile(),
                     AppConstants.h12,

                     // 알림 설정 섹션
                     const NotificationSettingsSection(),
                     AppConstants.h16,
                     
                     // 데이터 관리 섹션
                     const DataManagementSection(),
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

