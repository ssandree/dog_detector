import '../../../core/index_export.dart';

/// 로그인/회원가입 화면 하단 링크 위젯
/// 
/// 현재 페이지를 자동으로 감지하여 적절한 텍스트와 링크를 표시합니다.
/// - 로그인 화면: "계정이 없으신가요?" → 회원가입
/// - 회원가입 화면: "이미 계정이 있으신가요?" → 로그인
class BottomLinkTo extends StatelessWidget {
  const BottomLinkTo({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 route 경로 확인
    final currentPath = GoRouterState.of(context).uri.path;
    final isLoginScreen = currentPath == AppRoutes.login;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLoginScreen ? '계정이 없으신가요? ' : '이미 계정이 있으신가요? ',
          style: TextStyle(
            fontSize: AppConstants.smallFontSize,
            color: AppColors.grey8,
          ),
        ),
        TextButton(
          onPressed: () {
            if (isLoginScreen) {
              context.push(AppRoutes.signup);
            } else {
              context.pop(); // 회원가입 화면에서 로그인 화면으로 돌아가기
            }
          },
          child: Text(
            isLoginScreen ? '회원가입' : '로그인',
            style: TextStyle(
              fontSize: AppConstants.smallFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.appBarColor,
            ),
          ),
        ),
      ],
    );
  }
}