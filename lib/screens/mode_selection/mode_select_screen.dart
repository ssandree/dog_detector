import '../../core/index_export.dart';
import './widgets/simple_description.dart';
import './widgets/mode_buttons.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.beige2,
      body: Column(
        children: [
          // 중앙 섹션
          Expanded(
            flex: 4,
            child: Center(
              child: const SimpleDescription(),
            ),
          ),

          // 버튼 섹션 - 고정 높이로 오버플로우 방지
          SizedBox(
            height: 320, // 충분한 고정 높이 (버튼 2개 + 간격 + 여유공간)
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.12),
              child: const ModeSelectionSection(),
            ),
          ),
        ],
      ),
    );
  }
}

