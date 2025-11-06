import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/index_export.dart';
import '../../../core/providers/app_provider.dart';

class ModeSelectionSection extends ConsumerWidget {
   const ModeSelectionSection({
      super.key,
   });

   @override
   Widget build(BuildContext context, WidgetRef ref) {
      return Center(
         child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               AppButtons.normal(
                  text: '캠 모드',
                  subtitle: '반려동물의 실시간 감정을 기록합니다',
                  icon: Icons.videocam,
                  fontSize: 20,
                  height: 100,
                  backgroundColor: AppColors.coral1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                     // 모드 설정 후 라우팅
                     ref.read(appModeProvider.notifier).setCameraMode();
                     context.push(AppRoutes.cameraHome);
                  },
               ),
               AppConstants.h20,
               AppButtons.normal(
                  text: '매니저 모드',
                  subtitle: '반려동물의 데이터를 관리하고 분석합니다',
                  icon: Icons.bar_chart,
                  fontSize: 20,
                  height: 100,
                  backgroundColor: AppColors.coral2,
                  width: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                     // 모드 설정 후 라우팅
                     ref.read(appModeProvider.notifier).setManagerMode();
                     context.push(AppRoutes.managerHome);
                  },
               ),
            ],
         ),
      );
   }
}
