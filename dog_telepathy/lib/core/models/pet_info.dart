class PetInfo {
  final int? petId;
  final int? userId;

  final String name;
  final String? breed;
  final DateTime? birthDate;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final String? photoUrl;

  PetInfo({
    this.petId,
    this.userId,
    required this.name,
    this.breed,
    this.birthDate,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.photoUrl,
  });

  /// API 응답 & 로컬 저장 JSON → 모델 변환
  factory PetInfo.fromJson(Map<String, dynamic> json) {
    return PetInfo(
      petId: json['pet_id'] as int?,
      userId: json['user_id'] as int?,
      name: json['name'] as String,
      breed: json['breed'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
    );
  }

  /// 로컬 저장용 직렬화
  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'birth_date': birthDate != null
          ? "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}"
          : null,
      'age': age,
      'gender': gender,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'photo_url': photoUrl,
    };
  }

  /// API 요청용 JSON
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      if (breed != null) 'breed': breed,
      if (birthDate != null)
        'birth_date':
            "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
  }

  PetInfo copyWith({
    int? petId,
    int? userId,
    String? name,
    String? breed,
    DateTime? birthDate,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
  }) {
    return PetInfo(
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
