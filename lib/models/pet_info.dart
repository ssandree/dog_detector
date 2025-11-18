class PetInfo {
  // API 응답 필드
  final int? petId;
  final int? userId;
  
  // API 요청/응답 필드
  final String name;
  final String? breed;
  final DateTime? birthDate; // API: birth_date (YYYY-MM-DD)
  final double? weightKg; // API: weight_kg
  final double? heightCm; // API: height_cm
  final String? photoUrl; // API: photo_url
  
  // UI 전용 필드 (API에 포함되지 않음)
  final int? age; // birthDate로부터 계산
  final String? gender; // UI에서만 사용

  // 생성자
  PetInfo({
    this.petId,
    this.userId,
    required this.name,
    this.breed,
    this.birthDate,
    this.weightKg,
    this.heightCm,
    this.photoUrl,
    // UI 전용 필드
    this.age,
    this.gender,
  });
  
  // 하위 호환성을 위한 생성자 (기존 코드 지원)
  factory PetInfo.fromLegacy({
    required String name,
    int? age,
    DateTime? birthday,
    double? weight,
    String? breed,
    String? gender,
    String? photoUrl,
  }) {
    return PetInfo(
      name: name,
      breed: breed,
      birthDate: birthday,
      weightKg: weight,
      photoUrl: photoUrl,
      age: age,
      gender: gender,
    );
  }

  // 불변 객체 복제용
  PetInfo copyWith({
    int? petId,
    int? userId,
    String? name,
    String? breed,
    DateTime? birthDate,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
    int? age,
    String? gender,
  }) {
    return PetInfo(
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
  
  // 하위 호환성을 위한 copyWith
  PetInfo copyWithLegacy({
    String? name,
    int? age,
    DateTime? birthday,
    double? weight,
    String? breed,
    String? gender,
    String? photoUrl,
  }) {
    return PetInfo(
      petId: petId,
      userId: userId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthday ?? this.birthDate,
      weightKg: weight ?? this.weightKg,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  // JSON 직렬화 (로컬 저장용 - 기존 형식 유지)
  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'birth_date': birthDate != null 
          ? '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}'
          : null,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'photo_url': photoUrl,
      // UI 전용 필드 (로컬 저장용)
      'age': age,
      'gender': gender,
    };
  }
  
  // API 요청용 JSON 직렬화 (snake_case)
  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
      'name': name,
    };
    
    if (breed != null) json['breed'] = breed;
    if (birthDate != null) {
      json['birth_date'] = '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';
    }
    if (weightKg != null) json['weight_kg'] = weightKg;
    if (heightCm != null) json['height_cm'] = heightCm;
    if (photoUrl != null) json['photo_url'] = photoUrl;
    
    return json;
  }

  // JSON 역직렬화 (API 응답 및 로컬 저장 형식 모두 지원)
  factory PetInfo.fromJson(Map<String, dynamic> json) {
    try {
      // API 응답 형식 (snake_case) 또는 로컬 저장 형식 지원
      final petId = json['pet_id'] as int? ?? json['petId'] as int?;
      final userId = json['user_id'] as int? ?? json['userId'] as int?;
      final name = json['name'] as String? ?? '';
      
      // birth_date 또는 birthday 파싱
      DateTime? birthDate;
      if (json['birth_date'] != null) {
        birthDate = DateTime.tryParse(json['birth_date'] as String);
      } else if (json['birthday'] != null) {
        birthDate = DateTime.tryParse(json['birthday'] as String);
      }
      
      // weight_kg 또는 weight 파싱
      double? weightKg;
      if (json['weight_kg'] != null) {
        weightKg = (json['weight_kg'] as num?)?.toDouble();
      } else if (json['weight'] != null) {
        weightKg = (json['weight'] as num?)?.toDouble();
      }
      
      final heightCm = (json['height_cm'] as num?)?.toDouble() ?? (json['heightCm'] as num?)?.toDouble();
      final breed = json['breed'] as String?;
      final photoUrl = json['photo_url'] as String? ?? json['photoUrl'] as String?;
      
      // UI 전용 필드 (로컬 저장용)
      final age = json['age'] as int?;
      final gender = json['gender'] as String?;
      
      // birthDate로부터 age 계산 (age가 없고 birthDate가 있으면)
      int? calculatedAge = age;
      if (calculatedAge == null && birthDate != null) {
        final now = DateTime.now();
        calculatedAge = now.year - birthDate.year;
        if (now.month < birthDate.month || 
            (now.month == birthDate.month && now.day < birthDate.day)) {
          calculatedAge--;
        }
      }
      
      return PetInfo(
        petId: petId,
        userId: userId,
        name: name,
        breed: breed,
        birthDate: birthDate,
        weightKg: weightKg,
        heightCm: heightCm,
        photoUrl: photoUrl,
        age: calculatedAge,
        gender: gender,
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse PetInfo from JSON: $e',
        json,
      );
    }
  }
  
  // 하위 호환성을 위한 getter (기존 코드 지원)
  DateTime? get birthday => birthDate;
  double? get weight => weightKg;

  @override
  String toString() {
    return 'PetInfo(petId: $petId, userId: $userId, name: $name, breed: $breed, birthDate: $birthDate, weightKg: $weightKg, heightCm: $heightCm, photoUrl: $photoUrl, age: $age, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetInfo &&
        other.petId == petId &&
        other.userId == userId &&
        other.name == name &&
        other.breed == breed &&
        other.birthDate == birthDate &&
        other.weightKg == weightKg &&
        other.heightCm == heightCm &&
        other.photoUrl == photoUrl &&
        other.age == age &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return petId.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        breed.hashCode ^
        birthDate.hashCode ^
        weightKg.hashCode ^
        heightCm.hashCode ^
        photoUrl.hashCode ^
        age.hashCode ^
        gender.hashCode;
  }
}