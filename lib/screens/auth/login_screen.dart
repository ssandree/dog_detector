import '../../core/index_export.dart';
import 'widgets/login_form.dart';
import 'widgets/bottom_linkto.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<LoginFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단 콘텐츠 그룹
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // 로고/타이틀 영역
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '견심술',
                          style: TextStyle(
                            fontSize: AppConstants.largeTitleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.appBarColor,
                          ),
                        ),
                        AppConstants.h8,
                        Text(
                          '강아지의 마음을 읽어보세요',
                          style: TextStyle(
                            fontSize: AppConstants.defaultFontSize,
                            color: AppColors.grey8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // 로그인 폼
                  LoginForm(key: _formKey),
                  
                  AppConstants.h32,
              
                  // 버튼들
                  _buildLoginButton(),
                  AppConstants.h24,
                  
                  // 로그인 없이 이용 버튼
                  AppButtons.normal(
                    text: '(임시) 로그인 없이 이용',
                    onPressed: () {
                      context.go(AppRoutes.modeSelect);
                    },
                  ),
                  AppConstants.h12,
                  
                  // main_screen으로 돌아가기
                  AppButtons.outline(
                    text: '(임시) 이전 페이지로 돌아가기',
                    onPressed: () {
                      context.go(AppRoutes.main);
                    },
                  ),
                ],
              ),
              
              // 하단 링크 (회원가입)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: BottomLinkTo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final authAsync = ref.watch(authProvider);
    
    return authAsync.when(
      data: (authInfo) => AppButtons.primary(
        text: '로그인',
        onPressed: () => _handleLogin(),
        isLoading: false,
      ),
      loading: () => AppButtons.primary(
        text: '로그인',
        onPressed: null,
        isLoading: true,
      ),
      error: (error, stack) => AppButtons.primary(
        text: '로그인',
        onPressed: () => _handleLogin(),
        isLoading: false,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _formKey.currentState!.email;
    final password = _formKey.currentState!.password;

    try {
      await ref.read(authProvider.notifier).login(email, password);
      
      if (mounted) {
        final authState = ref.read(authProvider);
        authState.when(
          data: (authInfo) {
            if (authInfo != null) {
              AppToast.success(context, '로그인 성공!');
              context.go(AppRoutes.modeSelect);
            }
          },
          loading: () {},
          error: (error, stack) {
            AppToast.error(context, '로그인에 실패했습니다. 다시 시도해주세요.');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, '로그인에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }
}

