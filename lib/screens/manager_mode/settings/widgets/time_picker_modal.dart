import '../../../../core/index_export.dart';

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.white,
              hourMinuteTextColor: AppColors.blackAppBarTextColor,
              hourMinuteColor: WidgetStateColor.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.green6;
                  }
                  return AppColors.grey2;
                },
              ),
              dialBackgroundColor: AppColors.grey1,
              dialHandColor: AppColors.green6,
              dialTextColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.white
                    : AppColors.grey9,
              ),
              entryModeIconColor: AppColors.green6,
              helpTextStyle: const TextStyle(
                color: AppColors.blackAppBarTextColor,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            ),
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: AppColors.blackAppBarTextColor,
                  displayColor: AppColors.blackAppBarTextColor,
                ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.green6,
                  secondary: AppColors.green5,
                  surface: AppColors.white,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
