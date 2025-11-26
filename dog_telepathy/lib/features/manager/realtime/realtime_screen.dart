import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/app_constants.dart';
import 'widgets/video_player_section.dart';
import 'widgets/camera_info_section.dart';
import 'widgets/today_activity_chart.dart';

// 실시간 감정·객체 분석 결과 스트리밍 화면
// WebSocket을 통해 수신된 감정(label, prob)과 객체 탐지, 녹화·업로드 상태를 표시
class RealtimeScreen extends ConsumerStatefulWidget {
  const RealtimeScreen({super.key});

  @override
  ConsumerState<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends ConsumerState<RealtimeScreen> {
  int _selectedCameraIndex = 0;
  
  // Mock 카메라 데이터
  final List<Map<String, dynamic>> _cameras = [
    {
      'id': '1',
      'name': '카메라 1',
      'dogVisibleDuration': const Duration(hours: 2, minutes: 30),
      'cameraTotalDuration': const Duration(hours: 8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentCamera = _cameras[_selectedCameraIndex];
    final isMultipleCameras = _cameras.length > 1;

    return SingleChildScrollView(
      padding: AppConstants.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 비디오 플레이어 영역
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: VideoPlayerSection(
              cameraId: currentCamera['id'] as String,
              cameraName: currentCamera['name'] as String,
            ),
          ),
          
          // 다중 카메라일 경우 슬라이더
          if (isMultipleCameras) ...[
            AppConstants.h16,
            _buildCameraSlider(),
          ],
          
          AppConstants.h20,
          
          // 카메라 정보 섹션
          CameraInfoSection(
            cameraId: currentCamera['id'] as String,
            dogVisibleDuration: currentCamera['dogVisibleDuration'] as Duration,
            cameraTotalDuration: currentCamera['cameraTotalDuration'] as Duration,
          ),
          
          AppConstants.h20,
          
          // 오늘 활동 그래프
          const TodayActivityChart(),
          
          AppConstants.h20,
          
          // 연결 상태 표시
          const Text(
            '실시간 연결 기능이 임시 비활성화되었습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey6,
              fontSize: AppConstants.smallFontSize + 2,
            ),
          ),
          AppConstants.h20,
        ],
      ),
    );
  }

  Widget _buildCameraSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '카메라 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.grey9,
              ),
            ),
            Text(
              '${_selectedCameraIndex + 1} / ${_cameras.length}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _selectedCameraIndex > 0
                  ? () => setState(() => _selectedCameraIndex--)
                  : null,
              color: AppColors.green6,
            ),
            Expanded(
              child: Slider(
                value: _selectedCameraIndex.toDouble(),
                min: 0,
                max: (_cameras.length - 1).toDouble(),
                divisions: _cameras.length - 1,
                label: _cameras[_selectedCameraIndex]['name'] as String,
                activeColor: AppColors.green6,
                onChanged: (value) {
                  setState(() {
                    _selectedCameraIndex = value.toInt();
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _selectedCameraIndex < _cameras.length - 1
                  ? () => setState(() => _selectedCameraIndex++)
                  : null,
              color: AppColors.green6,
            ),
          ],
        ),
        Center(
          child: Text(
            _cameras[_selectedCameraIndex]['name'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.green6,
            ),
          ),
        ),
      ],
    );
  }
}

