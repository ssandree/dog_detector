/// 카메라 정보 모델
class CameraInfo {
  final String id;
  final String name;
  final Duration dogVisibleDuration;
  final Duration cameraTotalDuration;

  const CameraInfo({
    required this.id,
    required this.name,
    required this.dogVisibleDuration,
    required this.cameraTotalDuration,
  });

  /// Mock 데이터 생성 (실제로는 서비스에서 가져올 예정)
  static List<CameraInfo> getMockCameras() {
    return [
      const CameraInfo(
        id: '1',
        name: '거실 카메라',
        dogVisibleDuration: Duration(hours: 2, minutes: 30, seconds: 45),
        cameraTotalDuration: Duration(hours: 8, minutes: 15, seconds: 20),
      ),
      // 다중 카메라 테스트를 위해 주석 해제
      // const CameraInfo(
      //   id: '2',
      //   name: '주방 카메라',
      //   dogVisibleDuration: Duration(hours: 1, minutes: 15, seconds: 30),
      //   cameraTotalDuration: Duration(hours: 6, minutes: 45, seconds: 10),
      // ),
    ];
  }
}

