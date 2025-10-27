import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;
  
  const SettingRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 최소 높이를 설정하되 텍스트에 따라 자동으로 늘어나도록 함
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 텍스트는 왼쪽 정렬 - 고정된 왼쪽 여백
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle!,
                        style: TextStyle(fontSize: 12, color: AppColors.grey8),
                        maxLines: 3, // 최대 3줄까지 허용
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 버튼은 오른쪽 정렬
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 6),
            child: trailing,
          ),
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  
  const ActionRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 최소 높이를 설정하되 텍스트에 따라 자동으로 늘어나도록 함
      constraints: const BoxConstraints(minHeight: 60),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 텍스트는 왼쪽 정렬 - 고정된 왼쪽 여백
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle!,
                            style: TextStyle(fontSize: 12, color: AppColors.grey8),
                            maxLines: 3, // 최대 3줄까지 허용
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // trailingText가 있으면 오른쪽에 표시
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 6),
                  child: Text(
                    trailingText!,
                    style: TextStyle(fontSize: 14, color: AppColors.grey9),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
