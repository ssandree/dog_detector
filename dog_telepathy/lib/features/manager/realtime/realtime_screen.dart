import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_constants.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/provider/current_pet_provider.dart';
import '../../../core/widgets/base_scaffold.dart';
import 'realtime_types.dart';
import 'widgets/calendar_mini_panel.dart'; // ignore: unused_import
import 'widgets/fullscreen_overlay_controls.dart';
import 'widgets/recent_emotion.dart';
import 'widgets/remote_video_view.dart';
import 'widgets/stream_control_overlay.dart';
import 'widgets/stream_summary_bar.dart';
import 'widgets/swipe_overlay.dart';

class RealtimeScreen extends ConsumerStatefulWidget {
  const RealtimeScreen({super.key});

  @override
  ConsumerState<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends ConsumerState<RealtimeScreen> {
  final Map<String, Duration> _cameraUsage = {
    'CAM-01': const Duration(hours: 2, minutes: 12),
    'CAM-02': const Duration(hours: 1, minutes: 45),
    'CAM-03': const Duration(hours: 3, minutes: 5),
  };
  final Duration _totalUptime = const Duration(hours: 142, minutes: 19);

  late final List<String> _cameraIds;
  int _currentCameraIndex = 0;
  StreamConnectionState _connectionState = StreamConnectionState.connecting;
  bool _isPaused = false;
  bool _soundMuted = true;
  bool _micEnabled = false;
  bool _isFullscreen = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFrozen = false;
  int _videoWidth = 1280;

  Timer? _connectionTimer;

  String get _selectedCameraId => _cameraIds[_currentCameraIndex];

  @override
  void initState() {
    super.initState();
    _cameraIds = const ['CAM-01', 'CAM-02', 'CAM-03'];
    // _seedEmotionMap();
    _simulateConnection();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    if (_isFullscreen) {
      _exitFullscreen();
    }
    super.dispose();
  }

  void _simulateConnection() {
    _connectionTimer?.cancel();
    setState(() {
      _connectionState = StreamConnectionState.connecting;
      _isLoading = true;
      _hasError = false;
      _isFrozen = false;
    });

    _connectionTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _connectionState = StreamConnectionState.connected;
        _isLoading = false;
        _isPaused = false;
      });
    });
  }

  void _handleSwipe(bool isNext) {
    if (_connectionState == StreamConnectionState.connecting ||
        _connectionState == StreamConnectionState.reconnecting) {
      return;
    }

    if (_cameraIds.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('전환 가능한 다른 카메라가 없습니다.')));
      return;
    }

    setState(() {
      _currentCameraIndex = isNext
          ? (_currentCameraIndex + 1) % _cameraIds.length
          : (_currentCameraIndex - 1 + _cameraIds.length) % _cameraIds.length;
      _connectionState = StreamConnectionState.reconnecting;
      _isLoading = true;
    });

    _connectionTimer?.cancel();
    _connectionTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _connectionState = StreamConnectionState.connected;
        _isLoading = false;
      });
    });
  }

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _exitFullscreen();
      return;
    }

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    setState(() => _isFullscreen = true);
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    setState(() => _isFullscreen = false);
  }

  void _togglePause() {
    if (_connectionState != StreamConnectionState.connected) return;
    setState(() => _isPaused = !_isPaused);
  }

  void _toggleMute() {
    if (_connectionState != StreamConnectionState.connected) return;
    setState(() => _soundMuted = !_soundMuted);
  }

  void _toggleMic() {
    if (_connectionState != StreamConnectionState.connected) return;
    setState(() => _micEnabled = !_micEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final currentPet = ref.watch(currentPetProvider);
    final petId = currentPet?.petId;

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
        children: [
              RemoteVideoView(
                isLoading: _isLoading,
                hasError: _hasError,
                isFrozen: _isFrozen,
                isPaused: _isPaused,
                videoWidth: _videoWidth,
              ),
              FullscreenOverlayControls(
                cameraId: _selectedCameraId,
                connectionState: _connectionState,
                videoWidth: _videoWidth,
                soundMuted: _soundMuted,
                micEnabled: _micEnabled,
                onExitFullscreen: _toggleFullscreen,
                onToggleMute: _toggleMute,
                onToggleMic: _toggleMic,
              ),
            ],
          ),
      ),
    );
  }

    return BaseScaffold(
      useSafeArea: true,
      body: Padding(
        padding: EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  RemoteVideoView(
                    isLoading: _isLoading,
                    hasError: _hasError,
                    isFrozen: _isFrozen,
                    isPaused: _isPaused,
                    videoWidth: _videoWidth,
                  ),
                  StreamControlOverlay(
                    connectionState: _connectionState,
                    isPaused: _isPaused,
                    soundMuted: _soundMuted,
                    micEnabled: _micEnabled,
                    onTogglePause: _togglePause,
                    onToggleMute: _toggleMute,
                    onToggleMic: _toggleMic,
                    onToggleFullscreen: _toggleFullscreen,
                  ),
                  SwipeOverlay(
                    enabled: _cameraIds.length > 1,
                    onSwipeLeft: () => _handleSwipe(true),
                    onSwipeRight: () => _handleSwipe(false),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.defaultSpacing),
            StreamSummaryBar(
              cameraId: _selectedCameraId,
              usageDuration: _cameraUsage[_selectedCameraId] ?? Duration.zero,
              totalUptime: _totalUptime,
              connectionState: _connectionState,
              videoWidth: _videoWidth,
            ),
            SizedBox(height: AppConstants.defaultSpacing),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    petId == null
                        ? const _RecentEmotionPlaceholder()
                        : RecentEmotionPanel(petId: petId),
                    // SizedBox(height: AppConstants.defaultSpacing),
                    // CalendarMiniPanel(
                    //   currentMonth: _currentMonth,
                    //   selectedDate: _selectedDate,
                    //   emotionMap: _emotionMap,
                    //   onChangeMonth: _changeMonth,
                    //   onSelectDate: _selectDate,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEmotionPlaceholder extends StatelessWidget {
  const _RecentEmotionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '현재 감정 정보를 불러오려면 반려견을 등록해주세요.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey9,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '반려견 등록 후 실시간 분석 결과를 확인할 수 있습니다.',
            style: TextStyle(fontSize: 13, color: AppColors.grey6),
          ),
        ],
      ),
    );
  }
}
