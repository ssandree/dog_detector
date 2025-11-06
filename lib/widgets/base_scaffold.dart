import '../core/index_export.dart';

/// 앱 전체에서 사용할 기본 Scaffold 위젯
class BaseScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showNotification;
  final VoidCallback? onNotificationPressed;
  final bool useSafeArea;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool useCollapsingHeader;
  final double? collapseHeaderHeight;
  final Widget? collapseCustomHeader;
  final String? collapseHeaderTitle;
  final List<Widget>? collapseHeaderActions;
  final EdgeInsets? collapsePadding;
  final bool collapseFillRemaining;

  const BaseScaffold({
    super.key,
    this.title,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.showNotification = false,
    this.onNotificationPressed,
    this.useSafeArea = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.useCollapsingHeader = false,
    this.collapseHeaderHeight,
    this.collapseCustomHeader,
    this.collapseHeaderTitle,
    this.collapseHeaderActions,
    this.collapsePadding,
    this.collapseFillRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: useCollapsingHeader ? null : _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// ===== Body =====
  Widget _buildBody(BuildContext context) {
    Widget content = body;

    if (useCollapsingHeader && collapseHeaderHeight != null) {
      final header = collapseCustomHeader ?? _buildDefaultCollapseHeader(context);
      content = _buildCollapsingScrollView(
        context,
        title: collapseHeaderTitle,
        headerHeight: collapseHeaderHeight!,
        customHeader: header,
        padding: collapsePadding,
        fillRemaining: collapseFillRemaining,
        child: content,
      );
    } else if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }

  /// ===== AppBar =====
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    List<Widget> appBarActions = actions ?? [];

    if (showNotification) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.blackAppBarTextColor),
          onPressed: onNotificationPressed ?? () => context.push(AppRoutes.notification),
        ),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(AppConstants.appBarHeight),
      child: AppBar(
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(
                  color: AppColors.blackAppBarTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.appBarTitleFontSize,
                ),
              )
            : null,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blackAppBarTextColor,
        elevation: AppConstants.appBarElevation,
        centerTitle: AppConstants.appBarCenterTitle,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackAppBarTextColor),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        actions: appBarActions,
        bottom: bottom,
      ),
    );
  }

  /// ===== 기본 Collapsing Header =====
  Widget _buildDefaultCollapseHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: statusBarHeight,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (collapseHeaderTitle != null)
            Text(
              collapseHeaderTitle!,
              style: const TextStyle(
                color: AppColors.blackAppBarTextColor,
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.appBarTitleFontSize,
              ),
            ),
          if (collapseHeaderActions != null && collapseHeaderActions!.isNotEmpty)
            Row(children: collapseHeaderActions!),
        ],
      ),
    );
  }

  /// ===== Collapsing ScrollView =====
  Widget _buildCollapsingScrollView(
    BuildContext context, {
    String? title,
    required double headerHeight,
    required Widget customHeader,
    required Widget child,
    EdgeInsets? padding,
    bool fillRemaining = false,
  }) {
    return CustomScrollView(
      key: PageStorageKey('collapsingScroll_${title ?? ''}'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: headerHeight,
          collapsedHeight: headerHeight, // 접힘 상태에서도 동일 높이 유지
          pinned: false,
          floating: false, // 애니메이션 없이 안정적
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          flexibleSpace: SizedBox.expand(child: customHeader),
        ),
        fillRemaining
            ? SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
                    child: child,
                  ),
                ]),
              )
            : SliverToBoxAdapter(
                child: Padding(
                  padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
                  child: child,
                ),
              ),
      ],
    );
  }
}

/// 좌우 패딩만 제공하는 헬퍼 위젯
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
