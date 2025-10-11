import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../theme/app_colors.dart';

/// 앱 전체에서 사용할 기본 Scaffold 위젯
/// Scaffold, AppBar, SafeArea의 중복 구현을 해결하고 일관된 UI를 제공합니다.
class BaseScaffold extends StatelessWidget {
    /// 화면 제목
    final String? title;
    
    /// 화면 본문
    final Widget body;
    
    /// AppBar 표시 여부
    final bool showAppBar;
    
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
    
    /// SafeArea 적용 여부
    final bool useSafeArea;
    
    /// SafeArea 패딩 (기본값: EdgeInsets.zero)
    final EdgeInsets safeAreaPadding;
    
    /// Scaffold 배경색
    final Color? backgroundColor;
    
    /// FloatingActionButton
    final Widget? floatingActionButton;
    
    /// BottomNavigationBar
    final Widget? bottomNavigationBar;

    const BaseScaffold({
        super.key,
        this.title,
        required this.body,
        this.showAppBar = true,
        this.appBarTheme = AppBarThemeType.primary,
        this.showBackButton = true,
        this.onBackPressed,
        this.actions,
        this.bottom,
        this.useSafeArea = true,
        this.safeAreaPadding = EdgeInsets.zero,
        this.backgroundColor,
        this.floatingActionButton,
        this.bottomNavigationBar,
    });

    @override
    Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: backgroundColor ?? AppColors.defaultBackgroundColor,
          appBar: showAppBar ? _buildAppBar(context) : null,
          body: useSafeArea
          ? SafeArea(
                child: Padding(
                padding: safeAreaPadding,
                child: body,
                ),
              )
          : body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
        );
    }

    PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          actions: actions,
          bottom: bottom,
        );
    }

    Color _getAppBarBackgroundColor() {
      switch (appBarTheme) {
        case AppBarThemeType.primary:
          return AppColors.primaryAppBarColor;
        case AppBarThemeType.secondary:
          return AppColors.secondaryAppBarColor;
        case AppBarThemeType.white:
          return AppColors.whiteAppBarColor;
        case AppBarThemeType.grey:
          return AppColors.greyAppBarColor;
      }
    }

    Color _getAppBarTextColor() {
      switch (appBarTheme) {
        case AppBarThemeType.primary:
        case AppBarThemeType.secondary:
          return AppColors.whiteAppBarTextColor;
        case AppBarThemeType.white:
        case AppBarThemeType.grey:
          return AppColors.blackAppBarTextColor;
      }
    }
}

/// AppBar 테마 열거형
enum AppBarThemeType {
  primary,    // 파란색 (매니저모드)
  secondary,  // 녹색 (캠모드)
  white,      // 흰색
  grey,       // 회색
}
