// lib/features/webrtc/model/webrtc_config.dart

class WebRtcConfig {
  final Map<String, dynamic> raw;

  WebRtcConfig({required this.raw});

  factory WebRtcConfig.fromJson(Map<String, dynamic> json) {
    return WebRtcConfig(raw: json);
  }

  Map<String, dynamic> toPeerConnectionConfig() {
    final List<dynamic> servers =
        (raw['iceServers'] as List?) ?? (raw['ice_servers'] as List?) ?? [];

    final iceServers = servers.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final urls = m['urls'] ?? m['url'];
      return <String, dynamic>{
        'urls': urls,
        if (m['username'] != null) 'username': m['username'],
        if (m['credential'] != null) 'credential': m['credential'],
      };
    }).toList();

    return <String, dynamic>{
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
    };
  }
}
