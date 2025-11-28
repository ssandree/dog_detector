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
  final VoidCallback? onNotificationPressed;
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
    final hasActions = (actions?.isNotEmpty ?? false) || showNotification;
    final shouldShowAppBar =
        hasTitle || showBackButton || hasActions || bottom != null;

    if (!shouldShowAppBar) {
      return null;
    }

    List<Widget> appBarActions = actions ?? [];

    if (showNotification) {
      appBarActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.notifications,
              color: AppColors.grey7,
              size: 28,
            ),
            onPressed: onNotificationPressed ?? () => context.push(AppRoutes.managerNotification),
          ),
        ),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: AppBar(
        title: title != null
            ? Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 8.0, top: 4.0),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              )
            : null,
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: showBackButton,
        titleSpacing: 0,
        leadingWidth: showBackButton ? 56 : 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
