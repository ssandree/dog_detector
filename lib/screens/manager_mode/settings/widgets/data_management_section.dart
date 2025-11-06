import '../../../../core/index_export.dart';
import 'settings_section.dart';
import 'setting_row.dart';

/// 데이터 관리 섹션
class DataManagementSection extends StatelessWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: '데이터 관리',
      children: [
        ActionRow(
          title: '저장된 영상 보기',
          subtitle: '저장한 영상을 볼 수 있어요',
          onTap: () => _showSnack(context, '저장된 영상을 준비 중입니다.'),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

