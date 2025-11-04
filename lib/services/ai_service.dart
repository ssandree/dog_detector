// lib/services/ai_service.dart
// AI 실시간 감정 분석 서비스
// WebSocket 연결, 프레임 전송, 감정·객체 결과 수신 담당

import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/exceptions.dart';

class AiService {
  WebSocketChannel? _channel;
  bool get isConnected => _channel != null;

  Future<void> connect({required String url}) async {
    if (_channel != null) return;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'WebSocket 연결에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void sendFrame(Uint8List bytes) {
    if (_channel == null) {
      throw NetworkException('WebSocket이 연결되지 않았습니다.');
    }
    try {
      final data = {
        "type": "frame",
        "image": base64Encode(bytes),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
      _channel!.sink.add(jsonEncode(data));
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '프레임 전송에 실패했습니다: ${e.toString()}',
        e,
      );
    }
  }

  Stream<Map<String, dynamic>> listenResults() {
    if (_channel == null) {
      throw NetworkException('WebSocket이 연결되지 않았습니다.');
    }
    return _channel!.stream.map((event) {
      try {
        final res = jsonDecode(event as String) as Map<String, dynamic>;
        return {
          'label': res['label'],
          'prob': res['prob'],
          'dogDetected': res['dogDetected'] ?? (res['object'] == 'dog'),
        };
      } catch (e) {
        throw DataException(
          '응답 데이터 파싱에 실패했습니다: ${e.toString()}',
          e,
        );
      }
    });
  }
}
