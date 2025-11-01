import '../../../../core/index_export.dart';
import '../../../../services/home_service.dart';

class AIRecommendationCard extends StatefulWidget {
  const AIRecommendationCard({super.key});

  @override
  State<AIRecommendationCard> createState() => _AIRecommendationCardState();
}

class _AIRecommendationCardState extends State<AIRecommendationCard> {
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final data = await HomeService.getAIRecommendations();
    if (mounted) {
      setState(() {
        _recommendations = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: AppColors.green6,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 추천 액션',
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
                  children: _recommendations.map((recommendation) => RecommendationItem(
                    title: recommendation['title'] as String,
                    description: recommendation['description'] as String,
                    priority: recommendation['priority'] as String,
                    icon: recommendation['icon'] as String,
                  )).toList(),
                ),
        ],
      ),
    );
  }
}

class RecommendationItem extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final String icon;

  const RecommendationItem({
    super.key,
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
  });

  Color get _priorityColor {
    switch (priority) {
      case 'high':
        return AppColors.coral4;
      case 'medium':
        return AppColors.green4;
      case 'low':
        return AppColors.grey6;
      default:
        return AppColors.grey6;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _priorityColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
