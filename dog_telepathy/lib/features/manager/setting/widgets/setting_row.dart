import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/widgets/app_section.dart';

/// 설정 섹션 위젯
/// 제목과 자식 위젯들을 표시하며, 자식 위젯들 사이에 Divider를 추가합니다.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets? padding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: title,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildrenWithDividers(),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    if (children.isEmpty) return children;
    
    List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      // 마지막 항목이 아니면 Divider 추가
      if (i < children.length - 1) {
        result.add(const Divider(
          height: 1,
          color: AppColors.grey3,
          thickness: 0.5,
        ));
      }
    }
    return result;
  }
}

/// 설정 행 위젯
/// 제목, 부제목, 그리고 오른쪽에 trailing 위젯을 표시합니다.
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
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    
    return Container(
      // 최소 높이를 설정하되 텍스트에 따라 자동으로 늘어나도록 함
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: hasSubtitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // 텍스트는 왼쪽 정렬 - 고정된 왼쪽 여백
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: hasSubtitle ? MainAxisAlignment.start : MainAxisAlignment.center,
              mainAxisSize: hasSubtitle ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                if (hasSubtitle)
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
          // 버튼은 오른쪽 정렬
          Padding(
            padding: EdgeInsets.only(top: hasSubtitle ? 6 : 0),
            child: trailing,
          ),
        ],
      ),
    );
  }
}

/// 액션 행 위젯
/// 클릭 가능한 설정 행으로, trailingText를 표시하고 onTap 콜백을 실행합니다.
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
    return Material(
      color: Colors.transparent,
      child: Container(
        // 최소 높이를 설정하되 텍스트에 따라 자동으로 늘어나도록 함
        constraints: const BoxConstraints(minHeight: 60),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 텍스트는 왼쪽 정렬 - 고정된 왼쪽 여백
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: trailingText == null ? 6 : 0),
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
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      trailingText!,
                      style: TextStyle(fontSize: 14, color: AppColors.grey9),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
