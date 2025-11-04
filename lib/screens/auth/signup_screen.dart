import '../../core/index_export.dart';
import 'widgets/bottom_linkto.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: AppColors.whiteAppBarColor,
        foregroundColor: AppColors.blackAppBarTextColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppConstants.smallPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                const SizedBox(height: 20),
                
                // 이름 입력
                AppInputField(
                  controller: _nameController,
                  label: '이름',
                  hint: '이름을 입력해주세요',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 이메일 입력
                AppInputField(
                  controller: _emailController,
                  label: '이메일',
                  hint: '이메일을 입력해주세요',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppInputValidator.combine([
                    AppInputValidator.required,
                    AppInputValidator.email,
                  ]),
                ),
                
                const SizedBox(height: 20),
                
                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력해주세요 (6자 이상)',
                    prefixIcon: const Icon(Icons.lock),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.grey4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.grey4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.green6, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: const BorderSide(color: AppColors.errorRed),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 비밀번호 확인 입력
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '비밀번호 확인을 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력해주세요',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.grey7,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.grey4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.grey4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppColors.green6, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: const BorderSide(color: AppColors.errorRed),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 회원가입 버튼
                _buildSignupButton(),
                
                const SizedBox(height: 32),
                
                // 하단 링크 (로그인)
                const BottomLinkTo(),
                const SizedBox(height: 16),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    final authAsync = ref.watch(authProvider);
    
    return authAsync.when(
      data: (authInfo) => AppButtons.primary(
        text: '회원가입',
        onPressed: () => _handleSignup(),
        isLoading: false,
      ),
      loading: () => AppButtons.primary(
        text: '회원가입',
        onPressed: null,
        isLoading: true,
      ),
      error: (error, stack) => AppButtons.primary(
        text: '회원가입',
        onPressed: () => _handleSignup(),
        isLoading: false,
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    try {
      await ref.read(authProvider.notifier).signup(email, password, name);
      
      if (mounted) {
        final authState = ref.read(authProvider);
        authState.when(
          data: (authInfo) {
            if (authInfo != null) {
              AppToast.success(context, '회원가입이 완료되었습니다!');
              context.pop();
            }
          },
          loading: () {},
          error: (error, stack) {
            AppToast.error(context, '회원가입에 실패했습니다. 다시 시도해주세요.');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, '회원가입에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }
}

