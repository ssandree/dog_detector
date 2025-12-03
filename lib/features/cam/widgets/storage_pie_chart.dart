// lib/features/cam/widgets/storage_pie_chart.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StoragePieChart extends StatefulWidget {
  const StoragePieChart({super.key});

  @override
  State<StoragePieChart> createState() => _StoragePieChartState();
}

class _StoragePieChartState extends State<StoragePieChart> {
  int totalSpace = 0;
  int usedSpace = 0;
  int freeSpace = 0;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final dir = await getApplicationDocumentsDirectory();

    final systemTemp = Directory.systemTemp;
    final stat2 = await systemTemp.stat();

    totalSpace = stat2.size;

    final clips = Directory("${dir.path}/clips");
    int clipsSize = 0;

    if (clips.existsSync()) {
      for (final file in clips.listSync()) {
        if (file is File && file.path.endsWith(".mp4")) {
          clipsSize += await file.length();
        }
      }
    }

    usedSpace = clipsSize;
    freeSpace = totalSpace - usedSpace;

    if (freeSpace < 0) freeSpace = 0;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final used = usedSpace.toDouble();

    final total = totalSpace.toDouble() == 0 ? 1 : totalSpace.toDouble();

    final usedPercent = (used / total).clamp(0, 1);

    return Column(
      children: [
        const Text(
          "저장 공간 현황",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 160,
          width: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: usedPercent.toDouble(),
                strokeWidth: 18,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blueAccent,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(usedPercent * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Used",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "총 용량: ${(totalSpace / (1024 * 1024)).toStringAsFixed(1)} MB",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "사용 중: ${(usedSpace / (1024 * 1024)).toStringAsFixed(1)} MB",
          style: const TextStyle(fontSize: 14, color: Colors.blueAccent),
        ),
        Text(
          "남은 용량: ${(freeSpace / (1024 * 1024)).toStringAsFixed(1)} MB",
          style: const TextStyle(fontSize: 14, color: Colors.green),
        ),
      ],
    );
  }
}
