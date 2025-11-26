// pet_mock.dart

/// GET /pets/ 응답 Mock 데이터
final List<Map<String, dynamic>> mockPetList = [
  {
    "name": "초코",
    "breed": "푸들",
    "birth_date": "2022-03-15",
    "weight_kg": 4,
    "height_cm": 28,
    "photo_url": "https://mock.server/pets/choco.jpg",
    "pet_id": 1,
    "user_id": 100,
  },
  {
    "name": "몽이",
    "breed": "말티즈",
    "birth_date": "2021-11-02",
    "weight_kg": 3,
    "height_cm": 26,
    "photo_url": "https://mock.server/pets/mong.jpg",
    "pet_id": 2,
    "user_id": 100,
  },
];
