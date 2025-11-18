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
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthInfo?>>(authProvider, (previous, next) {
      if (!_isSubmitting) return;

      next.when(
        data: (authInfo) {
          if (authInfo != null) {
            if (!mounted) return;
            setState(() {
              _isSubmitting = false;
              _errorMessage = null;
            });
            AppToast.success(context, '로그인 성공!');
            context.go(AppRoutes.modeSelect);
          } else {
            if (!mounted) return;
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = _mapError(error);
          });
        },
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = _isSubmitting && authState.isLoading;
    final hasError = _errorMessage != null && !isLoading;

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
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.appBarColor,
                              ),
                        ),
                        AppConstants.h8,
                        Text(
                          '강아지의 마음을 읽어보세요',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // 로그인 폼
                  LoginForm(key: _formKey),
                  if (hasError)
                    AppErrorBanner(
                      message: _errorMessage ?? '로그인에 실패했습니다. 다시 시도해주세요.',
                      onRetry: isLoading ? null : _submit,
                    ),
                  
                  AppConstants.h32,
              
                  // 버튼들
                  AppButtons.primary(
                    text: '로그인',
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
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
                      context.push(AppRoutes.main);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSubmitting) return;

    final email = _formKey.currentState!.email;
    final password = _formKey.currentState!.password;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    await ref.read(authProvider.notifier).login(email, password);
  }

  String _mapError(Object? error) {
    return '로그인에 실패했습니다. 다시 시도해주세요.';
  }
}

