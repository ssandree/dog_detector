import '../core/index_export.dart';

/// 앱 전체에서 사용할 기본 Scaffold 위젯
/// 
/// BaseScaffold는 두 가지 모드를 지원합니다:
/// 
/// 1. **일반 모드 (기본)**: 
///    - ScaffoldMode.normal (기본값)
///    - 일반 AppBar를 표시
///    - title, actions, showNotification 등으로 AppBar 구성
///    - body는 SafeArea만 적용
///    - 예시: camera_home_screen.dart, realtime_screen.dart
/// 
/// 2. **Collapsing Header 모드**:
///    - ScaffoldMode.collapsingHeader
///    - customHeader와 headerHeight 필수 제공
///    - SliverAppBar + CustomScrollView 구조 사용
///    - 스크롤 시 헤더가 fade-out 효과로 사라짐
///    - body는 SliverToBoxAdapter로 감싸져서 무한 높이 방지
///    - 예시: manager_home_screen.dart, report_screen.dart
/// 
/// 사용 패턴:
/// - 일반 화면: mode=ScaffoldMode.normal (기본), title 제공
/// - Collapsing Header: mode=ScaffoldMode.collapsingHeader, customHeader + headerHeight 제공
class BaseScaffold extends StatelessWidget {
  /// Scaffold 모드
  final ScaffoldMode mode;

  /// 화면 제목 (일반 모드에서 사용)
  final String? title;

  /// 화면 본문
  final Widget body;

  /// 커스텀 헤더 위젯 (Collapsing Header 모드에서 사용)
  final Widget? customHeader;

  /// 헤더 높이 (Collapsing Header 모드에서 필수)
  final double? headerHeight;

  /// AppBar 색상 테마
  final AppBarThemeType appBarTheme;

  /// 뒤로가기 버튼 표시 여부
  final bool showBackButton;

  /// 뒤로가기 버튼 동작
  final VoidCallback? onBackPressed;

  /// AppBar 액션 버튼들
  final List<Widget>? actions;

  /// AppBar 하단 위젯 (TabBar 등)
  final PreferredSizeWidget? bottom;

  /// TabBar Controller (TabBar를 사용할 경우)
  final TabController? tabController;

  /// TabBar의 탭 리스트
  final List<Tab>? tabs;

  /// 알림 버튼 표시 여부
  final bool showNotification;

  /// 알림 버튼 동작
  final VoidCallback? onNotificationPressed;

  /// SafeArea 적용 여부
  final bool useSafeArea;

  /// Scroll physics
  final ScrollPhysics? scrollPhysics;

  /// Scaffold 배경색
  final Color? backgroundColor;

  /// FloatingActionButton
  final Widget? floatingActionButton;

  /// BottomNavigationBar
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.mode = ScaffoldMode.normal,
    this.title,
    required this.body,
    this.customHeader,
    this.headerHeight,
    this.appBarTheme = AppBarThemeType.primary,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.tabController,
    this.tabs,
    this.showNotification = false,
    this.onNotificationPressed,
    this.useSafeArea = true,
    this.scrollPhysics,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isNormalMode = mode == ScaffoldMode.normal;
    final isCollapsingMode = mode == ScaffoldMode.collapsingHeader;

    // Collapsing Header 모드 검증
    if (isCollapsingMode) {
      assert(
        customHeader != null && headerHeight != null,
        'Collapsing Header 모드에서는 customHeader와 headerHeight가 필수입니다.',
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.defaultBackgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: isNormalMode ? _buildAppBar(context) : null,
      body: _buildBody(context),
    );
  }

  /// Body 구성 로직
  /// 
  /// 두 가지 모드로 분기:
  /// 1. Collapsing Header 모드: mode == ScaffoldMode.collapsingHeader
  ///    - SliverAppBar 기반 구조 사용 (_buildSliverBody 호출)
  ///    - 스크롤 시 헤더가 자연스럽게 사라지는 효과
  /// 
  /// 2. 일반 모드: mode == ScaffoldMode.normal (기본값)
  ///    - SafeArea 적용
  ///    - body가 ScrollView 계열이 아니면 SingleChildScrollView로 자동 감싸기
  ///    - body 내부 패딩 적용
  Widget _buildBody(BuildContext context) {
    // Collapsing Header 모드면 Sliver 기반 구조 사용
    if (mode == ScaffoldMode.collapsingHeader) {
      return _buildSliverBody();
    }

    // 일반 모드 구조
    Widget content = body;

    // body가 ScrollView 계열이 아니면 SingleChildScrollView로 감싸고 패딩 적용
    if (!_isScrollView(content)) {
      content = SingleChildScrollView(
        physics: scrollPhysics ?? const ClampingScrollPhysics(),
        child: Padding(
          padding: AppConstants.smallPadding,
          child: content,
        ),
      );
    } else {
      // 이미 ScrollView인 경우: padding을 내부에 적용
      // SingleChildScrollView인 경우
      if (content is SingleChildScrollView) {
        final scrollView = content as SingleChildScrollView;
        content = SingleChildScrollView(
          key: scrollView.key,
          scrollDirection: scrollView.scrollDirection,
          reverse: scrollView.reverse,
          padding: AppConstants.smallPadding,
          primary: scrollView.primary,
          physics: scrollPhysics ?? scrollView.physics,
          child: scrollView.child,
        );
      }
      // 다른 ScrollView 타입은 그대로 두고 바깥에 패딩 적용하지 않음
      // (각 ScrollView가 자체적으로 패딩을 처리해야 함)
    }

    // SafeArea 적용 (useSafeArea가 true이면)
    // AppBar와 분리하기 위해 SafeArea를 먼저 적용
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }

