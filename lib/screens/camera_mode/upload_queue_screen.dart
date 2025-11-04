import 'dart:io';
import '../../core/index_export.dart';
import '../../utils/path_utils.dart';
import '../../providers/upload_provider.dart' show uploadProvider, UploadStatus;

/// 업로드 대기 파일 관리 화면
/// 
/// 역할:
/// - pending_uploads 폴더 내 파일 목록 표시
/// - 수동 업로드 재시도 및 개별 삭제 기능
/// - UploadService 및 PathUtil 연동
class UploadQueueScreen extends ConsumerStatefulWidget {
  const UploadQueueScreen({super.key});

  @override
  ConsumerState<UploadQueueScreen> createState() => _UploadQueueScreenState();
}

class _UploadQueueScreenState extends ConsumerState<UploadQueueScreen> {
  List<File> _pendingFiles = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final files = await PathUtil.listPendingFiles();
      if (mounted) {
        setState(() {
          _pendingFiles = files;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          '파일 목록을 불러오는데 실패했습니다: ${e.toString()}',
        );
      }
    }
  }

  /// 모든 보류 파일 업로드 재시도
  Future<void> _retryAll() async {
    final uploadState = ref.read(uploadProvider);
    if (uploadState.isLoading) return;

    await ref.read(uploadProvider.notifier).retryPending();

    if (!mounted) return;
    final newState = ref.read(uploadProvider);
    newState.when(
      data: (state) {
        if (state.status == UploadStatus.success) {
          AppToast.success(context, '보류 파일 업로드 재시도 완료');
        } else {
          AppToast.error(context, '업로드 실패');
        }
      },
      loading: () {},
      error: (error, stack) {
        AppToast.error(context, '업로드 실패: ${error.toString()}');
      },
    );

    // 파일 목록 새로고침
    await _loadFiles();
  }

  /// 개별 파일 삭제
  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();

      if (!mounted) return;
      final fileName = file.uri.pathSegments.last;
      AppToast.success(
        context,
        '$fileName 삭제 완료',
      );

      // 파일 목록 새로고침
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      AppToast.error(
        context,
        '파일 삭제 실패: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '업로드 대기 파일',
      body: _pendingFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_done,
                    size: AppConstants.largeIconSize * 3,
                    color: AppColors.grey5,
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing),
                  Text(
                    '대기 파일 없음',
                    style: TextStyle(
                      fontSize: AppConstants.titleFontSize - 4,
                      color: AppColors.grey6,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFiles,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.defaultSpacing,
                ),
                itemCount: _pendingFiles.length,
                separatorBuilder: (_, __) => const SizedBox(
                  height: AppConstants.smallSpacing,
                ),
                itemBuilder: (context, index) {
                  final file = _pendingFiles[index];
                  final fileName = file.uri.pathSegments.last;

                  return HorizontalPadding(
                    child: AppCards.basic(
                      padding: const EdgeInsets.all(AppConstants.defaultSpacing),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file,
                                      size: AppConstants.defaultIconSize,
                                      color: AppColors.grey6,
                                    ),
                                    const SizedBox(width: AppConstants.smallSpacing),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: const TextStyle(
                                          fontSize: AppConstants.defaultFontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.smallSpacing),
                                Text(
                                  '업로드 대기 중',
                                  style: TextStyle(
                                    fontSize: AppConstants.smallFontSize,
                                    color: AppColors.grey6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            onPressed: () => _deleteFile(file),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _pendingFiles.isNotEmpty
          ? FloatingActionButton(
              onPressed: _retryAll,
              backgroundColor: AppColors.appBarColor,
              child: const Icon(
                Icons.cloud_upload,
                color: AppColors.white,
              ),
            )
          : null,
    );
  }
}
