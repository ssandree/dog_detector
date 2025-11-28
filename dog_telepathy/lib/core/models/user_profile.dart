class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? name;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.name,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}

