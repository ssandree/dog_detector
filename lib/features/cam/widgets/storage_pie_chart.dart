/// lib/features/cam/widgets/storage_pie_chart.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import '../model/storage_info.dart';

class StoragePieChart extends StatelessWidget {
  const StoragePieChart({super.key});

  Future<Map<String, double>> _loadStorageInfo() async {
    final storage = await StorageInfo.getStorage();

    final dir = await getApplicationDocumentsDirectory();
    final clipsDir = Directory("${dir.path}/clips");
    int clipsSize = 0;

    if (clipsDir.existsSync()) {
      for (final file in clipsDir.listSync(recursive: true)) {
        if (file is File) clipsSize += await file.length();
      }
    }

    return {
      "total": storage["total"]!,
      "used": storage["used"]!,
      "free": storage["free"]!,
      "clips": clipsSize.toDouble(),
    };
  }

  String _bytesToGB(double bytes) =>
      (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadStorageInfo(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!;
        final total = data["total"]!;
        final used = data["used"]!;
        final free = data["free"]!;
        final clips = data["clips"]!;

        final usedPercent = used / total;
        final freePercent = free / total;

        final isFull = usedPercent > 0.9;

        return Column(
          children: [
            const SizedBox(height: 16),

            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: usedPercent,
                      color: isFull ? Colors.redAccent : Colors.blueAccent,
                      radius: 32,
                      title: "${(usedPercent * 100).toStringAsFixed(1)}%",
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: freePercent,
                      color: Colors.green,
                      radius: 28,
                      title: "",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _infoRow("총 용량", "${_bytesToGB(total)} GB", Colors.black87),
            _infoRow("사용 중", "${_bytesToGB(used)} GB", Colors.blue),
            _infoRow("가용 공간", "${_bytesToGB(free)} GB", Colors.green),
            _infoRow("클립 사용량", "${_bytesToGB(clips)} GB", Colors.orange),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
