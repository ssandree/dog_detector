import 'dart:io';
import '../../../models/event_info.dart';

/// 이벤트 관련 비즈니스 로직을 처리하는 Service 인터페이스
abstract class EventService {
  /// 영상 업로드 및 이벤트 생성
  /// 
  /// [file]: 업로드할 영상 파일
  /// [petId]: 반려동물 ID
  /// [deviceId]: 디바이스 ID
  /// [startTime]: 영상 시작 시간
  /// [videoDurationSec]: 영상 길이 (초)
  /// 반환값: 생성된 EventInfo 객체
  /// 예외: NetworkException, ValidationException
  Future<EventInfo> uploadEvent({
    required File file,
    required int petId,
    required int deviceId,
    required DateTime startTime,
    required int videoDurationSec,
  });

  /// 반려동물별 이벤트 목록 조회
  /// 
  /// [petId]: 반려동물 ID
  /// [skip]: 건너뛸 레코드 수 (페이지네이션)
  /// [limit]: 반환할 최대 레코드 수
  /// 반환값: EventInfo 리스트
  /// 예외: NetworkException, DataException
  Future<List<EventInfo>> getPetEvents({
    required int petId,
    int skip = 0,
    int limit = 100,
  });
}

