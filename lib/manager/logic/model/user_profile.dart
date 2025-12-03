class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? name;
  final int? age;
  final String? phoneNumber;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.name,
    this.age,
    this.phoneNumber,
  });

  UserProfile copyWith({
    int? userId,
    String? username,
    String? email,
    String? name,
    int? age,
    String? phoneNumber,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      age: json['age'] as int?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'phone_number': phoneNumber,
    };
  }
}

