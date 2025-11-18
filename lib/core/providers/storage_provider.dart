import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../storage/local_storage_repository.dart';

/// LocalStorageRepository Provider
/// 여러 Provider에서 공통으로 사용되는 저장소 인스턴스를 제공합니다.
final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  return LocalStorageRepository();
});