  /// 위젯이 ScrollView 계열인지 확인
  /// 
  /// SingleChildScrollView, ListView, GridView, CustomScrollView 등
  /// 스크롤 가능한 위젯인지 확인합니다.
  bool _isScrollView(Widget widget) {
    return widget is ScrollView ||
        widget is SingleChildScrollView ||
        widget is ListView ||
        widget is GridView ||
        widget is CustomScrollView ||
        widget is PageView;
  }

  /// SliverAppBar 기반 구조 (Collapsing Header 모드)
  /// 
  /// 이 메서드는 mode == ScaffoldMode.collapsingHeader인 경우 호출됩니다.
  /// 
  /// 구조:
  /// 1. SafeArea: 상단만 적용 (bottom=false로 설정하여 하단 네비게이션 바와 겹치지 않음)
  /// 2. CustomScrollView: Sliver 위젯들을 스크롤할 수 있게 해주는 컨테이너
  ///    - SliverAppBar: collapsing 효과를 위한 헤더
  ///    - SliverToBoxAdapter: body를 Sliver로 변환하여 무한 높이 방지
  /// 
  /// SliverAppBar 설정:
  /// - pinned: false - 스크롤 시 헤더를 고정하지 않음 (완전히 사라짐)
  /// - floating: false - 위로 스크롤해도 헤더가 다시 나타나지 않음
  /// - backgroundColor: transparent - 배경을 투명하게 하여 자연스러운 fade-out 효과
  /// 
  /// Fade-out 효과:
  /// - LayoutBuilder로 현재 높이를 감지
  /// - 스크롤 진행도에 따라 opacity 계산 (0.0 ~ 1.0)
  /// - scrollPercent가 0.5 이상이면 완전 투명 (opacity = 0)
  /// 
  /// 사용 예시:
  /// - manager_home_screen.dart: 홈 화면에서만 collapsing header 사용
  ///   customHeader: _buildHeader() (견심술 로고 + 알림/설정 버튼)
  ///   headerHeight: 120.0
  Widget _buildSliverBody() {
    // SafeArea 완전히 제거하여 상단 간격 없애기
    // 하단 네비게이션 바는 bottomNavigationBar에서 처리됨
    return CustomScrollView(
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      slivers: [
        // Collapsing Header (SliverAppBar)
        SliverAppBar(
          automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 표시 안 함
          expandedHeight: headerHeight!,
          pinned: false, // 스크롤 시 헤더 고정 안 함 (완전히 사라짐)
          floating: false, // 위로 당겨서 다시 표시 안 함
          backgroundColor: Colors.transparent, // 배경 투명하여 자연스러운 효과
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = headerHeight!;
              final currentHeight = constraints.maxHeight;
              // 스크롤 진행도 계산 (0.0: 최상단, 1.0: 완전히 올라감)
              final scrollPercent =
                  (1 - (currentHeight / maxHeight)).clamp(0.0, 1.0);

              // 반 이상 올라가면 완전 투명 (fade-out 효과)
              final opacity = (1 - scrollPercent * 2).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: maxHeight,
                  color: AppColors.white,
                  child: customHeader,
                ),
              );
            },
          ),
        ),
        // 본문 처리
        // 
        // body가 PageView인 경우: SliverFillRemaining 사용
        // - PageView는 전체 화면을 차지해야 함
        // - 스크롤은 PageView 내부의 페이지들이 처리
        // 
        // body가 일반 위젯인 경우: SliverToBoxAdapter 사용
        // - CustomScrollView는 Sliver 위젯만 자식으로 받을 수 있음
        // - 일반 위젯(body)을 Sliver로 변환
        // - Column 등 무한 높이 위젯도 유한한 크기로 제약하여 오버플로우 방지
        // - body는 Column을 사용할 때 mainAxisSize: MainAxisSize.min 필수
        // 
        // 예시:
        // - manager_home_screen.dart의 _HomeContent: SliverToBoxAdapter 사용
        // - report_screen.dart의 PageView: SliverFillRemaining 사용
        _buildBodySliver(),
      ],
    );
  }

  /// 일반 AppBar 빌더 (일반 모드에서 사용)
  /// 
  /// AppBar 구성 요소:
  /// 1. Title: title이 제공되면 표시
  /// 2. Leading: showBackButton=true이면 뒤로가기 버튼 표시
  /// 3. Actions: 
  ///    - actions 파라미터로 전달된 커스텀 버튼들
  ///    - showNotification=true이면 알림 버튼 자동 추가
  /// 4. Bottom: TabBar 지원 (tabController와 tabs 제공 시 자동 생성)
  /// 
  /// AppBar 테마:
  /// - primary: 파란색 배경 + 흰색 텍스트 (기본값)
  /// - white: 흰색 배경 + 검은색 텍스트
  /// - grey: 회색 배경 + 검은색 텍스트
  /// 
  /// 사용 예시:
  /// - camera_home_screen.dart: title='캠모드', 기본 테마(primary)
  /// - realtime_screen.dart: title='실시간 모니터링', showNotification=true
  /// - report_screen.dart: title='실시간 분석', TabBar 사용 (tabController + tabs 제공)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // TabBar 생성: tabController와 tabs가 모두 제공되면 자동으로 TabBar 생성
    // bottom 파라미터로 커스텀 위젯을 직접 제공할 수도 있음
    PreferredSizeWidget? appBarBottom = bottom;
    if (tabController != null && tabs != null) {
      appBarBottom = TabBar(
        controller: tabController,
        indicatorColor: _getAppBarTextColor(),
        labelColor: _getAppBarTextColor(),
        unselectedLabelColor: _getAppBarTextColor().withValues(alpha: 0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: tabs!,
      );
    }

    // 액션 버튼 구성
    // 1. 커스텀 actions 먼저 추가
    List<Widget> appBarActions = actions ?? [];
    // 2. showNotification=true이면 알림 버튼 자동 추가
    if (showNotification) {
      appBarActions = [
        ...appBarActions,
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: _getAppBarTextColor(),
          ),
          onPressed: onNotificationPressed ??
              () {
                context.push(AppRoutes.notification);
              },
        ),
      ];
    }

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: _getAppBarTextColor(),
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.appBarTitleFontSize,
              ),
            )
          : null,
      backgroundColor: _getAppBarBackgroundColor(),
      foregroundColor: _getAppBarTextColor(),
      elevation: AppConstants.appBarElevation,
      centerTitle: AppConstants.appBarCenterTitle,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: _getAppBarTextColor(),
                size: AppConstants.appBarIconSize,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: appBarActions.isNotEmpty ? appBarActions : null,
      bottom: appBarBottom,
    );
  }

  /// AppBar 배경색 반환
  /// 
  /// 테마에 따라 적절한 배경색 반환:
  /// - primary: 파란색 (매니저모드, 캠모드 공통)
  /// - white: 흰색
  /// - grey: 회색
  Color _getAppBarBackgroundColor() {
    switch (appBarTheme) {
      case AppBarThemeType.primary:
        return AppColors.AppBarColor;
      case AppBarThemeType.white:
        return AppColors.whiteAppBarColor;
      case AppBarThemeType.grey:
        return AppColors.greyAppBarColor;
    }
  }

  /// AppBar 텍스트 색상 반환
  /// 
  /// 테마에 따라 적절한 텍스트 색상 반환:
  /// - primary: 흰색 텍스트 (파란 배경에 대비)
  /// - white/grey: 검은색 텍스트 (밝은 배경에 대비)
  Color _getAppBarTextColor() {
    switch (appBarTheme) {
      case AppBarThemeType.primary:
        return AppColors.whiteAppBarTextColor;
      case AppBarThemeType.white:
      case AppBarThemeType.grey:
        return AppColors.blackAppBarTextColor;
    }
  }

  /// Body를 Sliver로 변환
  /// 
  /// body의 타입에 따라 적절한 Sliver 위젯을 반환합니다:
  /// - PageView: SliverFillRemaining 사용 (전체 화면 차지)
  /// - 일반 위젯: SliverToBoxAdapter 사용 (콘텐츠 높이에 맞춤)
  Widget _buildBodySliver() {
    // PageView인지 확인
    if (body is PageView) {
      return SliverFillRemaining(
        hasScrollBody: true,
        child: Padding(
          padding: AppConstants.smallPadding,
          child: body,
        ),
      );
    }

    // 일반 위젯인 경우
    return SliverToBoxAdapter(
      child: Padding(
        padding: AppConstants.smallPadding,
        child: body,
      ),
    );
  }
}

/// Scaffold 모드 열거형
enum ScaffoldMode {
  /// 일반 모드: 일반 AppBar를 사용하는 표준 화면
  normal,

  /// Collapsing Header 모드: 스크롤 시 사라지는 커스텀 헤더를 사용하는 화면
  collapsingHeader,
}

/// AppBar 테마 열거형
enum AppBarThemeType {
  primary,
  white,
  grey,
}
