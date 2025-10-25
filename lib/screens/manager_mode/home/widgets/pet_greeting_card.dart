import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/index_export.dart';
import '../../../../providers/pet_providers.dart';
import '../../../settings/setting_screen.dart';

class PetGreetingCard extends StatelessWidget {
  const PetGreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final petInfo = petProvider.petInfo;
        final isPetRegistered = petInfo != null && petInfo.name.isNotEmpty;
        
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
                      isPetRegistered 
                        ? '안녕하세요 ${petInfo!.name}님~'
                        : '강아지 정보를 등록해주세요',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey12,
                      ),
                    ),
                    if (isPetRegistered) ...[
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
      },
    );
  }
}
