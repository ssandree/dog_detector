import '../../core/index_export.dart';
import 'mode_selection/widgets/simple_description.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige2,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 중앙 섹션 - 애니메이션 없이 고정
            const SimpleDescription(),

            // 버튼 섹션 - 시작하기 버튼만 표시
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                bottom: MediaQuery.of(context).size.height * 0.12,
              ),
              child: AppButtons.normal(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 60,
                text: '시작하기',
                onPressed: () {
                  context.push(AppRoutes.onboarding);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
