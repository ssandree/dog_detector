import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'app_cards.dart';

class AppSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? trailing;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.margin,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey8,
                      ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          AppCards.basic(
            padding: padding ?? const EdgeInsets.all(0),
            child: child,
          ),
        ],
      ),
    );
  }
}

