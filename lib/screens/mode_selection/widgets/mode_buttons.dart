import '../../../core/index_export.dart';

class ModeSelectionSection extends StatelessWidget {
   const ModeSelectionSection({
      super.key,
   });

   @override
   Widget build(BuildContext context) {
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
                     context.push(AppRoutes.managerHome);
                  },
               ),
            ],
         ),
      );
   }
}
