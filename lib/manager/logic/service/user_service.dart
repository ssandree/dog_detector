import '../model/user_profile.dart';

abstract class UserService {
  Future<UserProfile> fetchCurrentUser();
  Future<UserProfile> updateCurrentUser(UserProfile user);
}

