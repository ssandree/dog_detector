class AuthInfo {
  final String id;
  final String email;
  final String name;
  final String accessToken;
  final String refreshToken;

  const AuthInfo({
    required this.id,
    required this.email,
    required this.name,
    required this.accessToken,
    required this.refreshToken,
  });

  // 불변 객체 복제용
  AuthInfo copyWith({
    String? id,
    String? email,
    String? name,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // JSON 역직렬화
  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: json['name'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  @override
  String toString() {
    return 'AuthInfo(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthInfo &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }
}

