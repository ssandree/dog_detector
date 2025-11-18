import '../../core/index_export.dart';
import 'widgets/placeholder_camera.dart';
import 'widgets/analysis_result_panel.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      title: '캠모드',
      showBackButton: true,
      onBackPressed: () => context.go(AppRoutes.main),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding.horizontal,
        ),
        child: Column(
          children: [
            SizedBox(height: AppConstants.defaultSpacing),
            PlaceholderCamera(),
            SizedBox(height: AppConstants.largeSpacing),
            AnalysisResultPanel(),
            SizedBox(height: AppConstants.largeSpacing)
          ],
        ),
      ),
    );
  }
}
