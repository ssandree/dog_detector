// lib/core/providers/network_provider.dart
// 네트워크 연결 상태 관리 Provider
// - 실시간 연결 변화 감지
// - 현재 연결 여부와 상세 상태 모두 제공

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 네트워크 상태 스트림 Provider
final connectivityStreamProvider =
    StreamProvider<ConnectivityResult>((ref) async* {
  await for (final results in Connectivity().onConnectivityChanged) {
    // results는 List<ConnectivityResult>
    yield results.isNotEmpty ? results.first : ConnectivityResult.none;
  }
});

// 현재 연결 여부 Provider
final isNetworkConnectedProvider = FutureProvider<bool>((ref) async {
  final results = await Connectivity().checkConnectivity();
  // checkConnectivity()도 List<ConnectivityResult> 반환
  return results.isNotEmpty && results.first != ConnectivityResult.none;
});
