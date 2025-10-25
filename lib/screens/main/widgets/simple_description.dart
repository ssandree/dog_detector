import 'package:flutter/material.dart';
import '../../../core/index_export.dart';

class SimpleDescription extends StatelessWidget {
   final Animation<double> animation;

   const SimpleDescription({
      super.key,
      required this.animation,
   });

   @override
   Widget build(BuildContext context) {
      return Transform.translate(
         offset: Offset(0, animation.value + 10), // 애니메이션 후 10픽셀 아래로
         child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
               // const SizedBox(height: 20),
            // 앱 아이콘/로고
            Container(
               width: 120,
               height: 120,
               decoration: BoxDecoration(
               color: AppColors.white.withValues(alpha: 0.4),
               borderRadius: BorderRadius.circular(
                  AppConstants.circularBorderRadius,
               ),
               ),
               child: const Icon(
               Icons.pets,
               size: 60,
               color: AppColors.beige3,
               ),
            ),
            const SizedBox(height: AppConstants.extraLargeSpacing),

            // 앱 타이틀
            const Text(
               '견심술',
               style: TextStyle(
               fontSize: AppConstants.largeTitleFontSize,
               fontWeight: FontWeight.w900,
               color: AppColors.beige5,
               letterSpacing: 2,
               ),
            ),
            const SizedBox(height: AppConstants.defaultSpacing),

            // 서비스 설명
            Text(
               'AI 기반 강아지 감정 탐지 서비스',
               textAlign: TextAlign.center,
               style: TextStyle(
               fontSize: AppConstants.titleFontSize - 6,
               color: AppColors.white,
               height: 1.5,
               ),
            ),
         ],
            ),
         ),
      );
   }
}
