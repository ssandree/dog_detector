import 'package:flutter/material.dart';

class EmailEditorModal {
  static Future<String?> show({
    required BuildContext context,
    required String initialEmail,
    String title = '이메일 수정',
    String hintText = '이메일 입력',
  }) async {
    final controller = TextEditingController(text: initialEmail);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      return controller.text.trim();
    }
    
    return null;
  }
}
