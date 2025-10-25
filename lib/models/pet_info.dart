class PetInfo {
   final String name;
   final int? age;
   final DateTime? birthday;
   final double weight;
   final String? breed;
   final String? gender;
   final String? photoUrl;

   // 생성자
   PetInfo({
      required this.name,
      this.age,
      this.birthday,
      required this.weight,
      this.breed,
      this.gender,
      this.photoUrl,
   });

   // 불변 객체 복제용
   PetInfo copyWith({
      String? name,
      int? age,
      DateTime? birthday,
      double? weight,
      String? breed,
      String? gender,
      String? photoUrl,
   }) {
      return PetInfo(
         name: name ?? this.name,
         age: age ?? this.age,
         birthday: birthday ?? this.birthday,
         weight: weight ?? this.weight,
         breed: breed ?? this.breed,
         gender: gender ?? this.gender,
         photoUrl: photoUrl ?? this.photoUrl,
      );
   }

   // JSON 직렬화
   Map<String, dynamic> toJson() {
      return {
         'name': name,
         'age': age,
         'birthday': birthday?.toIso8601String(),
         'weight': weight,
         'breed': breed,
         'gender': gender,
         'photoUrl': photoUrl,
      };
   }

   // JSON 역직렬화
   factory PetInfo.fromJson(Map<String, dynamic> json) {
      return PetInfo(
         name: json['name'] as String,
         age: json['age'] as int?,
         birthday: json['birthday'] != null 
            ? DateTime.parse(json['birthday'] as String)
            : null,
         weight: (json['weight'] as num).toDouble(),
         breed: json['breed'] as String?,
         gender: json['gender'] as String?,
         photoUrl: json['photoUrl'] as String?,
      );
   }

   @override
   String toString() {
      return 'PetInfo(name: $name, age: $age, birthday: $birthday, weight: $weight, breed: $breed, gender: $gender, photoUrl: $photoUrl)';
   }

   @override
   bool operator ==(Object other) {
      if (identical(this, other)) return true;
      return other is PetInfo &&
         other.name == name &&
         other.age == age &&
         other.birthday == birthday &&
         other.weight == weight &&
         other.breed == breed &&
         other.gender == gender &&
         other.photoUrl == photoUrl;
   }

   @override
   int get hashCode {
      return name.hashCode ^
         age.hashCode ^
         birthday.hashCode ^
         weight.hashCode ^
         breed.hashCode ^
         gender.hashCode ^
         photoUrl.hashCode;
   }
}