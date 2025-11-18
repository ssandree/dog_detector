// Core Exports - 전역적으로 많이 사용되는 파일들
// 이 파일을 import하면 프로젝트의 핵심 요소들을 한 번에 가져올 수 있습니다.

// Flutter Core
export 'package:flutter/material.dart';

// Routing
export 'package:go_router/go_router.dart';

// State Management
export 'package:hooks_riverpod/hooks_riverpod.dart';

// Constants
export 'app_constants.dart';

// Theme
export '../theme/app_colors.dart';
export '../theme/app_theme.dart';

// Common Widgets
export '../widgets/widget_export.dart';

// App Core
export 'app_routes.dart';
export 'providers/notification_provider.dart';

// Providers
export 'providers/pet_provider.dart';
export 'providers/alarm_provider.dart';
export 'providers/home_provider.dart';
export 'providers/report_provider.dart';
export 'providers/auth_provider.dart';
export 'providers/mode_provider.dart';

// Models
export '../models/auth_info.dart';
export '../models/pet_info.dart';
export '../models/notification_message.dart';
