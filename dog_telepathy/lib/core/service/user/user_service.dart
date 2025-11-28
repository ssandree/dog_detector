import '../../models/user_profile.dart';

abstract class UserService {
  Future<UserProfile> fetchCurrentUser();
}

