import '../../../../core/index_export.dart';
import '../../../../services/home_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  List<Map<String, dynamic>> _weatherData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final data = await HomeService.getWeatherData();
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 어제 날씨를 제외하고 오늘, 내일, 모레만 표시
    final filteredWeatherData = _weatherData.skip(1).take(3).toList();
    
    return AppCards.basic(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny,
                color: AppColors.green6,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '3일간 날씨 예보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: filteredWeatherData.map((weather) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: WeatherItem(
                date: weather['date'] as String,
                temperature: weather['temperature'] as String,
                condition: weather['condition'] as String,
                icon: weather['icon'] as String,
                comment: weather['comment'] as String,
                color: Color(int.parse((weather['color'] as String).replaceFirst('#', '0xFF'))),
              ),
            )).toList(),
                ),
        ],
      ),
    );
  }
}

class WeatherItem extends StatelessWidget {
  final String date;
  final String temperature;
  final String condition;
  final String icon;
  final String comment;
  final Color color;

  const WeatherItem({
    super.key,
    required this.date,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.comment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 날짜와 아이콘
          Column(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 온도와 날씨 상태
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temperature,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                condition,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey8,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 코멘트
          Expanded(
            child: Text(
              comment,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
