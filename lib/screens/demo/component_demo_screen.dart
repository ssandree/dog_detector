import 'package:flutter/material.dart';
import '../../core/index_export.dart';

/// 버튼과 태그 컴포넌트 데모 화면
class ComponentDemoScreen extends StatelessWidget {
  const ComponentDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '컴포넌트 데모',
      appBarTheme: AppBarThemeType.white,
      body: SingleChildScrollView(
        padding: AppConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 버튼 섹션
            const Text(
              '버튼 컴포넌트',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 일반 버튼
            AppButtons.normal(
              text: '일반버튼',
              onPressed: () {},
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 눌린 버튼
            AppButtons.pressed(
              text: '눌림',
              onPressed: () {},
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 비활성 버튼
            AppButtons.disabled(text: '비활성'),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 테두리 버튼
            AppButtons.outline(
              text: '일반버튼',
              onPressed: () {},
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            
            // 상태 태그 섹션
            const Text(
              '상태 태그',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 기본 태그
            AppStatusTags.defaultTag(text: '태그'),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 좋음 태그
            AppStatusTags.good(text: '좋음'),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 보통 태그
            AppStatusTags.normal(text: '보통'),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 나쁨 태그
            AppStatusTags.bad(text: '나쁨'),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 아픔 태그
            AppStatusTags.pain(text: '아픔'),
            const SizedBox(height: AppConstants.extraLargeSpacing),
            
            // 사용 예시 섹션
            const Text(
              '사용 예시',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),
            
            // 분석 결과 예시
            Container(
              padding: AppConstants.defaultPadding,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '강아지 상태 분석',
                    style: TextStyle(
                      fontSize: AppConstants.titleFontSize - 4,
                      fontWeight: FontWeight.bold,
                      color: AppColors.analysisResultTitleColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing),
                  
                  // 상태 태그들
                  Wrap(
                    spacing: AppConstants.smallSpacing,
                    runSpacing: AppConstants.smallSpacing,
                    children: [
                      AppStatusTags.good(text: '정상'),
                      AppStatusTags.normal(text: '보통'),
                      AppStatusTags.bad(text: '주의'),
                      AppStatusTags.pain(text: '통증'),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultSpacing),
                  
                  // 액션 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: AppButtons.normal(
                          text: '상세보기',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultSpacing),
                      Expanded(
                        child: AppButtons.outline(
                          text: '닫기',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
