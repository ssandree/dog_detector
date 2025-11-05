// lib/core/providers/network_provider.dart
// 네트워크 연결 상태 관리 Provider
// - 실시간 연결 변화 감지
// - 현재 연결 여부와 상세 상태 모두 제공

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 스트림은 List<ConnectivityResult> 반환
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// 현재 연결 상태 한 번 확인
final isNetworkConnectedProvider = FutureProvider<bool>((ref) async {
  final result = await Connectivity().checkConnectivity(); // ConnectivityResult
  return result != ConnectivityResult.none;
});
