import '../core/index_export.dart';

/// 앱 전체에서 사용할 기본 Scaffold 위젯.
///
/// ======== 일반 AppBar를 사용하는 표준 화면을 위한 위젯 ========
/// 
/// 이 위젯은 일반 AppBar를 사용하는 표준 화면을 위한 기본 Scaffold입니다.
/// body는 개발자가 직접 제어해야 하며, 위젯은 body를 변형하지 않습니다.
/// 
/// **주요 특징:**
/// - 일반 AppBar 제공 (제목, 뒤로가기 버튼, 액션 버튼 등)
/// - TabBar 지원 (tabController + tabs 제공 시)
/// - SafeArea 선택적 적용
/// 
/// **body 처리 방법:**
/// - 스크롤이 필요하면: 개발자가 직접 SingleChildScrollView 또는 CustomScrollView 사용
/// - 패딩이 필요하면: `HorizontalPadding` 위젯 사용 (좌우 패딩만)
/// 
/// **사용 예시:**
/// ```dart
/// BaseScaffold(
///   title: '화면 제목',
///   showNotification: true,
///   body: SingleChildScrollView(
///     child: HorizontalPadding(
///       child: Column(
///         children: [...],
///       ),
///     ),
///   ),
/// )
/// ```
class BaseScaffold extends StatelessWidget {
  /// 화면 제목
  final String? title;

  /// 화면 본문
  /// 
  /// 주의: 이 위젯은 body를 변형하지 않습니다.
  /// - 스크롤이 필요하면: 개발자가 직접 SingleChildScrollView 사용
  /// - 패딩이 필요하면: HorizontalPadding 위젯 사용
  final Widget body;

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

  /// FloatingActionButton
  final Widget? floatingActionButton;

  /// BottomNavigationBar
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.title,
    required this.body,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.tabController,
    this.tabs,
    this.showNotification = false,
    this.onNotificationPressed,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// ======== Body 구성 ========
  /// 
  /// body를 그대로 사용합니다 (변형하지 않음).
  /// useSafeArea가 true이면 SafeArea로 감쌉니다.
  /// 
  /// 주의: body 내부에서 스크롤이나 패딩이 필요하면
  /// 개발자가 직접 SingleChildScrollView를 사용하고
  /// HorizontalPadding 위젯을 사용하세요.
  Widget _buildBody(BuildContext context) {
    Widget content = body;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    return content;
  }

  /// ======== AppBar 빌더 ========
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    PreferredSizeWidget? appBarBottom = bottom;
    if (tabController != null && tabs != null) {
      appBarBottom = TabBar(
        controller: tabController,
        indicatorColor: AppColors.whiteAppBarTextColor,
        labelColor: AppColors.whiteAppBarTextColor,
        unselectedLabelColor: AppColors.whiteAppBarTextColor.withValues(alpha: 0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: tabs!,
      );
    }
    List<Widget> appBarActions = actions ?? [];
    if (showNotification) {
      appBarActions = [
        ...appBarActions,
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.whiteAppBarTextColor,
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
              style: const TextStyle(
                color: AppColors.whiteAppBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.appBarTitleFontSize,
              ),
            )
          : null,
      backgroundColor: AppColors.appBarColor,
      foregroundColor: AppColors.whiteAppBarTextColor,
      elevation: AppConstants.appBarElevation,
      centerTitle: AppConstants.appBarCenterTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.whiteAppBarTextColor,
                size: AppConstants.appBarIconSize,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: appBarActions.isNotEmpty ? appBarActions : null,
      bottom: appBarBottom,
    );
  }
}

/// ======== 좌우 패딩만 제공하는 헬퍼 위젯 ========
/// 
/// BaseScaffold의 body에 좌우 패딩만 적용하고 싶을 때 사용합니다.
/// 
/// **사용 예시:**
/// ```dart
/// BaseScaffold(
///   title: '화면 제목',
///   body: SingleChildScrollView(
///     child: HorizontalPadding(
///       child: Column(
///         children: [...],
///       ),
///     ),
///   ),
/// )
/// ```
class HorizontalPadding extends StatelessWidget {
  final Widget child;
  final double? horizontalPadding;

  const HorizontalPadding({
    super.key,
    required this.child,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? AppConstants.smallPadding.horizontal,
      ),
      child: child,
    );
  }
}

/// ======== Collapsing Header를 위한 헬퍼 함수 ========
/// 
/// CustomScrollView를 사용하여 Collapsing Header 효과를 구현하는 헬퍼 함수입니다.
/// 각 화면에서 동일한 방식으로 Collapsing Header를 적용할 수 있습니다.
/// 
/// **사용 예시:**
/// ```dart
/// Scaffold(
///   body: buildCollapsingScrollView(
///     headerHeight: 80.0,
///     customHeader: _buildHeader(context),
///     child: Column(
///       children: [...],
///     ),
///   ),
/// )
/// ```
Widget buildCollapsingScrollView({
  required double headerHeight,
  required Widget customHeader,
  required Widget child,
  EdgeInsets? padding,
  bool fillRemaining = false,
}) {
  return CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      // Collapsing Header (SliverAppBar)
      SliverAppBar(
        automaticallyImplyLeading: false,
        expandedHeight: headerHeight,
        pinned: false,
        floating: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = headerHeight;
            final currentHeight = constraints.maxHeight;
            final scrollPercent =
                (1 - (currentHeight / maxHeight)).clamp(0.0, 1.0);
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
      // body를 Sliver로 변환
      fillRemaining
          ? SliverFillRemaining(
              hasScrollBody: child is PageView,
              child: Padding(
                padding: padding ?? EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding.horizontal,
                ),
                child: child,
              ),
            )
          : SliverToBoxAdapter(
              child: Padding(
                padding: padding ?? EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding.horizontal,
                ),
                child: child,
              ),
            ),
    ],
  );
}