import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/index_export.dart';

class MonthlyTrendAnalysis extends StatelessWidget {
  final String title;
  final List<RadarEntry> radarEntries;
  final List<String> radarTitles;

  const MonthlyTrendAnalysis({
    super.key,
    required this.title,
    required this.radarEntries,
    required this.radarTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.titleFontSize - 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing - 1),
        Container(
          height: 300,
          padding: const EdgeInsets.all(AppConstants.defaultSpacing - 1),
          decoration: BoxDecoration(
            color: AppColors.grey1,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius + 2),
          ),
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.green5.withValues(alpha: 0.3),
                  borderColor: AppColors.green5,
                  entryRadius: 5,
                  dataEntries: radarEntries,
                ),
              ],
              radarBorderData: BorderSide(color: AppColors.grey4, width: 2),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: const TextStyle(
                color: AppColors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: radarTitles[index],
                  angle: angle,
                );
              },
              tickBorderData: BorderSide(color: AppColors.grey4),
              gridBorderData: BorderSide(color: AppColors.grey4, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
