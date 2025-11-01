import '../../core/index_export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultBackgroundColor,
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: AppColors.whiteAppBarColor,
        foregroundColor: AppColors.blackAppBarTextColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppConstants.smallPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // 로고/타이틀 영역
                Center(
                  child: Column(
                    children: [
                      Text(
                        '견심술',
                        style: TextStyle(
                          fontSize: AppConstants.largeTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.AppBarColor,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                
                // 이메일 입력
                AppInputField(
                  controller: _emailController,
                  label: '이메일',
                  hint: '이메일을 입력해주세요',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppInputValidator.required,
                ),
                
                const SizedBox(height: 24),
                
                // 비밀번호 입력
                AppInputField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hint: '비밀번호를 입력해주세요',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey7,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: AppInputValidator.required,
                ),
                
                const SizedBox(height: 32),
                
                // 로그인 버튼
                AppButtons.primary(
                  text: '로그인',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 12),
                
                // 로그인 없이 이용 버튼
                AppButtons.normal(
                  text: '로그인 없이 이용',
                  onPressed: () {
                    context.go(AppRoutes.modeSelect);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요? ',
                      style: TextStyle(
                        fontSize: AppConstants.smallFontSize,
                        color: AppColors.grey8,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.signup);
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: AppConstants.smallFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.AppBarColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 인증 API 호출
      await Future.delayed(const Duration(seconds: 1)); // 로딩 시뮬레이션
      
      if (mounted) {
        AppToast.success(context, '로그인 성공!');
        context.go(AppRoutes.modeSelect);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, '로그인에 실패했습니다. 다시 시도해주세요.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

