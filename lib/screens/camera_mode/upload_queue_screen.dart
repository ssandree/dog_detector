// lib/screens/camera_mode/upload_queue_screen.dart
// 업로드 대기 파일 관리 화면
// - pending_uploads 폴더 내 파일 목록 표시
// - 수동 업로드 재시도 및 개별 삭제 기능

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/utils/path_util.dart';
import '../../core/services/upload_service.dart';

class UploadQueueScreen extends HookConsumerWidget {
  const UploadQueueScreen({super.key});

  // 모든 보류 파일 업로드 재시도
  Future<void> _retryAll(BuildContext context) async {
    await UploadService.instance.retryPending();

    // context 유효성 확인(async gap 대응)
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('보류 파일 업로드 재시도 완료')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('업로드 대기 파일')),
      body: FutureBuilder<List<File>>(
        future: PathUtil.listPendingFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final files = snapshot.data ?? [];
          if (files.isEmpty) {
            return const Center(child: Text('대기 파일 없음'));
          }

          return ListView.separated(
            itemCount: files.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final name = files[index].uri.pathSegments.last;
              return ListTile(
                title: Text(name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await files[index].delete();

                    // context 유효성 확인(async gap 대응)
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name 삭제 완료')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _retryAll(context),
        child: const Icon(Icons.cloud_upload),
      ),
    );
  }
}
