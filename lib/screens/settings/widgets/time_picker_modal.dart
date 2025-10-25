import 'package:flutter/material.dart';

class TimePickerModal {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String helpText = '시간 선택',
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
    );
  }
}
