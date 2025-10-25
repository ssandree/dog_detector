import 'package:flutter/foundation.dart';
import '../models/pet_info.dart';
import '../services/pet_service.dart';

// 클래스: Provider
class PetProvider extends ChangeNotifier {
  PetInfo? _petInfo;
  bool _isLoading = false;
  String? _error;
  final PetService _petService = PetService();

  PetInfo? get petInfo => _petInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPet => _petInfo != null;

  void setPetInfo(PetInfo petInfo) {
    _petInfo = petInfo;
    notifyListeners();
  }

  void setPetInfoLocal(PetInfo petInfo) {
    _petInfo = petInfo;
    notifyListeners();
  }

  void clearPetInfo() {
    _petInfo = null;
    _error = null;
    notifyListeners();
  }

  // 에러 상태 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 상태 설정
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // 백엔드에서 반려동물 정보 조회
  Future<void> loadPetInfo(String petId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final petInfo = await _petService.getPetInfo(petId);
      _petInfo = petInfo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 백엔드에 반려동물 정보 저장
  Future<void> savePetInfo(PetInfo petInfo) async {
    try {
      _setLoading(true);
      _error = null;
      
      final savedPetInfo = await _petService.createPetInfo(petInfo);
      _petInfo = savedPetInfo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 백엔드에서 반려동물 정보 업데이트
  Future<void> updatePetInfo(String petId, PetInfo petInfo) async {
    try {
      _setLoading(true);
      _error = null;
      
      final updatedPetInfo = await _petService.updatePetInfo(petId, petInfo);
      _petInfo = updatedPetInfo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 백엔드에서 반려동물 정보 삭제
  Future<void> deletePetInfo(String petId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _petService.deletePetInfo(petId);
      _petInfo = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 생일이 변경될 때 나이 자동 계산
  void updateBirthday(DateTime? birthday) {
    if (_petInfo == null) return;
    
    _petInfo = _petInfo!.copyWith(
      birthday: birthday,
      age: birthday != null ? _calculateAgeFromBirthday(birthday) : null,
    );
    notifyListeners();
  }

  // 나이가 변경될 때 생일 추정
  void updateAge(int? age) {
    if (_petInfo == null) return;
    
    _petInfo = _petInfo!.copyWith(
      age: age,
      birthday: age != null ? _estimateBirthdayFromAge(age) : null,
    );
    notifyListeners();
  }

  int? _calculateAgeFromBirthday(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || 
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  DateTime? _estimateBirthdayFromAge(int age) {
    final now = DateTime.now();
    return DateTime(now.year - age, now.month, now.day);
  }
}
