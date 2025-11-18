import '../../../../core/index_export.dart';
import 'package:email_validator/email_validator.dart';

class EmailEditorModal {
  static Future<String?> show({
    required BuildContext context,
    required String initialEmail,
    String title = '이메일 수정',
    String hintText = '이메일 입력',
  }) async {
    final controller = TextEditingController(text: initialEmail);
    
    String? errorText;

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void handleSave() {
              final value = controller.text.trim();
              if (value.isEmpty) {
                setState(() => errorText = '이메일을 입력해주세요.');
                return;
              }

              if (!EmailValidator.validate(value)) {
                setState(() => errorText = '올바른 이메일 형식이 아니에요.');
                return;
              }

              Navigator.pop(ctx, value);
            }

        return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.blackAppBarTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
            controller: controller,
                    autofocus: true,
            keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      hintText: hintText,
                      filled: true,
                      fillColor: AppColors.grey1,
                      errorText: errorText,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.grey3),
                        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.green5, width: 1.5),
                        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
                        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
                        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => handleSave(),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() => errorText = null);
                      }
                    },
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.grey8,
                  ),
                  onPressed: () => Navigator.pop(ctx, null),
              child: const Text('취소'),
            ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green6,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: handleSave,
              child: const Text('저장'),
            ),
          ],
            );
          },
        );
      },
    );
    
    controller.dispose();
    return result;
  }
}
