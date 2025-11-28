import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/user_profile.dart';
import '../service/user/remote_user_service.dart';
import '../service/user/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return RemoteUserService();
});

final currentUserProvider = FutureProvider<UserProfile>((ref) async {
  final service = ref.read(userServiceProvider);
  return service.fetchCurrentUser();
});

