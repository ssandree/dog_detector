import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../config/app_colors.dart';
import '../routes/app_routes.dart';

/// 앱 전체에서 사용할 기본 Scaffold 위젯
class BaseScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showNotification;
  final bool showSettings;
  final bool useSafeArea;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    this.title,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.showNotification = false,
    this.showSettings = false,
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

  /// ===== Body =====
  Widget _buildBody(BuildContext context) {
    Widget content = body;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      color: AppColors.white,
      child: content,
    );
  }

  /// ===== AppBar =====
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    final hasTitle = title != null && title!.isNotEmpty;
    final hasActions = (actions?.isNotEmpty ?? false) || showNotification || showSettings;
    final shouldShowAppBar =
        hasTitle || showBackButton || hasActions || bottom != null;

    if (!shouldShowAppBar) {
      return null;
    }

    List<Widget> appBarActions = [];

    if (showNotification) {
      appBarActions.add(
        Padding(
          padding: EdgeInsets.only(right: 8.0.w, top: 4.0.h),
          child: IconButton(
            icon: Icon(
              Icons.notifications,
              color: AppColors.grey7,
              size: 25.sp,
            ),
            onPressed: () => context.push(AppRoutes.notification),
          ),
        ),
      );
    }

    if (showSettings) {
      appBarActions.add(
        Padding(
          padding: EdgeInsets.only(right: 8.0.w, top: 4.0.h),
          child: IconButton(
            icon: Icon(
              Icons.settings,
              color: AppColors.grey7,
              size: 28.sp,
            ),
            onPressed: () {

            },
          ),
        ),
      );
    }

    // actions는 마지막에 추가하여 가장 오른쪽에 배치
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: AppBar(
        title: title != null
            ? Padding(
                padding: EdgeInsets.only(
                  left: showBackButton ? 8.0.w : 32.0.w,
                  right: 8.0.w,
                  top: 8.0.h,
                ),
                child: Text(
                  title!,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              )
            : null,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              centerTitle: false,
              automaticallyImplyLeading: showBackButton,
              titleSpacing: 0,
              leadingWidth: showBackButton ? 56.w : 0,
              leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              )
            : const SizedBox.shrink(),
        actions: appBarActions,
        bottom: bottom,
      ),
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
        horizontal: (horizontalPadding ?? 16.0).w,
      ),
      child: child,
    );
  }
}
