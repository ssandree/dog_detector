import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/index_export.dart';
import '../../../providers/app_provider.dart';

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
                  icon: Icons.videocam,
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.8,
                  onPressed: () {
                     // 모드 설정 후 라우팅
                     ref.read(appModeProvider.notifier).setCameraMode();
                     context.push(AppRoutes.cameraHome);
                  },
               ),
               const SizedBox(height: 20),
               AppButtons.normal(
                  text: '매니저 모드',
                  icon: Icons.bar_chart,
                  height: 80,
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
