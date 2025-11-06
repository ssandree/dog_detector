import '../../core/index_export.dart';

/// 녹화 제어 화면
///
/// - BaseScaffold 미사용, 일반 Scaffold 사용

class CameraRecordScreen extends StatefulWidget {
  const CameraRecordScreen({super.key});
  @override
  State<CameraRecordScreen> createState() => _CameraRecordScreenState();
}

class _CameraRecordScreenState extends State<CameraRecordScreen> {
  bool isRecording = false;
  bool isBusy = false;

  Future<void> onToggle() async {
    if (isBusy) return;
    setState(() => isBusy = true);
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      setState(() => isRecording = !isRecording);
      final message = isRecording ? '녹화 시작' : '녹화 중지';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Record')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isRecording ? '녹화 중...' : '대기 중',
              style: const TextStyle(fontSize: 18),
            ),
            AppConstants.h16,
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: isBusy ? null : onToggle,
                child: Text(isRecording ? '녹화 중지' : '녹화 시작'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
