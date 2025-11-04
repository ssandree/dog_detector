import '../../../core/index_export.dart';

/// 로그인 폼 위젯
/// 
/// 이메일, 비밀번호 입력 필드만 포함합니다.
/// 폼 검증과 입력값 접근을 위해 GlobalKey를 사용하세요.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// 폼 검증
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  /// 이메일 값 가져오기
  String get email => _emailController.text.trim();

  /// 비밀번호 값 가져오기
  String get password => _passwordController.text;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
        ],
      ),
    );
  }
}

