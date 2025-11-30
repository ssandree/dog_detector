// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_constants.dart';
import '..//widgets/pet_greeting.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PetGreeting(),
            SizedBox(height: AppConstants.defaultSpacing),

          ],
        ),
      ),
    );
  }
}
