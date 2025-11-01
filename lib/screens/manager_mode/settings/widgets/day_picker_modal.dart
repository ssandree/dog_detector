import '../../../../core/index_export.dart';

class DayPickerModal {
  static Future<int?> show({
    required BuildContext context,
    required int currentDay,
    String title = '날짜 선택',
  }) async {
    return await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: 31,
                    itemBuilder: (c, i) {
                      final day = i + 1;
                      return ListTile(
                        title: Text('매달 $day일'),
                        trailing: day == currentDay 
                            ? Icon(Icons.check, color: AppColors.green6) 
                            : null,
                        onTap: () => Navigator.pop(ctx, day),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
