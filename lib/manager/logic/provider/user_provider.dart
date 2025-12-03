import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/user_profile.dart';
import '../service/remote_user_service.dart';
import '../service/user_service.dart';
import '../../../core/network/dio_client.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(apiDioProvider);
  return RemoteUserService(dio);
});

final currentUserProvider = FutureProvider<UserProfile>((ref) async {
  final service = ref.read(userServiceProvider);
  return service.fetchCurrentUser();
});

