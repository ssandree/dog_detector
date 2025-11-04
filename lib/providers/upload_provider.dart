// lib/providers/upload_provider.dart
// 업로드 상태 관리
// 업로드 진행, 성공, 실패 상태를 UI에 반영

import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/upload_service.dart';
import '../data/repositories/upload_repository.dart';

enum UploadStatus { idle, uploading, success, error }

class UploadState {
  final UploadStatus status;
  final String? error;
  final String? filePath;

  const UploadState({
    this.status = UploadStatus.idle,
    this.error,
    this.filePath,
  });

  UploadState copyWith({
    UploadStatus? status,
    String? error,
    String? filePath,
  }) {
    return UploadState(
      status: status ?? this.status,
      error: error ?? this.error,
      filePath: filePath ?? this.filePath,
    );
  }
}

class UploadNotifier extends Notifier<AsyncValue<UploadState>> {
  late final UploadService _service;
  final _repository = UploadRepository();

  @override
  AsyncValue<UploadState> build() {
    _service = ref.watch(uploadServiceProvider);
    return const AsyncValue.data(UploadState());
  }

  Future<void> uploadFile(
    File file, {
    required String emotion,
    required double probability,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.handleUpload(file);
      await _repository.saveUploadLog(
        emotion: emotion,
        probability: probability,
        filePath: file.path,
      );
      state = AsyncValue.data(UploadState(
        status: UploadStatus.success,
        filePath: file.path,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> retryPending() async {
    state = const AsyncValue.loading();
    try {
      await _service.retryPending();
      state = const AsyncValue.data(UploadState(status: UploadStatus.success));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(UploadState());
  }
}

// UploadService Provider
final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});

final uploadProvider = NotifierProvider<UploadNotifier, AsyncValue<UploadState>>(UploadNotifier.new);
