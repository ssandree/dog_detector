import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  const TopNav({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.bottom,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: iconColor ?? Colors.black,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom != null ? bottom!.preferredSize.height : 0));

  // 편의 생성자들
  factory TopNav.simple({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? titleColor,
    Color? iconColor,
    bool centerTitle = true,
  }) {
    return TopNav(
      title: title,
      onBackPressed: onBackPressed,
      actions: actions,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      iconColor: iconColor,
      centerTitle: centerTitle,
    );
  }

  factory TopNav.withNotification({
    required String title,
    VoidCallback? onBackPressed,
    VoidCallback? onNotificationPressed,
    Color? backgroundColor,
    Color? titleColor,
    Color? iconColor,
    bool centerTitle = true,
  }) {
    return TopNav(
      title: title,
      onBackPressed: onBackPressed,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: iconColor ?? Colors.black,
          ),
          onPressed: onNotificationPressed,
        ),
      ],
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      iconColor: iconColor,
      centerTitle: centerTitle,
    );
  }

  factory TopNav.withTabBar({
    required String title,
    required TabController tabController,
    required List<Tab> tabs,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? titleColor,
    Color? iconColor,
    bool centerTitle = true,
  }) {
    return TopNav(
      title: title,
      onBackPressed: onBackPressed,
      actions: actions,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      iconColor: iconColor,
      centerTitle: centerTitle,
      bottom: TabBar(
        controller: tabController,
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: tabs,
      ),
    );
  }

  factory TopNav.managerMode({
    required String title,
    VoidCallback? onBackPressed,
    VoidCallback? onSettingsPressed,
    Color? backgroundColor,
    Color? titleColor,
    Color? iconColor,
    bool centerTitle = true,
  }) {
    return TopNav(
      title: title,
      onBackPressed: onBackPressed,
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: iconColor ?? AppColors.white,
          ),
          onPressed: onSettingsPressed,
        ),
      ],
      backgroundColor: backgroundColor ?? AppColors.primaryAppBarColor,
      titleColor: titleColor ?? AppColors.white,
      iconColor: iconColor ?? AppColors.white,
      centerTitle: centerTitle,
    );
  }
}
