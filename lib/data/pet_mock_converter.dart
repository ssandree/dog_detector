import '../models/pet_info.dart';

/// Mock 데이터를 Model로 변환하는 헬퍼 클래스
/// 모든 Mock → Model 변환 로직을 한 곳에서 관리
class PetMockConverter {
  PetMockConverter._(); // private 생성자로 인스턴스화 방지

  /// Mock 데이터 Map을 PetInfo로 변환
  /// 
  /// [mockData]: Mock 데이터 Map (pet_mock.dart의 mockPet 항목)
  /// 반환값: PetInfo 객체
  static PetInfo fromMockData(Map<String, dynamic> mockData) {
    final petId = mockData['id'] as int?;
    final registeredAt = mockData['registeredAt'] as String?;
    DateTime? birthDate;
    if (registeredAt != null) {
      birthDate = DateTime.tryParse(registeredAt);
    }
    
    return PetInfo(
      petId: petId,
      name: mockData['name'] as String,
      breed: mockData['breed'] as String?,
      birthDate: birthDate,
      weightKg: 5.5, // mockPet에는 weight가 없으므로 기본값 사용
      photoUrl: mockData['photoUrl'] as String?,
      age: mockData['age'] as int?,
      gender: _convertGender(mockData['gender'] as String?),
    );
  }

  /// Mock 데이터 리스트를 PetInfo 리스트로 변환
  /// 
  /// [mockDataList]: Mock 데이터 리스트
  /// 반환값: PetInfo 리스트
  static List<PetInfo> fromMockDataList(List<Map<String, dynamic>> mockDataList) {
    return mockDataList.map((mockData) => fromMockData(mockData)).toList();
  }

  /// 기본 PetInfo 생성 (fallback용)
  /// Mock 데이터가 없을 때 사용
  static PetInfo createDefault() {
    final birthDate = DateTime.now().subtract(const Duration(days: 365 * 3));
    return PetInfo(
      name: '멍멍이',
      breed: '골든리트리버',
      birthDate: birthDate,
      weightKg: 5.5,
      age: 3,
      gender: '수컷',
      photoUrl: null,
    );
  }

  /// Mock 데이터의 gender를 PetInfo 형식으로 변환
  /// 'male' → '수컷', 'female' → '암컷'
  static String? _convertGender(String? gender) {
    if (gender == null) return null;
    switch (gender.toLowerCase()) {
      case 'male':
        return '수컷';
      case 'female':
        return '암컷';
      default:
        return gender;
    }
  }
}

