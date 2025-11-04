// lib/screens/camera_mode/camera_home_screen.dart
// 카메라 홈 스크린
// - 권한 요청 후 카메라 초기화 및 프리뷰 표시
// - 초기화 중 로딩 및 에러 상태 처리
// - 연결된 카메라 프리뷰를 GridView(2x2)로 표시
// - 화면 종료 시 자원 해제

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:camera/camera.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/services/camera_service.dart';
import '../../core/utils/permission_util.dart';

class CameraHomeScreen extends ConsumerStatefulWidget {
  const CameraHomeScreen({super.key});

  @override
  ConsumerState<CameraHomeScreen> createState() => _CameraHomeScreenState();
}

class _CameraHomeScreenState extends ConsumerState<CameraHomeScreen> {
  @override
  void dispose() {
    CameraService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(cameraInitProvider);
    final isReady = ref.watch(cameraReadyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Control')),
      body: FutureBuilder<bool>(
        future: PermissionUtil.requestAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != true) {
            return const Center(child: Text('권한이 필요합니다'));
          }

          return initState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('카메라 초기화 실패: $err')),
            data: (_) {
              final controllers = ref.watch(cameraControllersProvider);
              if (!isReady || controllers.isEmpty) {
                return const Center(child: Text('카메라가 준비되지 않았습니다'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controllers.length,
                itemBuilder: (context, i) {
                  final controller = controllers[i];
                  if (!controller.value.isInitialized) {
                    return const SizedBox.shrink();
                  }
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
