import 'package:flutter/material.dart';
import '../../../../core/index_export.dart';
import '../../../settings/setting_screen.dart';

class PetGreetingCard extends StatelessWidget {
  const PetGreetingCard({super.key});

  // TODO: PetInfo를 prop으로 받거나 다른 상태 관리 방법 사용
  bool get _isPetRegistered => false;
  String get _petName => '';

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.green2,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.pets,
              color: AppColors.green6,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPetRegistered 
                    ? '안녕하세요 $_petName님~'
                    : '강아지 정보를 등록해주세요',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey12,
                  ),
                ),
                if (_isPetRegistered) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '오늘도 건강한 하루 보내세요! 🐕',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
