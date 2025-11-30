// lib/features/pet/domain/pet_info.dart

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

  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'breed': breed,
      'birth_date': birthDate != null
          ? "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}"
          : null,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'photo_url': photoUrl,
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
